#! /bin/sh

# Copyright (C) 2011- by Mar2zz <LaSi.Mar2zz@gmail.com>
# released under GPL, version 2 or later

#######################################################
#                                                     #
#  TO CONFIGURE EDIT /etc/default/calibre-server      #
#                                                     #
#######################################################

### BEGIN INIT INFO
# Provides:          Calibre server instance
# Required-Start:    $all
# Required-Stop:     $all
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts instance of Calibre server
# Description:       starts instance of Calibre server using start-stop-daemon
### END INIT INFO

# main variables
DAEMON=/usr/bin/calibre-server
SETTINGS=/etc/default/calibre-server

SETTINGS_LOADED=FALSE

DESC='Calibre Server'

# only accept values from /etc/default/calibre-server
unset RUN_AS LIBRARY PORT PID_FILE

. /lib/lsb/init-functions

[ -x $DAEMON ] || {
    log_warning_msg "$DESC: Can't execute daemon, aborting. See $DAEMON";
    return 1; }

[ -r $SETTINGS ] || {
    log_warning_msg "$DESC: Can't read settings, aborting. See $SETTINGS";
    return 1; }

check_retval() {
    if [ $? -eq 0 ]; then
        log_end_msg 0
        return 0
    else
        log_end_msg 1
        exit 1
    fi
}

load_settings() {
    if [ $SETTINGS_LOADED != "TRUE" ]; then
        . $SETTINGS

        [ -n "$APP_PATH" ] || {
            log_warning_msg "$DESC: path to $DESC not set, aborting. See $SETTINGS";
            return 1; }

        [ $ENABLE_DAEMON = 1 ] || {
            log_warning_msg "$DESC: daemon not enabled, aborting. See $SETTINGS";
            return 1; }

        [ -n "$RUN_AS" ] || {
            log_warning_msg "$DESC: daemon username not set, aborting. See $SETTINGS";
            return 1; }
        [ -z "${RUN_AS%:*}" ] && exit 1

        DAEMON_OPTS="--daemonize"
        [ -n "$LIBRARY" ] && DAEMON_OPTS="$DAEMON_OPTS --with-library=$LIBRARY"
        [ -n "$PORT" ] && DAEMON_OPTS="$DAEMON_OPTS --port=$PORT"
        [ -n "$USERNAME" ] && DAEMON_OPTS="$DAEMON_OPTS --username=$USERNAME"
        [ -n "$PASSWORD" ] && DAEMON_OPTS="$DAEMON_OPTS --password=$PASSWORD"
        [ -n "$COVERSIZE" ] && DAEMON_OPTS="$DAEMON_OPTS --max-cover=$MAX_COVER"
        [ -n "$EXTRA_OPTS" ] && DAEMON_OPTS="DAEMON_OPTS $EXTRA_OPTS"
        [ -n "$PID_FILE" ] || PID_FILE=/var/run/calibre/calibre-server.pid
        DAEMON_OPTS="$DAEMON_OPTS --pidfile=$PID_FILE"
        [ $ENABLE_DEVELOPMENT = 1 ] && DAEMON_OPTS="$DAEMON_OPTS --develop"
        SETTINGS_LOADED=TRUE
    fi
    return 0
}

load_settings || exit 0

is_running () {
    # returns 1 when running, else 0.
    PID=$(pgrep -f "$APP_PATH/bin/calibre-server $DAEMON_OPTS")
    RET=$?
    [ $RET -gt 1 ] && exit 1 || return $RET
}

handle_pid () {
    PID_PATH=`dirname $PID_FILE`
    [ -d $PID_PATH ] || mkdir -p $PID_PATH && chown -R $RUN_AS $PID_PATH > /dev/null || {
        log_warning_msg "$DESC: Could not create $PID_FILE, aborting.";
        return 1;}
}

start_calibre () {
    if ! is_running; then
        log_daemon_msg "Starting $DESC"
        [ "$WEB_UPDATE" = 1 ] && enable_updates
        handle_pid
        start-stop-daemon -o -c $RUN_AS --start --pidfile $PID_FILE --exec $DAEMON -- $DAEMON_OPTS
        check_retval
    else
        log_success_msg "$DESC: already running (pid $PID)"
    fi
}

stop_calibre () {
    if is_running; then
        log_daemon_msg "Stopping $DESC"
        start-stop-daemon -o --stop --pidfile $PID_FILE --retry 15
        check_retval
    else
        log_success_msg "$DESC: not running"
    fi
}

case "$1" in
    start)
        start_calibre
        ;;
    stop)
        stop_calibre
        ;;
    restart|force-reload)
        stop_calibre
        start_calibre
        ;;
    *)
        N=/etc/init.d/$NAME
        echo "Usage: $N {start|stop|restart|force-reload}" >&2
        exit 1
        ;;
esac

exit 0
