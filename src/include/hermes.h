/*******************************************************************************
 *
 * Hermes Linux Driver
 * Copyright(c) 2020 Eideticom, Inc.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms and conditions of the GNU General Public License,
 * version 2, as published by the Free Software Foundation.
 *
 * This program is distributed in the hope it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * The full GNU General Public License is included in this distribution in
 * the file called "LICENSE".
 *
 * Martin Oliveira <martin.oliveira@eideticom.com>
 *
 ******************************************************************************/

#ifndef HERMES_H
#define HERMES_H

#ifdef __KERNEL__
#include <linux/types.h>
#else
#include <stdint.h>
#endif

struct __attribute__((__packed__)) hermes_cmd_req {
	uint8_t opcode;
	uint8_t rsv0;
	uint16_t cid;
	uint32_t rsv1;
	union {
		struct __attribute__((__packed__)) {
			uint8_t slot_type;
			uint8_t slot_id;
			uint16_t rsv;
			uint64_t addr;
			uint32_t len;
		} xdma;
		uint32_t cmd_specific[6];
	};
};

struct __attribute__((__packed__)) hermes_cmd_res {
	uint16_t cid;
	uint8_t status;
	uint8_t rsv0[5];
	union {
		struct __attribute__((__packed__)) {
			uint32_t bytes;
		} xdma;
		uint32_t cmd_specific[2];
	};
};

struct __attribute__((__packed__)) hermes_cmd_req_res {
	struct hermes_cmd_req req;
	struct hermes_cmd_res res;
};

enum hermes_opcode {
	HERMES_REQ_SLOT = 0x00,
	HERMES_REL_SLOT,
	HERMES_WR = 0x10,
	HERMES_RD,
	HERMES_RUN = 0x80,
};

enum hermes_slot_type {
	HERMES_SLOT_PROG,
	HERMES_SLOT_DATA,
};

enum hermes_status {
	HERMES_STATUS_SUCCESS,
	HERMES_STATUS_NO_SPACE,
	HERMES_STATUS_INV_PROG_SLOT,
	HERMES_STATUS_INV_DATA_SLOT,
	HERMES_STATUS_INV_SLOT_TYPE,
	HERMES_STATUS_INV_ADDR,
	HERMES_STATUS_INV_OPCODE,
	HERMES_STATUS_EBPF_ERROR,

	HERMES_GENERIC_ERROR = 0xFF,
};

#endif // HERMES_H
