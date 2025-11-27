#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -ex -o pipefail

cd "${GITHUB_WORKSPACE-/w}"

read -r -a debs <<< "${INPUT_DEBS}"
if [ ! "${#debs[@]}" -eq 0 ]; then
  sudo apt-get --fix-missing --yes update
  sudo apt-get --no-install-recommends --yes install "${debs[@]}"
  sudo apt-get clean
  sudo rm -rf /var/lib/apt/lists/*
fi

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

cd "${INPUT_PATH-.}"
ls -al

echo "latexmk-action 0.0.0"

read -r -a opts <<< "${INPUT_OPTS}"
if [ -n "${INPUT_DOCUMENT}" ]; then
  opts+=("${INPUT_DOCUMENT}")
fi

eval "${INPUT_CMD} ${opts[*]}"
