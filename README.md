# Simple root task demo for [rust-seL4](https://github.com/coliasgroup/rust-seL4)

This repository demonstrates the use of the [rust-seL4](https://github.com/coliasgroup/rust-seL4) crates to construct a simple system.

See comments in the files in this repository, especially [./Makefile](./Makefile), for documentation.

### Quick start

The only requirements for getting started are Git, Make, and Docker.

First, clone this respository:

```
git clone https://github.com/coliasgroup/rust-seL4-root-task-demo.git
cd rust-seL4-root-task-demo
```

Next, build, run, and enter a Docker container for development:

```
make -C docker/ run && make -C docker/ exec
```

Finally, inside the container, build and emulate a simple seL4-based system with a root task written in Rust:

```
make run
```
