## Repository for working CPU


Some of the components in the [other folder](../../cl_dram_dma_with_cpu) were edited in the work with the interface. 
This folder is the CPU at the stage working as a fully functional unit,
and will work with [CPU Tb files](../../cl_dram_dma_with_cpu/verif/tests/ComponentTests)
As well as with the tb files in this directory.


## [Design specs of the CPU] (src/device/cl_dram_dma_with_cpu/docs/design_specification.MD)


Please reference this document for the design specifications of the CPU.


## Running the current Version of the CPU

For our team's development we did this primarily through Vivado on our local machines.
This directory can be loaded in as design sources, and the tb files as simulation sources.


## Known bugs and issues


Some of this is given treatment in the [Design specs of the CPU] (src/device/cl_dram_dma_with_cpu/docs/design_specification.MD)
document. We don't have any known bugs otherwise, with the exception that the Call function is not currently supported. 


The Out of bounds store/load execeptions, Jump Out of Bounds and Jump to middle of LDDW are also not currently supported.
The first three will require the interface to be fully working before they can be implemented (Working with the 
Memory bounds to identify errors) and the Jump to the middle of LDDW exception we had no elegent solution for 
implementing. 



Some of the components in the other folder were edited to work with the interface. This folder is the CPU at the stage working as a fuly functional unit, and will work with CPU Tb files


