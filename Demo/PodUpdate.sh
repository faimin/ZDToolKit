#!/bin/bash
# rm -rf Podfile.lock
# rm -rf Pods

gem install bundler
bundle install
bundle exec pod update --no-repo-update
