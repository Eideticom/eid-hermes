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

## Overview

1. Host uses a driver to discover the capabilities of the eid-hermes
device via the capabilities advertised in BAR0.

2. Host uses a driver to exercise BAR2 to initiate DMAs on the device
that populate eBPF program slots and eBPF data slots from host
memory. Alternatively [p2pdma][1] could be used to populate eBPF
program memory from a remote device. Note the device memory addresses
used in these DMAs can be obtained via step 1.

3. Host initiates the execution of an eBPF program loaded into a
specific slot against input data located in a specific program
memory. The eBPF program may reference memory via offsets into the
eBPF program memory. The eBPF program may populate parts of the eBPF
program memory with both intermediate data *and* output data. Once the
eBPF program has completed the device will inform the host (mechanism
for this is TBD).

4. Host uses a driver to exercise BAR2 to initate DMAs on the device
that take the output data from the relevant eBPF data slot and move it
to host memory.

[1]: https://www.kernel.org/doc/html/latest/driver-api/pci/p2pdma.html