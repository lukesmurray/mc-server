#!/bin/bash

set -ex

cd "${0%/*}/.."

serverless remove
