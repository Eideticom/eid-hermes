# Amazon FPGA Hardware Development Kit
#
# Copyright 2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Amazon Software License (the "License"). You may not use
# this file except in compliance with the License. A copy of the License is
# located at
#
#    http://aws.amazon.com/asl/
#
# or in the "license" file accompanying this file. This file is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or
# implied. See the License for the specific language governing permissions and
# limitations under the License.

SHELL = /bin/bash

topdir := $(shell cd $(src)/.. && pwd)

TARGET_MODULE:=hermes

EXTRA_CFLAGS := -I$(topdir)/include
#EXTRA_CFLAGS += -D__LIBXDMA_DEBUG__

ifneq ($(KERNELRELEASE),)
	$(TARGET_MODULE)-objs := libxdma.o xdma_sgdma.o hermes_mod.o hermes_cdev.o
	obj-m := $(TARGET_MODULE).o
else
	BUILDSYSTEM_DIR:=/lib/modules/$(shell uname -r)/build
	PWD:=$(shell pwd)
all :
	$(MAKE) -C $(BUILDSYSTEM_DIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(BUILDSYSTEM_DIR) M=$(PWD) clean
	@/bin/rm -f *.ko modules.order *.mod.c *.o *.o.ur-safe .*.o.cmd

install: all
	$(MAKE) -C $(BUILDSYSTEM_DIR) M=$(PWD) modules_install
	depmod -a
	install -m 644 10-hermes.rules /etc/udev/rules.d
	-rmmod -s hermes || true
	-modprobe hermes

uninstall:
	-rm -f /etc/udev/rules.d/10-hermes.rules
	-rmmod -s hermes || true
	-rm -f /lib/modules/`uname -r`/extra/hermes.ko
	depmod -a

# Allow make install and uninstall targets to work without having to set ec2 in the environment.
noop:

endif

ifneq ($(ec2),1)
	CFLAGS_hermes_mod.o := -DINTERNAL_TESTING
endif
