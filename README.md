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
      - uses: yegor256/latex-make-action@0.1.5
        with:
          path: foo
          packages: acmart geometry tikz
```

You should have `Makefile` in the `foo` directory of your repository.
