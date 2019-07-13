#!/bin/bash

set -ex

cd "${0%/*}/.."

sls deploy -v