# eid-hermes: An open-source eBPF accelerator for AWS F1 instances.

# Introduction

This is an open-source [Eideticom][1]-led project that explores how
[eBPF][2]-based FPGA accelerators can be used to offload application
code from host processors.

This repository contains the source code for an eBPF-based PCIe
accelerator design that can be run on [AWS F1 servers][3]. As such,
anyone can use this project to run said accelerators on the cloud and
develop host code (such as drivers and userspace libraries) targetting
said accelerators.

# Licensing

Where possible the code in this repository is licensed under the
[Apache License, Version 2.0][4]. This is a permissive license allowing
anyone to use this code, even for commercial purposes, if they so
wish. Please refer to the full text of the license for more
information.

# Contributing

Contributions in the form of pull-requests are most welcome. The
upstream version of this repo is located at [this link][5]. Note that
only PGP signed commits will be accepted so please setup [PGP
signing][6] in order to commit to this project.

[1]: https://www.eideticom.com/
[2]: https://github.com/iovisor/bpf-docs/blob/master/eBPF.md
[3]: https://aws.amazon.com/ec2/instance-types/f1/
[4]: https://www.apache.org/licenses/LICENSE-2.0
[5]: https://github.com/Eideticom/eid-hermes
[6]:https://docs.github.com/en/github/authenticating-to-github/signing-commits
