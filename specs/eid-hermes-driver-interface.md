# eid-hermes Driver Interface

## Introduction

This document defines the interface exposed by the Hermes [kernel driver][1]
provided in this repository. For the host <-> device interface, see [here][2].

## Device File

For every Hermes device in the system, the driver creates a `/dev/hermesX`
device, which can be used by an userspace program to interact with the device.

## Syscalls

The `/dev/hermesX` device file supports the `open`, `close`, `ioctl`, `write`
`read` and `fsync` syscalls.

Programs can be sent to the device using an `ioctl`: the request number and the
pointer structure are defined [here][3]. A program slot is automatically
allocated upon the first `ioctl` and reused for subsequent `ioctl`s.

Data can be written/read from the device using the `write`/`read` syscalls. A
data slot is automatically allocated upon the first `write` and reused for
subsequent `write`s/`read`s.

Programs can be executed by either passing the `RWF_SYNC` flag to a `pwritev2`
syscall (in which case the driver will first write the program then immediately
execute the program) or by using the `fsync` syscall. These syscalls expect the
program to exit with 0 and will fail with errno `ENOEXEC` if that does not
happen. Programmers that need to know the eBPF return code must write their
eBPF programs so that the return code is written into a known offset of the
data slot, which can then be `read`.

## Example

An example userspace program that uses the kernel driver is available
[here][4].

## Limitations

For each file descriptor, no more than one program slot and one data slot will
be allocated. Users that need to run multiple programs/want to run them in
parallel should open `/dev/hermesX` multiple times. Users that need to pass the
unmodified output of program A to the input of program B should create a single
program with A+B.


[1]: ../src/driver/
[2]: eid-hermes-commands-format.md
[3]: ../src/include/hermes_uapi.h
[4]: ../examples/simple.c
