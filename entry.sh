#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -ex -o pipefail

cd "${GITHUB_WORKSPACE-/w}" || exit 1

read -r -a packages <<< "${INPUT_PACKAGES}"
if [ -n "${INPUT_DEPENDS}" ]; then
  while IFS= read -r p; do
    packages+=( "${p}" )
  done < <( cut -d' ' -f2 "${INPUT_DEPENDS}" | uniq )
fi

if [ ! "${#packages[@]}" -eq 0 ]; then
  tlmgr --verify-repo=none update --self
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
