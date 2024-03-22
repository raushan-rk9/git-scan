#!/bin/sh
count=1

while [ $count -le 3 ]
do
    rsync -archive --partial --append-verify --stats root@216.168.44.226:/mnt/drive_3/minio /volume1 --delete
    if [ "$?" = "0" ] ; then
        echo "rsync completed normally"
        exit
    else
        echo "Rsync failure. Backing off and retrying in 1 minute..."
        sleep 60
    fi

    count=$((count+1))
done