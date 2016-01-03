name             'mediawiki'
maintainer       'wasya.co'
maintainer_email 'victor@wasya.co'
license          'All rights reserved'
description      'Installs/Configures mediawiki'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.2.0'

depends 'mysql'
depends 'ish_apache'
depends "php"
