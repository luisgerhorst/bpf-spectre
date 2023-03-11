# Raw Benchmark Data Archives

Archive all `TESTRUN_DATA` using `make -j $(getconf _NPROCESSORS_ONLN) all`.

Unpack the archives into `TESTRUN_DATA` manually to run the eval scripts on them. Only keep valid archives when changing the associated scripts. To reproduce a specific evaluation result, check out a git revision of the repo where the data is present, unpack the archive and run `make -C eval all`.
