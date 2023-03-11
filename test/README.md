# Benchmark/Test Runner

## Usage

For some `$name.suite.{py,yaml}`, run:

``` sh
./run.sh --suite $name
```

By default, the results go into `$TESTRUN_DATA`. See `./run.sh --help`.

Compiles parts of `../src`. Connects to remote SuTs.
