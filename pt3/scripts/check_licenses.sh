#!/bin/bash

if [ "$1x" = "developmentx" ]
then
    shift                               ;
    environment=development             ;
    cd /Users/paul/Work/Patmos/src/pact ;
else
    environment=production              ;
    cd /app                             ;
fi

for organization in $*
do
    RAILS_ENV=$environment bundle exec rails runner "LicenseeMailer.check_license_expired('${organization}')"
    RAILS_ENV=$environment bundle exec rails runner "LicenseeMailer.check_license_expiring('${organization}')"
done
