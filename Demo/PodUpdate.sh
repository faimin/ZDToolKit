#!bin/sh
# rm -rf Podfile.lock
# rm -rf Pods

bundle install
bundle exec pod update --no-repo-update
