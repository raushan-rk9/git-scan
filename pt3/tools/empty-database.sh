#!/bin/sh
if [ "$1x" != "x" ]
then
  shift                                        ;
  export RAILS_ENV=$1                          ;
else
  export RAILS_ENV=development                 ;
  export DISABLE_DATABASE_ENVIRONMENT_CHECK=1  ;
fi

bundle exec rake db:drop
bundle exec bundle exec rake db:create
bundle exec bundle exec rake db:migrate
bundle exec bundle exec rake db:seed
rails db:fixtures:load FIXTURES=minimum_users_prod
bundle exec rails runner tools/populate_templates.rb