#!/bin/sh
export RAILS_ENV=development
export DISABLE_DATABASE_ENVIRONMENT_CHECK=1

if [ "$2x" != "x" ]
then
  echo "Populating $2"

  psql $2 < $1
else
  echo "Populating tool"

  bundle exec rake db:drop
  bundle exec bundle exec rake db:create

  psql tool < $1

  bundle exec bundle exec rake db:migrate
fi

