#!/bin/sh

/usr/bin/ruby /config/build.rb
/usr/sbin/apache2ctl -D FOREGROUND
