#!/bin/sh
set -x
set -e

cd ${GITHUB_WORKSPACE}
cd ${INPUT_PATH}

rm -rf /usr/bin/pdflatex
pdflatex -version

tlmgr init-usertree || echo 'already setup'
tlmgr --verify-repo=none update --self
for p in ${INPUT_PACKAGES}; do
    tlmgr --verify-repo=none install ${p}
done

make
