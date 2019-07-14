#!/bin/bash
# this script backs up the content of the server to the s3 bucket

set -ex

echo "loading s3 bucket name into MC_AUTO_BUCKET"
. /app/s3_bucket_name.txt

echo "syncing minecraft server to bucket/mc-auto-backups"
aws s3 sync /minecraft-server s3://"$MC_AUTO_BUCKET"/mc-auto-backups
