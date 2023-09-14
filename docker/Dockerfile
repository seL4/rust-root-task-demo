FROM trustworthysystems/sel4

RUN apt-get update -q && apt-get install -y --no-install-recommends \
    wget \
    sudo man vim \
    bash-completion \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSf https://sh.rustup.rs | \
        bash -s -- -y --no-modify-path --default-toolchain none

ENV PATH=/root/.cargo/bin:$PATH

RUN mkdir /deps

WORKDIR /deps

RUN git clone https://github.com/seL4/seL4.git && \
        cd seL4 && \
        git checkout 5091e5313d6fb79b71af4ee2be85277a07e07d65

COPY kernel-settings.cmake .

RUN set -eux; \
    cd seL4; \
    cmake \
        -DCROSS_COMPILER_PREFIX=aarch64-linux-gnu- \
        -DCMAKE_TOOLCHAIN_FILE=gcc.cmake \
        -DCMAKE_INSTALL_PREFIX=install \
        -C ../kernel-settings.cmake \
        -G Ninja \
        -S . \
        -B build; \
    ninja -C build all; \
    ninja -C build install;

ENV SEL4_INSTALL_DIR=/deps/seL4/install

RUN set -eux; \
    export RUSTUP_TOOLCHAIN=nightly-2023-08-02; \
    rustup component add rust-src; \
    url="https://github.com/coliasgroup/rust-sel4"; \
    rev="4fa7fb5e15b2c132f9ce75863caf81d78f080bc3"; \
    remote_options="--git $url --rev $rev"; \
    CC=aarch64-linux-gnu-gcc \
    SEL4_PREFIX=$SEL4_INSTALL_DIR \
        cargo install \
            -Z build-std=core,alloc,compiler_builtins \
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

RUN groupadd -f -g $GID x && useradd -u $UID -g $GID -G sudo -m -p x x
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers # for convenience

USER x

# This time, for the non-root user
RUN curl -sSf https://sh.rustup.rs | \
        bash -s -- -y --no-modify-path --default-toolchain none

ENV PATH=/home/x/.cargo/bin:$PATH

WORKDIR /work
