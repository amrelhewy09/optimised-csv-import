#!/bin/bash
rm -f /myapp/tmp/pids/server.pid
bundle install
bundle exec rails db:migrate 2>/dev/null || bundle exec rails db:create db:migrate
exec "$@"
