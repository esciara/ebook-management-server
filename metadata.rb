name             'ebook-management-server'
maintainer       'Emmanuel Sciara'
maintainer_email 'emmanuel.sciara@gmail.com'
license          'Apache 2.0'
description      'Installs/Configures an ebook management server'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

recipe 'ebook-management-server', 'Installs/configures an ebook management server'

%w(ubuntu).each do |os|
  supports os
end

%w(apt locale).each do |cb|
  depends cb
end

