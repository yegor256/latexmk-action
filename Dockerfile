# MIT License
#
# Copyright (c) 2021-2024 Yegor Bugayenko
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
  && echo "selected_scheme scheme-minimal" > p \
  && perl ./install-tl --profile=p --repository=ftp://dante.ctan.org/tex-archive/systems/texlive/tlnet/ \
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
