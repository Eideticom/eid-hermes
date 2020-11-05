obj-y := xdma/ hermes/

ifdef KDIR
 KERNEL_SOURCES	 = $(KDIR)
else
 KERNEL_UNAME	:= $(shell uname -r)
 KERNEL_SOURCES	 = /lib/modules/$(KERNEL_UNAME)/build
endif

default: modules
.PHONY: default

%::
	$(MAKE) -C $(KERNEL_SOURCES) M=$$PWD $@

install: modules_install
.PHONY: install
