FROM trustworthysystems/sel4

RUN apt-get update -q && apt-get install -y --no-install-recommends \
    wget \
    sudo man vim \
    bash-completion \
    && rm -rf /var/lib/apt/lists/*

# Derived from:
# https://hub.docker.com/r/rustlang/rust/dockerfile

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH

RUN set -eux; \
    url="https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init"; \
    wget "$url"; \
    chmod +x rustup-init; \
    ./rustup-init -y --no-modify-path --default-toolchain nightly; \
    rm rustup-init; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME; \
    rustup --version; \
    cargo --version; \
    rustc --version;

ENV CARGO_HOME=

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
    export RUSTUP_TOOLCHAIN=nightly-2023-05-03; \
    rustup component add rust-src; \
    url="https://github.com/coliasgroup/rust-seL4"; \
    rev="a453a30908f6302e38650e2745a9f1f2c29ef505"; \
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

WORKDIR /work
