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

For each eBPF engine (`EHENG`), there is one set of command [request/response
registers][2] (48 bytes each, starting at offset `0x1000`) and one one-byte
control register (starting at offset `0x2000`). As noted in the [command
formats specification][3], these registers are not used for Read/Write
commands.

|Offset                  | Length | Name         | Mode | Value | Description            |
|------------------------|--------|--------------|------|-------|------------------------|
| 0x00                   | 4      | EHVER        | RO   | 1     | Interface version      |
| 0x04                   | 48     | EHBLD        | RO   | NA    | Build version (git describe) |
| 0x34                   | 1      | EHENG        | RO   | NA    | Number of eBPF Engines |
| 0x35                   | 1      | EHPSLOT      | RO   | NA    | Number of program slots |
| 0x36                   | 1      | EHDSLOT      | RO   | NA    | Number of data slots |
| 0x38                   | 4      | EHPSOFF      | RO   | NA    | Base address in BAR4 of eBPF program slots |
| 0x3C                   | 4      | EHPSSZE      | RO   | NA    | Size of a single program slot |
| 0x40                   | 4      | EHDSOFF      | RO   | NA    | Base address in BAR4 of eBPF data slots |
| 0x44                   | 4      | EHDSSZE      | RO   | NA    | Size of a single data slot |
| 0x1000                 | 32     | EHCMDREQ0    | RW   | NA    | Command Request for engine 0 |
| 0x1020                 | 16     | EHCMDRES0    | RO   | NA    | Command Response for engine 0 |
| ...                    | ...    | ...          | ...  | ...   | ... |
| 0x1000 + (EHENG-1)\*48 | 32     | EHCMDREQN-1  | RW   | NA    | Command Request for engine N-1 |
| 0x1020 + (EHENG-1)\*48 | 16     | EHCMDRESN-1  | RO   | NA    | Command Response for engine N-1 |
| 0x2000                 | 8      | EHCMDCTRL0   | RW   | NA    | Command control for request 0. See EHCMDCTRL table for details |
| ...                    | ...    | ...          | ...  | ...   | ... |
| 0x2000 + (EHENG-1)\*8  | 8      | EHCMDCTRLN-1 | RW   | NA    | Command control for request N-1. See EHCMDCTRL table for details |

#### EHCMDCTRL
| Byte | Name      | Mode | Description |
|------|-----------|------|-------------|
| 0    | EHCMDEXEC | RW   | Host writes 1 to start command. Device clears after command finishes |
| 1    | EHCMDDONE | RO   | Indicates if command has finished. Cleared by device before starting command, set when done |
| 2-7  | --        | --   | Reserved |

## BAR2 Layout

The layout of BAR2 follows that of the XDMA IP provided by Xilinx and
which can be found [here][4] (however note that in this document it
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
[2]: eid-hermes-commands-format.md#command-format
[3]: eid-hermes-commands-format.md#list-of-commands
[4]: https://www.xilinx.com/support/documentation/ip_documentation/xdma/v4_1/pg195-pcie-dma.pdf
