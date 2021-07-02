To `make` your LaTeX document by GitHub Action just 
create a `.github/workflows/make.yml` file:

```yaml
name: make
on:
  push:
    branches: [ master ]
  pull_request:
    branches: [ master ]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: yegor256/latexmk-action@0.1.14
        with:
          path: foo
          packages: acmart geometry tikz
```

You should have `Makefile` in the `foo` directory of your repository.

In order to test this action, just run:

```bash
$ make test
```

This should build a new Docker image and then try to use it
in order to render a simple `test.tex` document. You need to have
[Docker](https://docs.docker.com/get-docker/) installed.