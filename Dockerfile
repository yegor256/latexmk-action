# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

FROM ubuntu:24.04

LABEL "repository"="https://github.com/yegor256/latexmk-action"
LABEL "maintainer"="Yegor Bugayenko"
LABEL "version"="0.0.0"

WORKDIR /action

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

RUN apt-get -y -q update \
  && apt-get -y install --no-install-recommends \
    wget=* \
    perl=* \
    zip=* unzip=* \
    inkscape=* \
    imagemagick=* \
    make=* \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ENV TEXLIVE_YEAR=2024
ENV TEXLIVE_INSTALL_ENV_NOCHECK=true
ENV PATH=${PATH}:/usr/local/texlive/${TEXLIVE_YEAR}/bin/latest
# hadolint ignore=DL3003
RUN wget -q --no-check-certificate http://mirror.ctan.org/systems/texlive/tlnet/install-tl.zip \
  && unzip -qq install-tl.zip -d install-tl \
  && cd install-tl/install-tl-* \
  && echo "selected_scheme scheme-full" > p \
  && perl ./install-tl --profile=p \
  && ln -s "$(ls /usr/local/texlive/${TEXLIVE_YEAR}/bin/)" "/usr/local/texlive/${TEXLIVE_YEAR}/bin/latest" \
  && cd /action && rm -rf install-tl* \
  && echo "export PATH=\${PATH}:/usr/local/texlive/${TEXLIVE_YEAR}/bin/latest" >> /root/.profile \
  && tlmgr init-usertree \
  && tlmgr install texliveonfly collection-latex l3kernel l3packages \
  && pdflatex --version \
  && bash -c '[[ "$(pdflatex --version)" =~ "2.6" ]]' \
  && tlmgr install latexmk \
  && bash -c 'latexmk --version'

RUN tlmgr option repository ctan \
  && tlmgr --verify-repo=none update --self \
  && tlmgr --verify-repo=none install biber

COPY entry.sh ./

ENTRYPOINT ["/bin/bash", "--login", "/action/entry.sh"]
