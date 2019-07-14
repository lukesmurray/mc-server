#!/bin/bash
# Get the url of the serverless application

set -e

cd mc-lambda

echo "getting url"
sls info | grep "endpoints:" -A 1 | tail -n 1 | cut -d '-' -f '2-' | xargs