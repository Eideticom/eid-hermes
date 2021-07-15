# Hermes Capstone Project

## Table of Contents
1. [Overview](#overview)
  - [Processor](#processor)
  - [DRAM Interface](#dram_interface)
  - [BAR Interface](#bar_interface)
2. [Design Choices](#design_choices)
3. [Helpful Documentation](#documentation)
4. [Design Specifications](#design_specs)
5. [Next Steps](#nextsteps)


<a name="overview"></a>
# Overview

This project revolves around the growing technology of hardware computational acceleration. Specifically we are using FPGA's to implement our team's custom designed processor.
This processor is based on the eBPF instruction set which is a very powerful vendor neutral instruction set that continues to grow in popularity. By deploying our
processor on an Amazon Cloud service with FPGA connected we can enable computational acceleration with relative ease for users. There is no need for them to have
the costly device themselves, but can rent time on an Amazon Cloud instance, and offload computation to our processor and memory system. This allows computational
parrallelism, and is also an efficient purpose built processor for eBPF specific operations compared to a typical processor.  This project is sponsored by Eideticom,
who have been concurrently developing the software driver that will be used for communication with the hardware portions of the design we have worked on. 

There are three main pieces to this project, namely the [Processor](#processor), the [DRAM Interface](#dram_interface), and the [BAR Interface](#bar_interface).

<a name="processor"></a>
### Processor

The processor is the main component of the eBPF FPGA accelerator, as this is where the instructions are actually broken down into steps and the results are computed.
The eBPF instruction set has similarities to many Reduced ISA's (Instruction Set Architecture), it has 10 64 bit general purpose registers, and all of the
instructions are quite commonplace, and these are discussed in more detail in the [Design Specifications Document](developer_design.md).

The processor that we were able to create in our limited time frame as a capstone project is not necessarily indicative of what a final product for this technology could
look like. Our processor is a single-cycle simple processor capable of clock speeds only up to about 10 MHz, however this could be greatly improved upon based on the steps
outlined in our [Next Steps Document](next_steps.md). Shown below is the final design of our implemented processor:

Grab screenshot, upload, and place here


<a name="dram_interface"></a>
### DRAM Interface

The DRAM (Dynamic Random Access Memory) interface is how our processor interacts with the onboard DRAM of the AWS FPGA's. There are more resources related to this in [Documentation](#documentation). The FPGA's on the Amazon Web Services F1 servers have 64 GiB of onboard memory that is accessible through DDR controllers based on the [CL_DRAM_DMA](../../../examples/cl_dram_dma) example. This example is quite complicated, however at it's most basic it takes general DMA requests and correctly routes them to the onboard memory. What this means for us is that as long as we could appropriately communicate with this block we should be able to make read and write requests to the instruction and data memory for the processor. Shown below is the overall design for our DRAM Interface.

Grab screenshot, upload, place here


<a name="bar_interface"></a>
### BAR Interface

The BAR (Base Address Register) interface is how our processor interacts with the information coming from the "user". This is based in part on the design of the driver developed by [Eideticom](https://github.com/Eideticom/eid-hermes). The driver wants to make partitions in our FPGA memory based on instruction and data memory for different programs and the core(s) of the FPGA should execute these programs and return commands based on the result. All of this information needs to be passed around via the BAR interface which allows the driver to place data into memory, and read from memory as well.

This interface was not able to be finished in our project however it is discussed in [Next Steps](next_steps.md). Much of the information regarding this interface and how it will be formatted in the memory is discussed at length in Eideticom's [Specs](https://github.com/Eideticom/eid-hermes/tree/master/specs)


<a name="design_choices"></a>
# Design Choices

Many of the design choices made for this project came down to time and effort, as this was a capstone project we were quite limited on time. Given our knowledge base at the start of the project, a large amount of time was required in reading documentation from Xilinx, AWS, and many other resources that are listed in the [Documentation](#documentation). 

Given constraints we were only able to successfully create a single-cycle eBPF processor, which is much slower when compared to a pipelined processor. The eBPF language was chosen for it being a powerful, vendor-neutral instruction set that is growing in popularity. AWS servers were used because of the ability for us to access them anywhere, and that they are a much cheaper source of FPGA "time" than buying a board. 


<a name="documentation"></a>
# Helpful Documentation

Linked Below are a large number of helpful resources and documentation that we came across while working on this project. 

[Hermes Specifications](https://github.com/Eideticom/eid-hermes/tree/master/specs)

[AWS HDK](https://github.com/aws/aws-fpga/tree/master/hdk)

[CL_DRAM_DMA Example](https://github.com/aws/aws-fpga/tree/master/hdk/cl/examples/cl_dram_dma)

[AWS Shell Documentation](https://github.com/aws/aws-fpga/blob/master/hdk/docs/AWS_Shell_Interface_Specification.md)

[CL_DRAM_DMA Explained](https://www.legupcomputing.com/blog/index.php/2017/08/18/amazon-ec2-f1-tutorial-understanding-the-cl_dram_dma-example/)

[Xilinx AXI Interface](https://www.xilinx.com/support/documentation/ip_documentation/axi_ref_guide/latest/ug1037-vivado-axi-reference-guide.pdf)

[Xilinx XDMA](https://www.xilinx.com/support/documentation/ip_documentation/xdma/v4_1/pg195-pcie-dma.pdf)



<a name="design_specs"></a>
# Design Specifications

The design specifications for this project are delved into in more detail in the [Design Specifications Document](developer_design.md). 


<a name="nextsteps"></a>
# Next Steps

The next steps for this project are talked about in detail in the [Next Steps Document](next_steps.md)
