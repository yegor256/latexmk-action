# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

FROM yegor256/latex:0.0.1

LABEL "repository"="https://github.com/yegor256/latexmk-action"
LABEL "maintainer"="Yegor Bugayenko"
LABEL "version"="0.16.1"

WORKDIR /action

COPY entry.sh ./

ENTRYPOINT ["/action/entry.sh"]
