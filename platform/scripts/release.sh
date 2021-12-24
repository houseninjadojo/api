#!/bin/sh

echo "RUN: bundle exec rails db:migrate"
bundle exec rails db:migrate
echo "DONE: bundle exec rails db:migrate"
