#!/bin/sh

dump_database() {
  filename="${DATABASE}_`date +'%Y_%m_%d_%H_%m.bak'`"
  pg_dump --username=admin ${DATABASE} > $filename
}

rm *.bak

export DATABASE='pact_awc' ; dump_database
export DATABASE='patmos' ;   dump_database
export DATABASE='cies' ;     dump_database
export DATABASE='aircomm' ;  dump_database
export DATABASE='enviro' ;   dump_database

tar -czvf transfer_data.gz *.bak 