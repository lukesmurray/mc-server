#!/bin/bash

set -ex

cd "${0%/*}/.."

serverless logs -f app
