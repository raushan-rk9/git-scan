#!/bin/sh
export DBNAME=$1

if [ "${DBNAME}x" == "x" ]
then
  echo 'No Database specified. Usage: create-new-organization DATABASE [RAILS_ENV]' ;
  exit 1                                                                ;
fi

shift

if [ "$1x" != "x" ]
then
  shift                                        ;
  export RAILS_ENV=$1                          ;
else
  export RAILS_ENV=development                 ;
  export DISABLE_DATABASE_ENVIRONMENT_CHECK=1  ;
fi

bundle exec bundle exec rake db:create
bundle exec bundle exec rake db:migrate
bundle exec bundle exec rake db:seed
rails db:fixtures:load FIXTURES=users_prod
sudo ORGANIZATION=${DBNAME} DBNAME=${DBNAME} bundle exec rails runner tools/populate_templates.rb
