# Benchmark Runner

## Usage

For some `$name.suite.{py,yaml}`, run:

``` sh
./run.sh --suite $name
```

By default, the results go into `../eval/.raw`. See `./run.sh --help`.

Checks out repos and compiles parts of `../system`. Connects to remote SuTs.

## Todos

### Benchmarks

- kernel bpf selftests?
- gen. hubble flows using https://github.com/cilium/fake
- cilium layer 7 filter benchmark https://docs.cilium.io/en/stable/policy/language/#layer-7-examples 
