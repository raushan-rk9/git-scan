#!/bin/sh
export DISABLE_DATABASE_ENVIRONMENT_CHECK=1

remove_database() {
  bundle exec rake db:drop
  bundle exec rake db:create
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
  export DBNAME='tool'     ; remove_database
  export DBNAME='pact_awc' ; remove_database
else
  export DBNAME='pact_awc' ; remove_database
fi

export DBNAME='patmos'     ; remove_database
export DBNAME='cies'       ; remove_database
export DBNAME='aircomm'    ; remove_database
export DBNAME='enviro'     ; remove_database
