#!/bin/sh

import_database() {
  filename=`ls /tmp/transfer/${DBNAME}_*.bak`

  if [ "$RAILS_ENV" == "development" ] -a [ "$DBNAME" == "pact_awc" ]
  then
    psql --username=admin tool < ${filename}
  fi

  psql --username=admin ${DBNAME} < ${filename}
}

if [ "$1x" != "x" ]
then
  shift                                        ;
  export RAILS_ENV=$1                          ;
else
  export RAILS_ENV=development                 ;
  export DISABLE_DATABASE_ENVIRONMENT_CHECK=1  ;
fi

rm -rf /tmp/transfer
mkdir /tmp/transfer
cd /tmp/transfer

scp paul@pact.faaconsultants.com:transfer_data.gz .
tar xvf transfer_data.gz

if [ "$RAILS_ENV" == "development" ]
then
  export DBNAME='tool' ; import_database
else
  export DBNAME='pact_awc' ; import_database
fi

export DBNAME='patmos' ;   import_database
export DBNAME='cies' ;     import_database
export DBNAME='aircomm' ;  import_database
export DBNAME='enviro' ;   import_database
