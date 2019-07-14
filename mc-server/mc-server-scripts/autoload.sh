#!/bin/bash
# this script automatically loads the contents of the s3 bucket into
# the minecraft server folder

set -ex

echo "loading s3 bucket name into MC_AUTO_BUCKET"
. /app/s3_bucket_name.txt

echo "syncing bucket/mc-auto-backups to minecraft server"
aws s3 sync s3://"$MC_AUTO_BUCKET"/mc-auto-backups /minecraft-server

