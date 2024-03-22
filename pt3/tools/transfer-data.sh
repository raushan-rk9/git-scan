#!/bin/sh
sudo docker exec -it pact_awc /app/tools/empty-databases.sh
sudo docker exec -it pactsql import-databases.sh