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

#define _GNU_SOURCE

#include "hermes_uapi.h"

#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdint.h>
#include <sys/ioctl.h>
#include <sys/uio.h>
#include <linux/fs.h>

#define BUF_SIZE 1024 * 1024

int main()
{
	char *src, *dst, *prog;
	int hermes_fd;
	int ret;
	struct hermes_download_prog_ioctl_argp argp = {
		.len = 16,
	};
	struct iovec iov;

	/* Open device */
	hermes_fd = open("/dev/hermes0", O_RDWR);
	if (hermes_fd == -1) {
		fprintf(stderr, "Failed to open device\n");
		ret = 1;
		goto out;
	}

	/* Initialize buffers */
	src = malloc(BUF_SIZE * sizeof(char));
	dst = malloc(BUF_SIZE * sizeof(char));
	prog = malloc(16 * sizeof(char));

	if (!src || !dst || !prog) {
		fprintf(stderr, "Failed to allocate buffers\n");
		ret = 1;
		goto out_close;
	}

	memset(src, 0xFF, BUF_SIZE);
	memset(dst, 0x00, BUF_SIZE);

	/*
	 * Create an eBPF program with two instructions:
	 *     r0 = 0 (b7 00 00 00 00 00 00 00)
	 *     ret    (95 00 00 00 00 00 00 00)
	 */
	memset(prog, 0, 16);
	prog[0] = 0xb7;
	prog[8] = 0x95;

	/* Send the eBPF program */
	argp.prog = (uint64_t) prog;
	ret = ioctl(hermes_fd, HERMES_DOWNLOAD_PROG_IOCTL, &argp);
	if (ret) {
		perror("Failed to write eBPF program");
		goto out_free;
	}

	/* Write some data */
	iov.iov_base = src;
	iov.iov_len = BUF_SIZE;
	ret = pwritev2(hermes_fd, &iov, 1, 0, 0);
	if (ret < 0) {
		perror("Failed to write data");
		ret = 1;
		goto out_free;
	}

	/* Read back into dst */
	iov.iov_base = dst;
	iov.iov_len = BUF_SIZE;
	ret = preadv2(hermes_fd, &iov, 1, 0, 0);
	if (ret < 0) {
		perror("Failed to read data");
		ret = 1;
		goto out_free;
	}

	ret = 0;

out_free:
	free(src);
	free(dst);
	free(prog);
out_close:
	close(hermes_fd);
out:
	return ret;
}
