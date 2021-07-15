# Deploying the Design onto AWS


### Rationale


One of the big challenges that we had as we were working on this project was using AWS, and finding the correct documentation to do so. As such, we wanted to link
some of the important documents and walkthrough a little bit of our process for those that may be adding onto, or trying to implement our project.


### AWS basics


The steps for implementing one of the AWS examples are found [here](https://github.com/aws/aws-fpga/tree/master/hdk#readme). Our design implements the Cl_DRAM_DMA example,
so that is a helpful example to start. The process will take you all the way to getting the design onto the FPGA card


When we were testing and wanting to simulate our design, we also had to do this on AWS, as the Developer AMI comes with fully liscensed version of Vivado, which is necessary for 
synthesizing the design for timing on an F1 instance. In addition it allows for you to get the entire simulation model including the shell.


[This document](https://github.com/aws/aws-fpga/blob/master/hdk/docs/RTL_Simulating_CL_Designs.md) for understanding simulating our design with the shell, on an AWS instance


### Setting up a GUI to synthesize


We primarily used this GUI to synthesize the design, as it worked much more easily for us than trying to do it from the command line. 


This is the [main document](https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-linux.html) is the main document we branched from for setting up a usable Vivado GUI off of an AWS instance, which was very convenient for when we were testing timing.
This NICE DCV guide will allow a remote desktop connection, from which you can open Vivado as a GUI on the AWS instance.

It should be noted that setting this up everytime would be difficult, and it takes some time to install. Once we had it set up, we left our instance stored, rather than terminating between uses.

### Using the XDMA driver to load data onto the FPGA DRAM

This is a process that we followed, but never got to the point that we were actually able to test with our design. 

To get the XDMA driver onto your instance, follow along [here](https://github.com/aws/aws-fpga/blob/master/sdk/linux_kernel_drivers/xdma/xdma_install.md)

Then, for a sample of how to load data through the XDMA channels from the host follow [this](https://github.com/aws/aws-fpga/tree/master/sdk/linux_kernel_drivers/xdma#readme) example

