# eid-hermes Commands

## Introduction

This document defines the commands that are available for interacting with a
Hermes device. It includes the list of available commands and the request and
response formats.

Note that there are two types of command interfaces:
- between user and driver
- between host and device

Some commands are defined for both interfaces and have the same specification.
Other commands (those that involve memory transfer) are defined only for the
user <-> driver interface and are marked as such in the rest of this document.
These commands are converted by the Hermes driver to the use the [XDMA
specification][1] for the host <-> device interface.

## Sample Execution

The following diagram exemplifies a possible execution flow for Hermes. `*`
edges denote commands that use the [XDMA specification][1] for the host <->
device interface.

The user first send sends a `Request Slot` command to the Hermes driver to
reserve space for a program, which forwards it to the device using the same
specification. Then, the user sends the `Write to Slot` command to the driver,
which converts it into an XDMA command and sends it to the device. This is
repeated for the data slot.

We can then execute the program using the `Run Program` command, which has the
same specification for both interfaces. After its completion, the user may read
back the result with the `Read Slot` command (which uses XDMA for host <->
device). If there is more data to be processed, we can repeat the last
commands, reusing the data slot.

Finally, the user releases the used program/data slots.

```
+--------------+     *****************     +--------------+     *****************
| Request slot |     * Write to Slot *     | Request slot |     * Write to Slot *
|   (program)  | --> *   (program)   * --> |    (data)    | --> *    (data)     *<--+
|              |     *               *     |              |     *               *   |
| Opcode: 0x00 |     * Opcode: 0x10  *     | Opcode: 0x00 |     * Opcode: 0x10  *   |
+--------------+     *****************     +--------------+     *****************   |
                                                                        |           |
                                                                        v           |
+--------------+     +--------------+      ****************     +--------------+    |
| Release slot |     | Release slot |      *   Read Slot  *     | Run program  |    |
|  (program)   | <-- |    (data)    | <--  *    (data)    * <-- |              |    |
|              |     |              |      *              *     | Opcode: 0x80 |    |
| Opcode: 0x01 |     | Opcode: 0x01 |      * Opcode: 0x11 *     +--------------+    |
+--------------+     +--------------+      ****************                         |
                                                   |                                |
                                                   +--------------------------------+
```

## Command Format

Command Requests are 32 bytes long and follow the format of Table 1. Command
Responses are 16 bytes long and follow the format of Table 2. Some parts of
Requests and Responses are command-specific and are described below.

| Bytes | Description                              |
|-------|------------------------------------------|
| 00    | Opcode: defines which command to execute |
| 01    | Reserved                                 |
| 03:02 | Command Identifier: The hermes device will copy this value into the corresponding Command Response |
| 07:04 | Reserved                                 |
| 31:08 | Command Specific                         |

**Table 1: Command Request format**

| Bytes | Description        |
|-------|--------------------|
| 01:00 | Command Identifier |
| 02    | Status             |
| 07:03 | Reserved           |
| 15:08 | Command Specific   |

**Table 2: Command Response format**

The following `Status` of Command Responses are defined:

| Status | Description          |
|--------|----------------------|
| 0x00   | Success              |
| 0x01   | Not enough space     |
| 0x02   | Invalid Program Slot |
| 0x03   | Invalid Data Slot    |
| 0x04   | Invalid Slot Type    |
| 0x05   | Invalid Address      |
| 0x06   | Invalid Opcode       |
| 0x07   | eBPF error           |
| 0xFF   | Other error          |

**Table 3: Status**

## List of Commands

The following commands are defined for Hermes devices:

| Opcode | Command        | Defined for user <-> driver | Defined for host <-> device |
|--------|----------------|-----------------------------|-----------------------------|
| 0x00   | Request Slot   | Y                           | Y                           |
| 0x01   | Release Slot   | Y                           | Y                           |
| 0x10   | Write to Slot  | Y                           | N (uses XDMA spec)          |
| 0x11   | Read from Slot | Y                           | N (uses XDMA spec)          |
| 0x80   | Run Program    | Y                           | Y                           |

**Table 4: List of commands**

### Request Slots (Opcode 0x00)

This command can be used to reserve a program or data slot on the device. It is
defined for both interfaces.

| Bytes | Description                           |
|-------|---------------------------------------|
| 08    | Slot type (0x00: program, 0x01: data) |

**Table 5: Request Slots Command Request**

| Bytes | Description                                          |
|-------|------------------------------------------------------|
| 08    | ID of allocated slot. Only valid when Status is 0x00 |

**Table 6: Request Slots Command Response**

This command may return the following status:

| Status | Description                            |
|--------|----------------------------------------|
| 0x00   | Success                                |
| 0x01   | All slots of requested type are in use |

**Table 7: Request Slots status codes**

### Release Slots (Opcode 0x01)

This command can be used to release a program or data slot on the device. It is
defined for both interfaces.

It is invalid to release a slot that is not allocated.

| Bytes | Description                           |
|-------|---------------------------------------|
| 08    | Slot type (0x00: program, 0x01: data) |
| 09    | Slot ID                               |

**Table 8: Release Slots Command Request**

| Bytes | Description                |
|-------|----------------------------|

(no command-specific bytes used)

**Table 9: Release Slots Command Response**

This command may return the following status:

| Status | Description                                                |
|--------|------------------------------------------------------------|
| 0x00   | Success                                                    |
| 0x02   | Requested program slot does not exist or is not allocated  |
| 0x03   | Requested data slot does not exist or is not allocated     |

**Table 10: Release Slots status codes**

### Write to Slot (Opcode 0x10)

This command can be used to write to a program or data slot. The slot must have
been previously requested with opcode 0x00 or this will fail. It is only
defined for the user <-> driver interface.

This command does not guarantee that all bytes will be transferred. The number
of actual bytes transferred is reported on the Command Response.

| Bytes | Description                               |
|-------|-------------------------------------------|
| 08    | Slot type (0x00: program, 0x01: data)     |
| 09    | Slot ID                                   |
| 11:10 | Reserved                                  |
| 19:12 | Source Addr: the host address to transfer |
| 23:20 | Data Length (in bytes)                    |

**Table 11: Write to Slot Command Request**

| Bytes | Description                                             |
|-------|---------------------------------------------------------|
| 11:08 | Number of bytes written. Only valid when Status is 0x00 |

**Table 12: Write to Slot Command Response**

| Status | Description                                                    |
|--------|----------------------------------------------------------------|
| 0x00   | Success. Does not guarantee that all data has been transferred |
| 0x01   | DMA size is greater than slot size                             |
| 0x02   | Requested program slot does not exist or is not allocated      |
| 0x03   | Requested data slot does not exist or is not allocated         |
| 0x04   | Invalid slot type                                              |
| 0x05   | Invalid source address                                         |

**Table 13: Write to Slot status codes**

### Read from Slot (Opcode 0x11)

This command can be used to read from a slot. The slot must have been
previously requested with opcode 0x00 or this will fail. It is only defined for
the user <-> driver interface.

This command does not guarantee that all bytes will be transferred. The number
of actual bytes transferred is reported on the Command Response.

| Bytes | Description                                                                   |
|-------|-------------------------------------------------------------------------------|
| 08    | Slot type (0x00: program, 0x01: data)                                         |
| 09    | Slot ID                                                                       |
| 11:10 | Reserved                                                                      |
| 19:12 | Destination Addr: a pre-allocated host buffer where data should be written to |
| 23:20 | Data Length (in bytes)                                                        |

**Table 14: Read to Slot Command Request**

| Bytes | Description                                             |
|-------|---------------------------------------------------------|
| 11:08 | Number of bytes read. Only valid when Status is 0x00    |

**Table 15: Read from Slot Command Response**

| Status | Description                                                    |
|--------|----------------------------------------------------------------|
| 0x00   | Success. Does not guarantee that all data has been transferred |
| 0x01   | DMA size is greater than slot size                             |
| 0x02   | Requested program slot does not exist or is not allocated      |
| 0x03   | Requested data slot does not exist or is not allocated         |
| 0x04   | Invalid slot type                                              |
| 0x05   | Invalid destination address                                    |

**Table 16: Read from Slot status codes**

### Run Program (Opcode 0x80)

This command executes a pre-loaded eBPF program against a pre-loaded data slot.
It is defined for both interfaces.

| Bytes | Description     |
|-------|-----------------|
| 08    | Program Slot ID |
| 09    | Data Slot ID    |

**Table 18: Run Program Command Request**

| Bytes | Description                                                        |
|-------|--------------------------------------------------------------------|
| 11:08 | eBPF return code. Only valid when Status is 0x00 or Status is 0x05 |

**Table 18: Run Program Command Response**

| Status | Description                                                           |
|--------|-----------------------------------------------------------------------|
| 0x00   | Success. Command Resposne bytes 11:08 is the value of eBPF register 0 |
| 0x02   | Requested program slot does not exist or is not allocated             |
| 0x03   | Requested data slot does not exist or is not allocated                |
| 0x05   | An error was encountered during eBPF execution. Command Response bytes 11:08 is platform-specific. On QEMU, this corresponds to the error returned by ubpf_load() or ubpf_exec(). For the FPGA, it is TBD. |

**Table 19: Run Program Slot status codes**

[1]: https://www.xilinx.com/support/documentation/ip_documentation/xdma/v4_1/pg195-pcie-dma.pdf
