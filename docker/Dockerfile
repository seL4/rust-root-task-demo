#
# Copyright 2023, Colias Group, LLC
#
# SPDX-License-Identifier: BSD-2-Clause
#

FROM trustworthysystems/sel4

RUN apt-get update -q && apt-get install -y --no-install-recommends \
    sudo man vim \
    bash-completion \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSf https://sh.rustup.rs | \
        bash -s -- -y --no-modify-path --default-toolchain none

ENV PATH=/root/.cargo/bin:$PATH

RUN mkdir /deps

WORKDIR /deps

RUN set -eux; \
    git clone \
        https://github.com/seL4/seL4.git \
        --config advice.detachedHead=false; \
    cd seL4; \
    git checkout a58480425c5b4c7a3d5000c797f083bc7d5fd532;

RUN set -eux; \
    cd seL4; \
    cmake \
        -DCROSS_COMPILER_PREFIX=aarch64-linux-gnu- \
        -DCMAKE_INSTALL_PREFIX=install \
        -DKernelPlatform=qemu-arm-virt \
        -DKernelArmHypervisorSupport=ON \
        -DKernelVerificationBuild=OFF \
        -DARM_CPU=cortex-a57 \
        -G Ninja \
        -S . \
        -B build; \
    ninja -C build all; \
    ninja -C build install;

ENV SEL4_INSTALL_DIR=/deps/seL4/install

RUN set -eux; \
    export RUSTUP_TOOLCHAIN=nightly-2024-03-09; \
    rustup component add rust-src; \
    url="https://github.com/seL4/rust-sel4"; \
    rev="a20aab14c0533d3145a2db75020e60151ce9b78f"; \
    remote_options="--git $url --rev $rev"; \
    CC=aarch64-linux-gnu-gcc \
    SEL4_PREFIX=$SEL4_INSTALL_DIR \
        cargo install \
            -Z build-std=core,compiler_builtins \
            -Z build-std-features=compiler-builtins-mem \
            --target aarch64-unknown-none \
            --root . \
            $remote_options \
            sel4-kernel-loader; \
    cargo install \
        --root . \
        $remote_options \
        sel4-kernel-loader-add-payload;

ARG UID
ARG GID

RUN set -eux; \
    if ! getent group $GID; then \
        groupadd -g $GID x; \
    fi; \
    if ! getent passwd $UID; then \
        useradd -u $UID -g $GID -G sudo -m -p x x; \
    fi;

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers # for convenience

USER $UID:$GID

# This time, for the non-root user
RUN curl -sSf https://sh.rustup.rs | \
        bash -s -- -y --no-modify-path --default-toolchain none

ENV PATH=/home/x/.cargo/bin:$PATH

WORKDIR /work
