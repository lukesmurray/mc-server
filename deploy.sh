#!/bin/bash
# This file deploys the server and the lambda

set -ex

echo "deploying server"
terraform apply --auto-approve mc-server

echo "outputting info for lambda deploy"
terraform output -json | jq 'with_entries(.value |= .value)' > mc-lambda/config.json

echo "installing serverless plugings"
./mc-lambda/scripts/install_serverless.sh

echo "deploying lambda"
./mc-lambda/scripts/deploy_serverless.sh