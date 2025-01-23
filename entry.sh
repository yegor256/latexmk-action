#!/bin/bash
# MIT License
#
# Copyright (c) 2021-2025 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set -ex
set -o pipefail

cd "${GITHUB_WORKSPACE-/w}" || exit 1

tlmgr option repository ctan
tlmgr --verify-repo=none update --self

read -r -a packages <<< "${INPUT_PACKAGES}"
if [ -n "${INPUT_DEPENDS}" ]; then
  while IFS= read -r p; do
    packages+=( "${p}" )
  done < <( cut -d' ' -f2 "${INPUT_DEPENDS}" | uniq )
fi

if [ ! "${#packages[@]}" -eq 0 ]; then
  tlmgr --verify-repo=none install "${packages[@]}"
  attempts=0
  while true; do
    ((++attempts))
    if tlmgr --verify-repo=none --no-auto-remove update "${packages[@]}"; then
      break
    fi
    if [ "${attempts}" -gt 3 ]; then
      echo "After ${attempts} attempts we failed to install packages, sorry :("
      exit 1
    fi
    sleep "${attempts}"
  done
  fmtutil-sys --all
fi

cd "${INPUT_PATH-.}" || exit 1
ls -al

echo "latexmk-action 0.0.0"

read -r -a opts <<< "${INPUT_OPTS}"
${INPUT_CMD} "${opts[@]}"
