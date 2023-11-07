#
# Copyright 2023, Colias Group, LLC
#
# SPDX-License-Identifier: BSD-2-Clause
#

BUILD ?= build

build_dir := $(BUILD)

sel4_prefix := $(SEL4_INSTALL_DIR)

# Kernel loader binary artifacts provided by Docker container:
# - `sel4-kernel-loader`: The loader binary, which expects to have a payload appended later via
#   binary patch.
# - `sel4-kernel-loader-add-payload`: CLI which appends a payload to the loader.
loader_artifacts_dir := /deps/bin
loader := $(loader_artifacts_dir)/sel4-kernel-loader
loader_cli := $(loader_artifacts_dir)/sel4-kernel-loader-add-payload

.PHONY: none
none:

.PHONY: clean
clean:
	rm -rf $(build_dir)

app_crate := example
app := $(build_dir)/$(app_crate).elf
app_intermediate := $(build_dir)/$(app_crate).intermediate

$(app): $(app_intermediate)

# SEL4_TARGET_PREFIX is used by build.rs scripts of various rust-sel4 crates to locate seL4
# configuration and libsel4 headers.
.INTERMDIATE: $(app_intermediate)
$(app_intermediate):
	SEL4_PREFIX=$(sel4_prefix) \
		cargo build \
			-Z build-std=core,alloc,compiler_builtins \
			-Z build-std-features=compiler-builtins-mem \
			--target aarch64-sel4 \
			--target-dir $(abspath $(build_dir)/target) \
			--out-dir $(build_dir) \
			-p $(app_crate)

image := $(build_dir)/image.elf

# Append the payload to the loader using the loader CLI
$(image): $(app) $(loader) $(loader_cli)
	$(loader_cli) \
		--loader $(loader) \
		--sel4-prefix $(sel4_prefix) \
		--app $(app) \
		-o $@

qemu_cmd := \
	qemu-system-aarch64 \
		-machine virt,virtualization=on \
		-cpu cortex-a57 -smp 2 -m 1024 \
		-nographic -serial mon:stdio \
		-kernel $(image)

.PHONY: run
run: $(image)
	$(qemu_cmd)

.PHONY: test
test: test.py $(image)
	python3 $< $(qemu_cmd)
