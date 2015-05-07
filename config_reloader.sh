#!/bin/sh

HOME=/root BUNDLE_GEMFILE=/config/Gemfile exec bundle exec guard -w /descriptors/ --guardfile /config/Guardfile -i
