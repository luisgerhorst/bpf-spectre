# Operating System Evaluator

Clone with `--recursive`. Install [Git LFS](https://git-lfs.com/) for raw data archives and prebuilt plots.

## Features

-   Different programming languages for plotting.
-   Flexible benchmarks (microbenchmarks, real-world client/server benchmarks).
-   Flexible system under test (e.g., VM or physical machine), compare different SuTs.
-   Fully automatic setup of the SuT with the software to evaluate (boot kernel, &#x2026;).
-   Plot available benchmark results while the benchmark suite is still running.
-   ETA for long benchmark runs.
-   Parallel plotting.
-   Separate running benchmarks and processing (e.g., plotting) their results.
-   Analyse [tidy](https://vita.had.co.nz/papers/tidy-data.pdf) data but still collect a lot of (dirty) data during the benchmark, decide later what to actually process.
-   Randomize benchmark execution order to avoid false conclusions and encourage reproducibility.
-   Archive/share large raw benchmark results and prebuilt plots with Git LFS to avoid exceeding Git limits.
-   Retry benchmarks when running a suite to not have the whole suite fail if
    there's a network problem. If you ever have to, you can even run the suite
    on your laptop, suspend it, and continue running the suite when you want to
    continue.

## Quick Start

Install all dependencies, see `make install-deps` in the subdirectories.

Boot the VM (system under test):

    make -C src qemu

This might take some time the first time as it builds the kernel and installs
Debian. Alternatively boot the physical target machine (with any kernel) for the
non-demo benchmark suites.

In another terminal on the control system (connects to the SuTs, can be the same as the development system):

    ./test/run.sh --suite idle

The latter also installs and sets up all benchmark dependencies (e.g., boot the kernel) on the target SuT.

Plot and open the results on the development system:

    make -C data -k -j $(getconf _NPROCESSORS_ONLN) all
    open data/plots/*-idle.pdf

To set up the physical SuTs, see `src`.

## Data Flow

    src/{linux, *}
      -- make -C src --> System under Test (Target)
      -- ./test/run.sh --> data/.raw/*/
      -- ./data/tidy.py --> data/.tidy/*.tsv.gz
      -- ./data/plot-*  --> data/plots/*.pdf

This does not mean that the above commands should be called directly.

# License

    SPDX-License-Identifier: GPL-2.0+

This is the default for this repo and all submodules unless explicitly set to something else (e.g., in external submodules).
