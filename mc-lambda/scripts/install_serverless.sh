#!/bin/bash

set -ex

cd "${0%/*}/.."

sls plugin install -n serverless-wsgi

sls plugin install -n serverless-python-requirements
