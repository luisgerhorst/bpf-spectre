# Spectector

Spectector is a tool for reasoning about information flows produced by
speculatively executed instructions. It takes as input an x64 assembly
program (in the Intel or AT&T syntax), and it automatically
detects leaks introduced by speculatively executed instructions (or
proves their absence).

In a nutshell, Spectector symbolically executes the program under analysis with
respect to a semantics that accounts for the speculative execution's effects.
During the symbolic execution, Spectector derives SMT formulae characterizing
leaks caused by speculatively executed instructions. It then relies on the Z3
SMT solver to determine the presence of possible leaks. More precisely,
Spectector automatically proves whether a program satisfies _speculative
non-interference_, a security property formalized in the [Spectector's
paper](https://spectector.github.io/papers/spectector.pdf).

Using Spectector, we detected subtle bugs in the way countermeasures
are placed by several major compilers, which may result in insecure
programs or unnecessary countermeasures. See the
[Spectector's paper](https://spectector.github.io/papers/spectector.pdf) for more information.

## Requirements

Spectector is written using the Prolog dialect supported by the
[Ciao system](https://github.com/ciao-lang/ciao), and it needs the Ciao environment
to compile. Additionally, Spectector uses the
[Z3 SMT solver](https://github.com/Z3Prover/z3) to check the
satisfiability of formulae.

We have tested Spectector with Ciao version 1.18 and Z3 version 4.8.4 on Debian
Linux (kernel 4.9.110), Arch Linux (kernel 4.19.4), Mac OSX (version 10.14), and
Windows 10 Pro (using the Windows Linux Subsystem with kernel 4.4.0).

## Build and installation

Once the Ciao system is installed, you can automatically fetch, build, and install Spectector using:

```
ciao get github.com/spectector/spectector
```

The following dependencies (including third-party code) will be
installed automatically:

1. [Concolic](https://github.com/ciao-lang/concolic) for
   SMT-enhanced symbolic reasoning and search
   (`ciao get concolic`). This will automatically install Z3.
2. [muASM translator](https://github.com/spectector/muasm_translator)
   for muASM translation from x64 assembly (`ciao get
   github.com/imdea-software/muasm_translator`)

All code will be downloaded and built under the first directory
specified in the `CIAOPATH` environment variable or `~/.ciao` by
default.

# Using Spectector

Spectector can be executed over x64 assembly programs. Additionally,
Spectector can analyze programs written in muASM, a simple assembly
language described in the [Spectector's paper](https://spectector.github.io/papers/spectector.pdf).

Spectector treats each file with extension `.s` as an x64 program
written using the AT&T syntax, each file with extension `.asm` as an
x64 program written using the Intel syntax, and each file with
extension `.muasm` as a muASM program.

Once correctly installed, Spectector can be run from the command line
as follows:

```
spectector assembly.file -c initConf --low policy
```

In the above command, `initConf` is a file containing the initial configuration
and `policy` is a file specifying the security policy:

* An initial configuration specifies the initial values for some of the
  registers and memory locations. Spectector will treat all uninitialized
  registers and memory locations as containing symbolic values. We specify the
  initial configuration as `c([Memory],[Assignments])`, where `Memory` maps
  memory locations to values and `Assignments` maps registers to values. For
  instance, `c([500=0,501=0],[rax=20, pc=START])` denotes that (1) the initial
  values of the memory locations `500` and `501` is `0`, (2) the initial value
  of the register `rax` is `20`, and (3) the initial value of the program
  counter register `pc` is the line number of the instruction labelled with `START`.

* A policy specifies which registers and memory locations are known or
  controlled by an attacker (i.e., they contain public information). The file
  `policy` contains  a list of register identifiers and memory locations
  separated by a comma. For instance, the policy `[pc, rax, 500]` states that
  the registers `pc` and `rax` and the memory location `500` contain public
  information.

See the output of `spectector -h` for more detailed instructions.

## Supported x64 instructions and other limitations

See Sections VI.C and VIII of the [Spectector's paper](https://spectector.github.io/papers/spectector.pdf) for a
description of the supported instructions and limitations.

# Useful links

1. [This](https://spectector.github.io/papers/spectector.pdf) is the research paper describing Spectector.
2. [This file](docs/compiling_from_sources.md) describes how to compile Spectector from source code.
3. [This file](docs/obtaining_assembly_programs.md) describes a few ways of obtaining assembly programs.
4. [This repository](https://github.com/spectector/spectector-benchmarks) contains the benchmarks from the Spectector's paper, and it describes how to reproduce all the results therein.
5. [This file](docs/generate_artifact_eval.md) describes how to generate Spectector's artifact evaluation distribution.

# Important

Spectector is not production ready. It's a research prototype that demonstrates
the viability of detecting speculative information flows in small assembly
programs. It cannot be used (yet!) to detect speculative leaks in large,
real-world programs.