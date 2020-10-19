# eid-hermes Interface Specification

## Introduction

This document defines the PCIe device interface for the eid-hermes
eBPF accelerator device.

## Overall BAR Layout

The eid-hermes PF BAR layout follows that of the shell of the generic
[AWS F1 FPGA][1] with some minor modifications.

```
eid-hermes PF
   |------- BAR0  
   |         * 32-bit BAR, non-prefetchable
   |         * 32MiB (0 to 0x1FF-FFFF)
   |         * eid-hermes device registers  
   |------- BAR2
   |         * 64-bit BAR, prefetchable
   |         * 64KiB (0 to 0xFFFF)
   |         * eid-hermes XDMA block
   |------- BAR4
             * 64-bit BAR, prefetchable
             * Size is TBD
             * Maps the exposed memory on eid-hermes
```
## BAR0 Layout

BAR0 in an eid-hermes device contains the eid-hermes device registers
which advertise a range of relevant capabilities to the host. These
registers are defined in the table below.

|Offset  | Length | Name    | Mode | Value | Description            |
|--------|--------|---------|------|-------|------------------------|
| 0x00   | 4      | EHVER   | RO   | 1     | Interface version      |
| 0x04   | 4      | EHTS    | RO   | NA    | Timestamp (seconds since epoch) |
| 0x08   | 1      | EHENG   | RO   | NA    | Number of eBPF Engines |
| 0x09   | 1      | EHPSLOT | RO   | NA    | Number of program slots   |
| 0x0A   | 1      | EHDSLOT | RO   | NA    | Number of data slots |
| 0x0C   | 4      | EHPSOFF | RO   | NA    | Base address in BAR4 of eBPF program slots |
| 0x10   | 4      | EHPSSZE | RO   | NA    | Size of a single program slot |
| 0x14   | 4      | EHDSOFF | RO   | NA    | Base address in BAR4 of eBPF data slots |
| 0x18   | 4      | EHDSSZE | RO   | NA    | Size of a single data slot |

## BAR2 Layout

The layout of BAR2 follows that of the XDMA IP provided by Xilinx and
which can be found [here][2] (however note that in this document it
refers to BAR1 but we use it in BAR2). This BAR can be used to move
data from host memory into the eBPF program slots and eBPF data slots
prior to executing an eBPF program. It is expected that this project
will develop a Linux kernel driver to manage this.

## BAR4 Layout

The layout of BAR4 is defined in the table in the BAR0 Layout section
above. It consists of eBPF program slots followed by eBPF data
slots. Note that it is advisable that BAR4 only be written via DMA
commands issued by the host driver. The only exception to this would
be p2pdma from other devices which should only target data slots (not
program slots).

[1]: https://github.com/aws/aws-fpga/blob/master/hdk/docs/AWS_Fpga_Pcie_Memory_Map.md
[2]: https://www.xilinx.com/support/documentation/ip_documentation/xdma/v4_1/pg195-pcie-dma.pdf
