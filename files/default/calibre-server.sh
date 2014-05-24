#! /bin/sh
# Calibre server init script

# settings
LIBDIR=/home/calibre/library
PIDFILE=/home/calibre/calibre-server.pid
EXEC="/usr/bin/calibre-server"

# user and group the server will run under
USER=calibre
GROUP=calibre

# username and password to access the server
# note: password WILL be visible in the list of processes
#USERNAME="test"
#PASSWORD="test"

# port the server will listen on
PORT=8080

# end of settings

PIDFILE=$LIBDIR/calibre-server.pid
#OPTIONS="--port $PORT --username $USERNAME --password $PASSWORD --with-library $LIBDIR --pidfile $PIDFILE --daemonize"
OPTIONS="--port $PORT --with-library $LIBDIR --pidfile $PIDFILE --daemonize"
N="calibre-server"

do_start ()
{
    # start it through shell and pass it some reasonable $HOME
    start-stop-daemon --start --chuid $USER:$GROUP --pidfile $PIDFILE --startas "/bin/bash" -- -c "HOME=$LIBDIR $EXEC $OPTIONS"
}

do_stop ()
{
    start-stop-daemon --stop --pidfile $PIDFILE
}

set -e

case "$1" in
  start)
    echo -n "Starting $N: "
    do_start
    echo "done."
    ;;

  stop)
    echo -n "Stopping $N: "
    do_stop
    echo "done."
    ;;

  reload|force-reload|restart)
    echo -n "Restarting $N: "
    do_stop
    sleep 1 # what the fuck
    do_start
    echo "done."
    ;;
  *)
    echo "Usage: calibre-server {start|stop|restart|reload|force-reload}" >&2
    exit 1
    ;;
esac

exit 0