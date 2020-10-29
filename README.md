# eid-hermes: An open-source eBPF accelerator for QEMU and AWS F1 instances.

# Introduction

This is an open-source [Eideticom][1]-led project that explores how
[eBPF][2]-based accelerators can be used to offload application code
from host processors.

This repository contains the source code for an eBPF-based PCIe
accelerator design that can be run on [AWS F1 servers][3]. As such,
anyone can use this project to run said accelerators on the cloud and
develop host code (such as drivers and userspace libraries) targetting
said accelerators.

# Overview

This project consists of four main parts.

## QEMU Model

This part of the project will develop and ideally upstream a
hermes-based PCIe device model. Prior to upstream this code is hosted
in this public fork of [QEMU][4]. Some early work on such a model
results in [this RFC][5].

## AWS F1 Implementation

This part of the project implements an eid-hermes bitstream which can
run on an AWS F1 instance. This code will be contained in this repo
and will consist mostly of RTL.

## Linux Driver

This part of the project implements a Linux driver for eid-hermes and
should threfore work for both the QEMU model and the AWS F1 instance
noted above. This code *may* be hosted in this repo initially and
ideally will be upstreamed into the [Linux kernel][6].

## eBPF Userspace Library

This part of the project implements a userspace library that provides
an API whereby applications can offload part of their computation to
eBPF-capable devices like eid-hermes. Note that long term this part
may span other device types like, for example, [NVMe devices][7] and
may come under the perview of a standards body like [SNIA][8].

# Specification

The specification for eid-hermes is located in Markdown files in the
```specs``` folder. The files in that folder are as follows:

* **[eid-hermes-theory-of-operation.md][9]** - An overview of how the
    eid-hermes device interacts with the host and how a driver should
    communicate with it to get work done.

* **[eid-hermes-interface.md][10]** - The PCIe register interface to the
    eid-hermes device and the overall BAR layout.

# Dependencies and host configuration

Eid-hermes uses the [XDMA][11] kernel module for data transfer between the host
and the device. That driver needs to be patched to accept the Hermes PCI
device/vendor ID.

To facilitate installation, an [Ansible][12] playbook is provided, which also
installs some helper programs, such as [pcimem][13].

To run it, first install ansible then run:

```
cd ansible
ansible-playbook hermes.yml -K
```

# Licensing

Where possible the code in this repository is licensed under the
[Apache License, Version 2.0][14]. This is a permissive license allowing
anyone to use this code, even for commercial purposes, if they so
wish. Please refer to the full text of the license for more
information.

# Contributing

Contributions in the form of pull-requests are most welcome. The
upstream version of this repo is located at [this link][15]. Note that
only PGP signed commits will be accepted so please setup [PGP
signing][16] in order to commit to this project.

[1]: https://www.eideticom.com/
[2]: https://github.com/iovisor/bpf-docs/blob/master/eBPF.md
[3]: https://aws.amazon.com/ec2/instance-types/f1/
[4]: https://github.com/Eideticom/eid-hermes-qemu
[5]: https://lists.sr.ht/~philmd/qemu/patches/5932
[6]: https://www.kernel.org/
[7]: https://www.linkedin.com/posts/stephen-bates-8791263_nvm-express-working-groups-activity-6713828187782156288-pYrv
[8]: https://www.snia.org/computational
[9]: specs/eid-hermes-theory-of-operation.md
[10]: specs/eid-hermes-interface.md
[11]: https://github.com/aws/aws-fpga/tree/master/sdk/linux_kernel_drivers/xdma
[12]: https://www.ansible.com/
[13]: https://github.com/billfarrow/pcimem
[14]: https://www.apache.org/licenses/LICENSE-2.0
[15]: https://github.com/Eideticom/eid-hermes
[16]: https://docs.github.com/en/github/authenticating-to-github/signing-commits
