#!/bin/sh
export DISABLE_DATABASE_ENVIRONMENT_CHECK=1

migrate_database() {
  bundle exec rake db:migrate
}

if [ "$1x" != "x" ]
then
  shift                                        ;
  export RAILS_ENV=$1                          ;
else
  export RAILS_ENV=development                 ;
fi

if [ "$RAILS_ENV" == "development" ]
then
  export DBNAME='tool'     ; migrate_database
  export DBNAME='pact_awc' ; migrate_database
else
  export DBNAME='pact_awc' ; migrate_database
fi

export DBNAME='patmos'     ; migrate_database
export DBNAME='cies'       ; migrate_database
export DBNAME='aircomm'    ; migrate_database
export DBNAME='enviro'     ; migrate_database
