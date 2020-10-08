#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>

#define BUF_SIZE              50 * 4096
#define OFFSET_IN_FPGA_DRAM   0x10000000

static char *rand_str(char *str, size_t size)  // randomize a string of size <size>
{
    const char charset[] = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRTSUVWXYZ1234567890";
    int i;

    for(i = 0; i < size; i++) {
        int key = rand() % (int) (sizeof charset - 1);
        str[i] = charset[key];
    }

    str[size-1] = '\0';
    return str;
}


int main()
{
    char* srcBuf;
    char* dstBuf;
    int read_fd;
    int write_fd;
    int i;
    int ret;

    srcBuf = (char*)malloc(BUF_SIZE * sizeof(char));
    dstBuf = (char*)malloc(BUF_SIZE * sizeof(char));

    /* Initialize srcBuf */
    rand_str(srcBuf, BUF_SIZE);

    /* Open a XDMA write channel (Host to Core) */
    if ((write_fd = open("/dev/xdma0_h2c_0",O_WRONLY)) == -1) {
        perror("open failed with errno");
    }

    /* Open a XDMA read channel (Core to Host) */
    if ((read_fd = open("/dev/xdma0_c2h_0",O_RDONLY)) == -1) {
        perror("open failed with errno");
    }

    /* Write the entire source buffer to offset OFFSET_IN_FPGA_DRAM */
    ret = pwrite(write_fd , srcBuf, BUF_SIZE, OFFSET_IN_FPGA_DRAM);
    if (ret < 0) {
        perror("write failed with errno");
    }

    printf("Tried to write %u bytes, succeeded in writing %u bytes\n", BUF_SIZE, ret);
    if (BUF_SIZE != ret) {
        return 1;
    }

    ret = pread(read_fd, dstBuf, BUF_SIZE, OFFSET_IN_FPGA_DRAM);
    if (ret < 0) {
        perror("read failed with errno");
    }

    printf("Tried reading %u byte, succeeded in read %u bytes\n", BUF_SIZE, ret);
    if (BUF_SIZE != ret) {
        return 1;
    }

    if (close(write_fd) < 0) {
        perror("write_fd close failed with errno");
    }
    if (close(read_fd) < 0) {
        perror("read_fd close failed with errno");
    }

    printf("Data read is %s\n", dstBuf);

    if (strncmp(srcBuf, dstBuf, BUF_SIZE)) {
        printf("Data mismatch\n");
	return 1;
    }

    return 0;
}
