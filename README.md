<!--
     Copyright 2023, Colias Group, LLC

     SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Simple root task demo for the [seL4 crates](https://github.com/seL4/rust-sel4)

This repository demonstrates the use of the [seL4 crates](https://github.com/seL4/rust-sel4) to
construct a simple system.

See comments in the files in this repository, especially [./Makefile](./Makefile), for
documentation.

### Quick start

The only requirements for getting started are Git, Make, and Docker.

First, clone this respository:

```
git clone https://github.com/seL4/rust-root-task-demo.git
cd rust-root-task-demo
```

Next, build, run, and enter a Docker container for development:

```
make -C docker/ run && make -C docker/ exec
```

Finally, inside the container, build and emulate a simple seL4-based system with a root task written
in Rust:

```
make run
```
