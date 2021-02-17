# eid-hermes Commands

## Introduction

This document defines the commands that are available for interacting with a
Hermes device. It includes the list of available commands and the request and
response formats.

Note that there are two types of command interfaces:
- between user and driver
- between host and device

This document refers to the host <-> device interface only. Driver
implementations are free to define their own interface. For the interface of
the kernel driver provided in this repository, see [here][1].

Within the host <-> device interaction, there are two types of commands: those
that involve memory transfer and those that don't. The former are handled by
the [XDMA specification][2] and follow that interface, while the latter follow
the interface defined in the rest of this document.

## Sample Execution

The following diagram exemplifies a possible execution flow for Hermes. `*`
edges denote commands that use the [XDMA specification][2].

The host first send sends a `Request Slot` command to the device to reserve
space for a program. Then, an XDMA write command can be sent to the device
containing the program bytecode. This is repeated for the data slot.

The host can then execute the program using the `Run Program` command,
specifying the program and data slots to be used. After its completion, the
host may read back the result with an XDMA Read command. If there is more data
to be processed, we can repeat the last commands, reusing the data slot.

Finally, the host releases the used program/data slots.

```
+--------------+     *****************     +--------------+     *****************
| Request slot |     *               *     | Request slot |     *               *
|   (program)  | --> *  XDMA write   * --> |    (data)    | --> *  XDMA write   *<--+
|              |     *   (program)   *     |              |     *    (data)     *   |
| Opcode: 0x00 |     *               *     | Opcode: 0x00 |     *               *   |
+--------------+     *****************     +--------------+     *****************   |
                                                                        |           |
                                                                        v           |
+--------------+     +--------------+      ****************     +--------------+    |
| Release slot |     | Release slot |      *              *     | Run program  |    |
|  (program)   | <-- |    (data)    | <--  *  XDMA read   * <-- |              |    |
|              |     |              |      *    (data)    *     | Opcode: 0x80 |    |
| Opcode: 0x01 |     | Opcode: 0x01 |      *              *     +--------------+    |
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
| 0x04   | Invalid Address      |
| 0x05   | eBPF error           |
| 0x06   | Invalid opcode       |

**Table 3: Status**

## List of Commands

The following commands are defined for Hermes devices:

| Opcode | Command        |
|--------|----------------|
| 0x00   | Request Slot   |
| 0x01   | Release Slot   |
| 0x80   | Run Program    |

**Table 4: List of commands**

### Request Slots (Opcode 0x00)

This command can be used to reserve a program or data slot on the device.

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

This command can be used to release a program or data slot on the device.

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

### Run Program (Opcode 0x80)

This command executes a pre-loaded eBPF program against a pre-loaded data slot.

| Bytes | Description     |
|-------|-----------------|
| 08    | Program Slot ID |
| 09    | Data Slot ID    |

**Table 11: Run Program Command Request**

| Bytes | Description                                                        |
|-------|--------------------------------------------------------------------|
| 15:08 | eBPF return code. Only valid when Status is 0x00 or Status is 0x05 |

**Table 12: Run Program Command Response**

| Status | Description                                                           |
|--------|-----------------------------------------------------------------------|
| 0x00   | Success. Command Response bytes 15:08 is the value of eBPF register 0 |
| 0x02   | Requested program slot does not exist or is not allocated             |
| 0x03   | Requested data slot does not exist or is not allocated                |
| 0x05   | An error was encountered during eBPF execution. Command Response bytes 15:08 is platform-specific. On QEMU, this corresponds to the error returned by ubpf_load() or ubpf_exec(). For the FPGA, it is TBD. |
| 0x06   | The Command opcode is invalid |

**Table 13: Run Program Slot status codes**

[1]: eid-hermes-driver-interface.md
[2]: https://www.xilinx.com/support/documentation/ip_documentation/xdma/v4_1/pg195-pcie-dma.pdf
