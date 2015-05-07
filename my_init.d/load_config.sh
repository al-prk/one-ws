#!/usr/bin/env sh

exec /usr/bin/ruby /config/build.rb >> /var/log/config_loader.log 2>&1