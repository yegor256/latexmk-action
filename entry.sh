#!/bin/sh
set -x
set -e

cd ${GITHUB_WORKSPACE}
cd ${INPUT_PATH}
make
