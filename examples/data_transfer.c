/*******************************************************************************
 * Copyright 2020 Eideticom Inc
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 ******************************************************************************/

#include "hermes.h"

#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <errno.h>

#define BUF_SIZE 1024*1024

int send_ioctl(int fd, uint8_t opcode, uint16_t cid, uint8_t slot_id, uint8_t
		slot_type, uint64_t addr, uint32_t len)
{
	int ret;
	struct hermes_cmd_req_res req_res;
	req_res.req.opcode = opcode;
	req_res.req.cid = cid;
	req_res.req.xdma.slot_id = slot_id;
	req_res.req.xdma.slot_type = slot_type;
	req_res.req.xdma.addr = addr;
	req_res.req.xdma.len = len;

	ret = ioctl(fd, 0, &req_res);
	if (ret) {
		fprintf(stderr, "Ioctl failed: %m\n");
		return 1;
	}

	if (req_res.res.status) {
		fprintf(stderr, "Command failed with status: 0x%x\n",
				req_res.res.status);
		return 1;
	}

	if (req_res.res.xdma.bytes != len)
		fprintf(stderr, "DMA did not transfer all data (note that this is allowed).\n");

	return 0;
}

int main()
{
	char *src, *dst;
	int hermes_fd;
	int ret;

	/* Open device */
	hermes_fd = open("/dev/hermes0", O_RDWR);
	if (hermes_fd == -1) {
		fprintf(stderr, "Failed to open device\n");
		return 1;
	}


	/* Initialize buffers */
	src = (char*)malloc(BUF_SIZE * sizeof(char));
	dst = (char*)malloc(BUF_SIZE * sizeof(char));

	if (!src || !dst) {
		fprintf(stderr, "Failed to allocate buffers\n");
		return 1;
	}

	memset(src, 0xff, BUF_SIZE);
	memset(dst, 0x00, BUF_SIZE);

	/* Send Write command */
	ret = send_ioctl(hermes_fd, HERMES_WR, 0x0000, 0, HERMES_SLOT_DATA,
			(uint64_t) src, BUF_SIZE);

	if (ret) {
		fprintf(stderr, "Write command failed\n");
		return 1;
	}

	/* Read back into dst */
	ret = send_ioctl(hermes_fd, HERMES_RD, 0x0001, 0, HERMES_SLOT_DATA,
			(uint64_t) dst, BUF_SIZE);
	if (ret) {
		fprintf(stderr, "Read command failed\n");
		return 1;
	}

	if (strcmp(src, dst)) {
		fprintf(stderr, "Src and Dst do not match!\n");
		return 1;
	}

	printf("Src and Dst match, DMAs succeeded\n");

	return 0;
}
