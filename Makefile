build_dir := build

.PHONY: none
none:

.PHONY: clean
clean:
	rm -rf $(build_dir)

# ## Kernel
#
# Install the seL4 kernel and libsel4 locally. There is nothing specific to rust-seL4 in this
# section.

kernel_source_dir := seL4
kernel_build_dir := $(build_dir)/kernel/build
kernel_install_dir := $(build_dir)/kernel/install
kernel_settings := kernel-settings.cmake
cross_compiler_prefix := aarch64-linux-gnu-

.PHONY: configure-kernel
configure-kernel:
	cmake \
		-DCROSS_COMPILER_PREFIX=$(cross_compiler_prefix) \
		-DCMAKE_TOOLCHAIN_FILE=gcc.cmake \
		-DCMAKE_INSTALL_PREFIX=$(kernel_install_dir) \
		-C $(kernel_settings) \
		-G Ninja \
		-S $(kernel_source_dir) \
		-B $(kernel_build_dir)

.PHONY: build-kernel
build-kernel: configure-kernel
	ninja -C $(kernel_build_dir) all

.PHONY: install-kernel
install-kernel: build-kernel
	ninja -C $(kernel_build_dir) install

# ## Common Rust definitions

rust_target_path := support/targets
rust_sel4_target := aarch64-sel4
rust_bare_metal_target := aarch64-unknown-none
target_dir := $(build_dir)/target

# SEL4_TARGET_PREFIX is used by build.rs scripts of various rust-seL4 crates to locate seL4
# configuration and libsel4 headers.
common_env := \
	RUST_TARGET_PATH=$(abspath $(rust_target_path)) \
	SEL4_PREFIX=$(abspath $(kernel_install_dir)) \

common_options := \
	--target-dir $(abspath $(target_dir))

build_std_options := \
	-Z build-std=core,alloc,compiler_builtins \
	-Z build-std-features=compiler-builtins-mem

remote_options := \
	--git https://gitlab.com/coliasgroup/rust-seL4 \
	--rev 50d44e23c4035d36297a1ca5f584022e095f7077

# ## Loader
#
# - `sel4-kernel-loader`: The loader binary, which expects to have a payload appended later via
#   binary patch.
# - `sel4-kernel-loader-add-payload`: CLI which appends a payload to the loader.
#
# In this Makefile, we take the approach of using `cargo install --root <somewhere local to this
# project>` to build these `[bin]` crates.

loader_crate := sel4-kernel-loader
loader := $(build_dir)/bin/$(loader_crate)
loader_intermediate := $(build_dir)/$(loader_crate).intermediate

$(loader): $(loader_intermediate)

.INTERMDIATE: $(loader_intermediate)
$(loader_intermediate):
	$(common_env) \
	CC=$(cross_compiler_prefix)gcc \
		cargo install \
			$(common_options) \
			$(remote_options) \
			$(build_std_options) \
			--target $(rust_bare_metal_target) \
			--root $(abspath $(build_dir)) \
			--force \
			$(loader_crate)

loader_cli_crate := sel4-kernel-loader-add-payload
loader_cli := $(build_dir)/bin/$(loader_cli_crate)
loader_cli_intermediate := $(build_dir)/$(loader_cli_crate).intermediate

$(loader_cli): $(loader_cli_intermediate)

.INTERMDIATE: $(loader_cli_intermediate)
$(loader_cli_intermediate):
	cargo install \
		$(common_options) \
		$(remote_options) \
		--root $(abspath $(build_dir)) \
		--force \
		$(loader_cli_crate)

# ## Demo

app_crate := example
app := $(build_dir)/$(app_crate).elf
app_intermediate := $(build_dir)/$(app_crate).intermediate

$(app): $(app_intermediate)

.INTERMDIATE: $(app_intermediate)
$(app_intermediate):
	$(common_env) \
		cargo build \
			$(common_options) \
			$(build_std_options) \
			--target $(rust_sel4_target) \
			--out-dir $(build_dir) \
			-p $(app_crate)

image := $(build_dir)/image.elf

# Append the payload to the loader using the loader CLI
$(image): $(app) $(loader) $(loader_cli)
	$(loader_cli) \
		--loader $(loader) \
		--sel4-prefix $(kernel_install_dir) \
		--app $(app) \
		-o $@

.PHONY: run
run: $(image)
	qemu-system-aarch64 \
		-machine virt,virtualization=on \
		-cpu cortex-a57 -smp 2 -m 1024 \
		-nographic -serial mon:stdio \
		-kernel $<
