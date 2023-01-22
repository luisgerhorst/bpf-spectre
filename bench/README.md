# Benchmark Runner

## Usage

For some `$name.suite.{py,yaml}`, run:

``` sh
./run.sh --suite $name
```

By default, the results go into `../eval/.raw`. See `./run.sh --help`.

Checks out repos and compiles parts of `../system`. Connects to remote SuTs.
