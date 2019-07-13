#!/bin/bash
# This file destroys the server and the lambda

set -ex

echo "destroying server"
terraform destroy --auto-approve mc-server

echo "destroying lambda"
./mc-lambda/scripts/destroy_serverless.sh
