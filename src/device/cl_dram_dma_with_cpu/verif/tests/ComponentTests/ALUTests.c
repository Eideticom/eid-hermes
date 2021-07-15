#include <stdint.h>
#include <stdio.h>
#include <inttypes.h>

#ifdef __APPLE__
#include <libkern/OSByteOrder.h>

#define htobe16(x) OSSwapHostToBigInt16(x)
#define htole16(x) OSSwapHostToLittleInt16(x)
#define htobe32(x) OSSwapHostToBigInt32(x)
#define htole32(x) OSSwapHostToLittleInt32(x)
#define htobe64(x) OSSwapHostToBigInt64(x)
#define htole64(x) OSSwapHostToLittleInt64(x)
#else
#include <endian.h>
#endif

int64_t const a_64bit_tests[7] = {15, 0, -1, INT64_MIN, INT64_MAX, INT64_MIN, INT64_MAX};
int64_t const b_64bit_tests[7] = {-3, 9, -18, INT64_MIN, INT64_MIN, INT64_MAX, INT64_MAX};
uint64_t const b_64bit_shift_tests[7] = {0, 1, 5, 32, 50, 63, 65};

int32_t const a_32bit_tests[7] = {15, 0, -1, INT32_MIN, INT32_MAX, INT32_MIN, INT32_MAX};
int32_t const b_32bit_tests[7] = {-3, 9, -18, INT32_MIN, INT32_MIN, INT32_MAX, INT32_MAX};
uint32_t const b_32bit_shift_tests[7] = {0, 1, 5, 16, 24, 31, 33};


#define OPERATOR_TEST(OP) \
    do {                             \
        printf(#OP " 32 BIT: {"); \
        for (int i = 0; i < 7; i++) { \
            printf("%" PRId32 ", ", a_32bit_tests[i] OP b_32bit_tests[i]); \
        } \
        printf("}\n"); \
        printf(#OP " 64 BIT: {"); \
        for (int i = 0; i < 7; i++) { \
            printf("%" PRId64 ", ", a_64bit_tests[i] OP b_64bit_tests[i]); \
        } \
        printf("}\n"); \
    } while(0)

int32_t arithmetic32(int32_t x, unsigned int bits) {
	for (; bits > 0; bits--) {
		x /= 2;
	}
	return x;
}

int64_t arithmetic64(int64_t x, unsigned int bits) {
	for (; bits > 0; bits--) {
		x /= 2;
	}
	return x;
}


int main () {
    //addition
    OPERATOR_TEST(+);

    //subtraction
    OPERATOR_TEST(-);

    //multiplication
    OPERATOR_TEST(*);

    //division
    OPERATOR_TEST(/);

    //OR
    OPERATOR_TEST(|);

    //AND
    OPERATOR_TEST(&);

    //Logical left shift
    printf("<< 32 BIT: {");
    for (int i = 0; i < 7; i++) {
        printf("%" PRId32 ", ", (int32_t)((uint32_t) a_32bit_tests[i] << (uint32_t) b_32bit_shift_tests[i]));
    }
    printf("}\n");
    printf("<< 64 BIT: {");
    for (int i = 0; i < 7; i++) {
        printf("%" PRId64 ", ", (int64_t)((uint64_t) a_64bit_tests[i] << (uint64_t) b_64bit_shift_tests[i]));
    }
    printf("}\n");

    //logic shift right
    printf(">> 32 BIT: {");
    for (int i = 0; i < 7; i++) {
        printf("%" PRId32 ", ", (int32_t)((uint32_t) a_32bit_tests[i] >> (uint32_t) b_32bit_shift_tests[i]));
    }
    printf("}\n");
    printf(">> 64 BIT: {");
    for (int i = 0; i < 7; i++) {
        printf("%" PRId64 ", ", (int64_t)((uint64_t) a_64bit_tests[i] >> (uint64_t) b_64bit_shift_tests[i]));
    }
    printf("}\n");

    //modulus
    printf("%% 32 BIT: {");
    for (int i = 0; i < 7; i++) {
        printf("%" PRId32 ", ", a_32bit_tests[i] % b_32bit_tests[i]);
    }
    printf("}\n");
    printf("%% 64 BIT: {");
    for (int i = 0; i < 7; i++) {
        printf("%" PRId64 ", ", a_64bit_tests[i] % b_64bit_tests[i]);
    }
    printf("}\n");

    //XOR
    OPERATOR_TEST(^);

    //arithmetic shift right
    printf(">>> 32 BIT: {");
    for (int i = 0; i < 7; i++) {
        printf("%" PRId32 ", ", arithmetic32(a_32bit_tests[i], b_32bit_shift_tests[i]));
    }
    printf("}\n");
    printf(">>> 64 BIT: {");
    for (int i = 0; i < 7; i++) {
        printf("%" PRId64 ", ", arithmetic64(a_64bit_tests[i], b_64bit_shift_tests[i]));
    }
    printf("}\n");

    //byteswap LE
    printf("LE 16: {");
    for (int i = 0; i < 7; i++) {
        printf("%" PRId64 ", ", (int64_t) htole16(a_64bit_tests[i]));
    }
    printf("}\n");
    printf("LE 32: {");
    for (int i = 0; i < 7; i++) {

        printf("%" PRId64 ", ", (int64_t) htole32(a_64bit_tests[i]));
    }
    printf("}\n");
    printf("LE 64: {");
    for (int i = 0; i < 7; i++) {
        printf("%" PRId64 ", ", (int64_t) htole64(a_64bit_tests[i]));
    }
    printf("}\n");

    //byteswap BE
    printf("BE 16: {");
    for (int i = 0; i < 7; i++) {
        printf("%" PRId64 ", ", (int64_t) htobe16(a_64bit_tests[i]));
    }
    printf("}\n");
    printf("BE 32: {");
    for (int i = 0; i < 7; i++) {

        printf("%" PRId64 ", ", (int64_t) htobe32(a_64bit_tests[i]));
    }
    printf("}\n");
    printf("BE 64: {");
    for (int i = 0; i < 7; i++) {
        printf("%" PRId64 ", ", (int64_t) htobe64(a_64bit_tests[i]));
    }
    printf("}\n");

    return 1;
}
