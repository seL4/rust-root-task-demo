#
# Copyright 2023, Colias Group, LLC
#
# SPDX-License-Identifier: BSD-2-Clause
#

# Basis for seL4 kernel configuration

set(ARM_CPU cortex-a57 CACHE STRING "")
set(KernelArch arm CACHE STRING "")
set(KernelArmHypervisorSupport ON CACHE BOOL "")
set(KernelMaxNumNodes 2 CACHE STRING "")
set(KernelPlatform qemu-arm-virt CACHE STRING "")
set(KernelSel4Arch aarch64 CACHE STRING "")
set(KernelVerificationBuild OFF CACHE BOOL "")
