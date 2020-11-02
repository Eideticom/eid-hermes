# eid-hermes Theory of Operation

## Introduction

This document outlines the theory of operation for the eid-hermes PCIe
eBPF-based accelerator that will be made available in both QEMU model
and AWS F1 FPGA instance form.

As with many PCIe-based accelerators this theory of operation takes
the form of interactions between a host computer and the PCIe device
via a PCIe interface exposed on the device. A combination of MMIO
operations and DMA/command descriptors are used to move data between
host memory and the device and to request that the device perform
certain data or admin operations.

## Types of Commands

Commands are defined in another [document][1], but they can be
divided into DMA commands and non-DMA commands. The former are
translated by the Hermes driver into [XDMA commands][2], which
exercises BAR2 registers. The latter are executed as follows:

1. User sends command request (32 bytes) to a Hermes driver
2. Driver copies command request to BAR0 registers.
3. Driver writes to BAR0 register to start command execution.
4. Upon completion, device writes command response (16 bytes) to BAR0
registers and raises interrupt.
5. Driver reads command response and return it to user.

## Overview

1. Host uses a driver to discover the capabilities of the eid-hermes
device via the capabilities advertised in BAR0.

2. Host uses a driver to exercise BAR2 to initiate DMAs on the device
that populate eBPF program slots and eBPF data slots from host
memory. Alternatively [p2pdma][3] could be used to populate eBPF
program memory from a remote device. Note the device memory addresses
used in these DMAs can be obtained via step 1.

3. Host initiates the execution of an eBPF program loaded into a
specific slot against input data located in a specific program
memory. The eBPF program may reference memory via offsets into the
eBPF program memory. The eBPF program may populate parts of the eBPF
program memory with both intermediate data *and* output data. Once the
eBPF program has completed the device will inform the host via an
interrupt. The host can also choose to poll the relevant BAR0 register
to check for command completion.

4. Host uses a driver to exercise BAR2 to initate DMAs on the device
that take the output data from the relevant eBPF data slot and move it
to host memory.

[1]: https://github.com/Eideticom/eid-hermes/blob/master/specs/eid-hermes-commands-format.md
[2]: https://www.xilinx.com/support/documentation/ip_documentation/xdma/v4_1/pg195-pcie-dma.pdf
[3]: https://www.kernel.org/doc/html/latest/driver-api/pci/p2pdma.html
