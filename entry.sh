#!/bin/sh
set -x
set -e

cd ${GITHUB_WORKSPACE}
cd ${INPUT_PATH}

rm -rf /usr/bin/pdflatex
pdflatex -version

tlmgr init-usertree
tlmgr update --self
for p in ${INPUT_PACKAGES}; do
    tlmgr install ${p}
done

make
