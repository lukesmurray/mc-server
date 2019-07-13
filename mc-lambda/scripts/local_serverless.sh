#!/bin/bash

set -ex

cd "${0%/*}/.."

sls wsgi serve
