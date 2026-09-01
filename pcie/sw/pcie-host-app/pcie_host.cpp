/*
 * Copyright (C) 2021 Xilinx, Inc.  All rights reserved.
 *
 * Copyright(C) 2022-2026 Advanced Micro Devices, Inc. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * XILINX BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * Except as contained in this notice, the name of the Xilinx shall not be used
 * in advertising or otherwise to promote the sale, use or other dealings in
 * this Software without prior written authorization from Xilinx.
 */

#include "pcie_host.h"
#include "mainwindow.h"
#define _BSD_SOURCE
//#define _XOPEN_SOURCE 500
#include <assert.h>
#include <fcntl.h>
#include <getopt.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <time.h>
#include <sched.h>
#include <sys/sysinfo.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>
#include <pthread.h>
#include <glob.h>
#include "dma_xfer_utils.c"
#include <glib-2.0/glib.h>

#define MAP_SIZE (32*1024UL)
#define MAP_MASK (MAP_SIZE - 1)

/* ── BAR2 register offsets (RC / host side) ──────────────────────────────
 * These are the host-visible BAR2 offsets.  The EP driver uses a different
 * set of offsets (PCIEP_* in xilinx_pci_endpoint.c) because BAR2 maps to
 * the EP's pcie-reg-space IP which has separate RC-side and EP-side views.
 *
 * RC-side registers (host writes, EP reads via PCIRC_* in EP driver):  */
#define PCIRC_GET_FILE_LENGTH      		0x04
#define PCIRC_PID_HIGH				0x0C
#define PCIRC_RAW_RESOLUTION      		0x18
#define PCIRC_UCASE_SET          		0x20
#define PCIRC_FPS_SET          			0x28
#define PCIEP_SET_SIG                           0x34
#define PCIRC_FMT_SET         			0x1c  /* BAR2 RC offset for PCIRC_FORMAT_SET (EP offset 0x9c) */

//  Interrupts
#define PCIRC_READ_BUFFER_TRANSFER_DONE 	0x70
#define PCIRC_WRITE_BUFFER_TRANSFER_DONE 	0x74
#define PCIRC_HOST_DONE			  	0x78

#define KGREEN  "\x1B[32m"
#define KRED "\x1B[31m"
#define RESET "\x1B[0m"

/* #define T_DEBUG */  /* Uncomment to enable per-30-frame FPS counters in DMA threads */
#define FAILURE -1

//Planes Multiplier
#define YUV_MULTIPLIER  1.5   /* NV12  semi-planar 4:2:0 = 1.5 bytes/pixel */
#define YUY2_MULTIPLIER 2.0   /* YUY2  packed      4:2:2 = 2.0 bytes/pixel */
#define BGR_MULTIPLIER  3     /* BGR   packed            = 3.0 bytes/pixel */

/* Format IDs written to PCIRC_FMT_SET register — must match VGST_FORMAT_TYPE on EP */
#define FMT_YUY2  1   /* VGST_FORMAT_YUY2  — 16 bpp packed  4:2:2 */
#define FMT_NV12  2   /* VGST_FORMAT_NV12  — 12 bpp semi-planar 4:2:0 */
#define FMT_RGB   3   /* VGST_FORMAT_RGB   — 24 bpp packed RGB888 */

/* frame_bytes() defined after global variable declarations below — see after trans struct */

/* EP-side registers (EP writes, host reads via BAR2):
 * Used by pcie_dma_read / pcie_dma_write to poll buffer readiness
 * and write transfer-done acknowledgements. */
#define PCIEP_READ_BUFFER_READY   		0x80
#define PCIEP_READ_BUFFER_ADDR_LOW   		0x84
#define PCIEP_READ_BUFFER_OFFSET 		0x88
#define PCIEP_READ_BUFFER_SIZE   		0x8c

#define PCIEP_WRITE_BUFFER_READY   		0x90
#define PCIEP_WRITE_BUFFER_ADDR_LOW   		0x94
#define PCIEP_WRITE_BUFFER_OFFSET 		0x98
#define PCIEP_WRITE_BUFFER_SIZE   		0x9c

#define PCIEP_READ_TRANSFER_COMPLETE   		0xa0
#define PCIEP_WRITE_TRANSFER_COMPLETE  		0xa4
#define PCIEP_WRITE_BUFFER_ADDR_HIGH   		0xb8
#define PCIEP_READ_BUFFER_ADDR_HIGH   		0xbc

/* ── QDMA device nodes and BAR2 resource ──────────────────────────────────
 * Default values matching the standard VEK385 PCIe enumeration.
 * These are overridden at runtime by CLI args (--h2c / --c2h / --bar2 /
 * --qdma-dev) parsed in main.cpp, or auto-detected on startup.
 * H2C = Host-to-Card (DMA write), C2H = Card-to-Host (DMA read). */
#define H2C_DEVICE_DEFAULT      "/dev/qdmac1000-MM-0"
#define C2H_DEVICE_DEFAULT      "/dev/qdmac1000-MM-1"
#define REG_DEVICE_DEFAULT      "/sys/bus/pci/devices/0000:c1:00.0/resource2"
#define QDMA_DEV_DEFAULT        "qdmac1000"
#define DMACTL_DEFAULT          "/usr/local/sbin/dma-ctl"

/* Runtime device paths — set by pcie_host_configure_devices() */
char g_h2c_dev[256]   = H2C_DEVICE_DEFAULT;
char g_c2h_dev[256]   = C2H_DEVICE_DEFAULT;
char g_reg_dev[256]   = REG_DEVICE_DEFAULT;
char g_qdma_dev[64]   = QDMA_DEV_DEFAULT;
char g_dmactl[256]    = DMACTL_DEFAULT;

/* Legacy macros now redirect to runtime globals */
#define H2C_DEVICE      g_h2c_dev
#define C2H_DEVICE      g_c2h_dev
#define REG_DEVICE_NAME g_reg_dev
#define QDMA_DEV        g_qdma_dev
#define DMACTL          g_dmactl
#define COUNT_DEFAULT 		  (1)
#define SIZE_DEFAULT		  (32)
/* Frame rate options */
#define FPS_MIN               (30)
#define FPS_MAX               (60)
#define FPS_DEFAULT           (FPS_MIN)
#define FMT_DEFAULT           (0)
#define PID_DEFAULT           42
#define UCASE_DEFAULT          0

/* Input file params */
#define INPUT_WIDTH_DEFAULT        (1920)
#define INPUT_HEIGHT_DEFAULT       (1080)

struct pcie_transfer {
	int infile_fd;
	int h2c_fd;
	int c2h_fd;
	int reg_fd;
	char *map_base;
	char *read_buffer;
	char *write_buffer;
	char *infname;
} trans;

#define BILLION  1000000000.0

int usecase_sel;
int format_type = FMT_NV12;   /* default NV12; overwritten by format selection in cmaincall() */

/* frame_bytes() — Returns the per-frame buffer size in bytes for the current format. */
static inline size_t frame_bytes(int w, int h) {
    if (format_type == FMT_YUY2)
        return (size_t)(w * h * YUY2_MULTIPLIER);  /* YUY2 16bpp */
    if (format_type == FMT_RGB)
        return (size_t)(w * h * BGR_MULTIPLIER);   /* RGB888 24bpp */
    return (size_t)(w * h * YUV_MULTIPLIER);       /* NV12 12bpp default */
}

volatile unsigned int *host_done;
unsigned int in_width = INPUT_WIDTH_DEFAULT;
unsigned int in_height = INPUT_HEIGHT_DEFAULT;
unsigned int fps = FPS_DEFAULT;
unsigned int u_case = UCASE_DEFAULT;
volatile unsigned int *set_sig;

circular_buffer queue_frame;
circular_buffer queue_file_frame;
bool app_running = true;

/* Per-run flags that track whether this run has observed at least one
 * BUFFER_READY=1.  Used to guard the 0xef end-of-stream exit condition
 * against stale 0xef values left in the register from the previous run.
 *
 * Background: pcie_reset_all() in the EP driver's release() no longer
 * clears TRANSFER_DONE, so the 0xef value written by the EP app just
 * before exit survives long enough for the host to detect it.  However,
 * the host threads start BEFORE the new EP app opens the driver fd (which
 * is what clears TRANSFER_DONE to 0 in open()).  During that window the
 * host must not exit on stale 0xef.  Requiring g_h2c/c2h_seen_ready=true
 * (at least one frame was exchanged this run) prevents false exits. */
static volatile bool g_h2c_seen_ready = false;
static volatile bool g_c2h_seen_ready = false;

/* ── SIGINT / Ctrl+C handler ──────────────────────────────────────────
 * When the user presses Ctrl+C in the terminal, set app_running=false
 * so that all worker threads (file_read, pcie_dma_read, pcie_dma_write)
 * exit their loops.  Also signal the EP to stop via PCIEP_SET_SIG so
 * the EP's host_app_reg_read thread sees it and quits the GStreamer
 * pipeline.  Without this, Ctrl+C kills the host process immediately,
 * leaving QDMA descriptors and EP BAR2 registers in a dirty state that
 * blocks subsequent runs until a PCIe reset.
 *
 * This is safe from signal context: it only writes to a boolean and a
 * single volatile BAR2 register (async-signal-safe operations).
 * ──────────────────────────────────────────────────────────────────── */
static void sigint_handler(int sig)
{
	(void)sig;
	printf("\n[SIGINT] Ctrl+C received — shutting down gracefully\n");
	app_running = false;
	/* Signal EP to stop if BAR2 is mapped */
	if (trans.map_base && trans.map_base != (char *)-1)
		*((volatile uint32_t *)(trans.map_base + PCIEP_SET_SIG)) = 0x1;
}

/* Elapsed seconds since first call.
 * Prefix key log lines with [T+NNN.NNN] for easy correlation with EP dmesg
 * (which uses [NNNNNN.NNNNNN] kernel uptime).  The delta between host
 * T+0 and the first EP dmesg event tells you the host→EP launch offset. */
static double host_now_s(void)
{
	static struct timespec t0 = {0, 0};
	struct timespec tnow;
	clock_gettime(CLOCK_MONOTONIC, &tnow);
	if (t0.tv_sec == 0 && t0.tv_nsec == 0)
		t0 = tnow;
	return (tnow.tv_sec - t0.tv_sec) + (tnow.tv_nsec - t0.tv_nsec) * 1e-9;
}

/* ── Device discovery help ────────────────────────────────────────────────
 * Printed when --help is passed or when a device cannot be opened. */
void print_device_help(void)
{
	printf(
	"\n"
	"PCIe Host App — device discovery guide\n"
	"---------------------------------------\n"
	"\n"
	"QDMA device naming convention\n"
	"  The QDMA driver creates character devices named:\n"
	"    /dev/qdma<BUS><DEV><FN>-MM-<queue>\n"
	"\n"
	"  Where <BUS><DEV><FN> is the PCIe BDF encoded in lower-case hex:\n"
	"    <BUS>  = 2 hex digits for the PCIe bus  number  (e.g. c1)\n"
	"    <DEV>  = 2 hex digits for the PCIe device number (e.g. 00)\n"
	"    <FN>   = 1 hex digit  for the PCIe function number (e.g. 0)\n"
	"    -MM-   = Memory-Mapped DMA mode\n"
	"    <queue>= queue index  (0 = H2C Host→Card, 1 = C2H Card→Host) based on queue configurations from Host\n"
	"\n"
	"  Example: BDF 0000:c1:00.0  →  bus=c1 dev=00 fn=0\n"
	"           prefix = qdmac1000\n"
	"           H2C    = /dev/qdmac1000-MM-0\n"
	"           C2H    = /dev/qdmac1000-MM-1\n"
	"\n"
	"  Example: BDF 0000:03:00.0  →  bus=03 dev=00 fn=0\n"
	"           prefix = qdma03000\n"
	"           H2C    = /dev/qdma03000-MM-0\n"
	"           C2H    = /dev/qdma03000-MM-1\n"
	"\n"
	"Step 1 — Find the PCIe BDF of the VEK385 QDMA endpoint:\n"
	"    lspci | grep -i 'xilinx\\|qdma\\|versal\\|amd'\n"
	"    # Example output: c1:00.0 Memory controller: Xilinx Corporation ...\n"
	"\n"
	"Step 2 — Derive the QDMA prefix from the BDF (shell one-liner):\n"
	"    BDF=c1:00.0   # replace with your BDF (omit domain 0000:)\n"
	"    IFS=':.' read BUS DEV FN <<< \"$BDF\"\n"
	"    PREFIX=\"qdma${BUS}${DEV}${FN}\"\n"
	"    echo \"H2C: /dev/${PREFIX}-MM-0\"\n"
	"    echo \"C2H: /dev/${PREFIX}-MM-1\"\n"
	"    echo \"BAR2: /sys/bus/pci/devices/0000:${BDF%%.*}.${FN}/resource2\"\n"
	"\n"
	"Step 3 — Or just list existing QDMA nodes (auto-detect does this):\n"
	"    ls /dev/qdma*-MM-0   # shows all H2C devices\n"
	"    ls /dev/qdma*-MM-1   # shows all C2H devices\n"
	"\n"
	"Step 4 — Verify queue configuration (optional):\n"
	"    /usr/local/sbin/dma-ctl qdmac1000 q list\n"
	"    /usr/local/sbin/dma-ctl dev list\n"
	"\n"
	"Usage: pcie_host_app [OPTIONS]\n"
	"  --h2c    <path>   H2C device  /dev/qdma<BUS><DEV><FN>-MM-0  (default: " H2C_DEVICE_DEFAULT ")\n"
	"  --c2h    <path>   C2H device  /dev/qdma<BUS><DEV><FN>-MM-1  (default: " C2H_DEVICE_DEFAULT ")\n"
	"  --bar2   <path>   BAR2        /sys/bus/pci/devices/<DOMAIN>:<BDF>/resource2\n"
	"                                                               (default: " REG_DEVICE_DEFAULT ")\n"
	"  --qdma   <name>   QDMA prefix qdma<BUS><DEV><FN>  used by dma-ctl\n"
	"                                                               (default: " QDMA_DEV_DEFAULT ")\n"
	"  --dmactl <path>   Path to dma-ctl binary                     (default: " DMACTL_DEFAULT ")\n"
	"  --help            Show this help\n"
	"\n"
	"VEK385 setup — BDF=0000:c1:00.0 → prefix=qdmac1000.\n"
	"Defaults already match; no arguments are needed:\n"
	"  pcie_host_app\n"
	"\n"
	"Equivalent explicit arguments:\n"
	"  pcie_host_app --h2c /dev/qdmac1000-MM-0 \\\n"
	"                --c2h /dev/qdmac1000-MM-1 \\\n"
	"                --bar2 /sys/bus/pci/devices/0000:c1:00.0/resource2 \\\n"
	"                --qdma qdmac1000\n"
	"\n"
	"If your host enumerates the VEK385 at a different BDF, e.g. 0000:03:00.0:\n"
	"  pcie_host_app --h2c /dev/qdma03000-MM-0 \\\n"
	"                --c2h /dev/qdma03000-MM-1 \\\n"
	"                --bar2 /sys/bus/pci/devices/0000:03:00.0/resource2 \\\n"
	"                --qdma qdma03000\n"
	"\n");
}

/* Auto-detect QDMA devices by scanning /dev/qdma*.
 * Fills g_h2c_dev / g_c2h_dev / g_reg_dev / g_qdma_dev if a match is found
 * and the user hasn't already overridden them via CLI args.
 * Returns true if at least one device was found. */
static bool auto_detect_devices(bool h2c_overridden, bool c2h_overridden,
                                 bool bar2_overridden, bool qdma_overridden)
{
	/* Scan for /dev/qdma*-MM-0 (H2C) */
	bool found = false;
	glob_t gl;
	memset(&gl, 0, sizeof(gl));

	if (!h2c_overridden || !c2h_overridden || !bar2_overridden || !qdma_overridden) {
		if (glob("/dev/qdma*-MM-0", 0, NULL, &gl) == 0 && gl.gl_pathc > 0) {
			const char *h2c = gl.gl_pathv[0];
			if (!h2c_overridden) {
				strncpy(g_h2c_dev, h2c, sizeof(g_h2c_dev) - 1);
				found = true;
			}
			/* Derive C2H by replacing -MM-0 with -MM-1 */
			if (!c2h_overridden) {
				strncpy(g_c2h_dev, h2c, sizeof(g_c2h_dev) - 1);
				char *p = strstr(g_c2h_dev, "-MM-0");
				if (p) { p[4] = '1'; found = true; }
			}
			/* Derive QDMA device name: strip /dev/ and suffix -MM-0 */
			if (!qdma_overridden) {
				const char *base = strrchr(h2c, '/');
				if (base) {
					strncpy(g_qdma_dev, base + 1, sizeof(g_qdma_dev) - 1);
					char *p = strstr(g_qdma_dev, "-MM-0");
					if (p) *p = '\0';
				}
			}
		}
		globfree(&gl);

		/* Scan for BAR2 resource2 belonging to a QDMA/Xilinx device */
		if (!bar2_overridden) {
			memset(&gl, 0, sizeof(gl));
			if (glob("/sys/bus/pci/devices/*/resource2", 0, NULL, &gl) == 0) {
				for (size_t i = 0; i < gl.gl_pathc; i++) {
					/* Check vendor — Xilinx=0x10ee or AMD=0x1d0f */
					char vendor_path[512];
					snprintf(vendor_path, sizeof(vendor_path), "%.*s/vendor",
					         (int)(strrchr(gl.gl_pathv[i], '/') - gl.gl_pathv[i]),
					         gl.gl_pathv[i]);
					FILE *vf = fopen(vendor_path, "r");
					if (vf) {
						unsigned int vendor = 0;
						fscanf(vf, "%x", &vendor);
						fclose(vf);
						if (vendor == 0x10ee || vendor == 0x1d0f) {
							strncpy(g_reg_dev, gl.gl_pathv[i],
							        sizeof(g_reg_dev) - 1);
							found = true;
							break;
						}
					}
				}
			}
			globfree(&gl);
		}
	}
	return found;
}

/* Print the active device configuration.  Called at startup so the user
 * can see what paths are being used and override if wrong. */
static void print_device_config(void)
{
	printf("\n[pcie_host] Device configuration:\n");
	printf("  H2C (Host→Card DMA) : %s\n", g_h2c_dev);
	printf("  C2H (Card→Host DMA) : %s\n", g_c2h_dev);
	printf("  BAR2 resource       : %s\n", g_reg_dev);
	printf("  QDMA device (dmactl): %s\n", g_qdma_dev);
	printf("  dma-ctl binary      : %s\n", g_dmactl);
	printf("  Run with --help to see how to change these or discover devices.\n\n");
}

/* Called from main() to apply CLI overrides and auto-detect missing paths. */
void pcie_host_configure_devices(const char *h2c, const char *c2h,
                                  const char *bar2, const char *qdma,
                                  const char *dmactl_path)
{
	bool h2c_ov = false, c2h_ov = false, bar2_ov = false, qdma_ov = false;
	if (h2c   && *h2c)   { strncpy(g_h2c_dev,  h2c,         sizeof(g_h2c_dev)  - 1); h2c_ov  = true; }
	if (c2h   && *c2h)   { strncpy(g_c2h_dev,  c2h,         sizeof(g_c2h_dev)  - 1); c2h_ov  = true; }
	if (bar2  && *bar2)  { strncpy(g_reg_dev,   bar2,        sizeof(g_reg_dev)  - 1); bar2_ov = true; }
	if (qdma  && *qdma)  { strncpy(g_qdma_dev,  qdma,        sizeof(g_qdma_dev) - 1); qdma_ov = true; }
	if (dmactl_path && *dmactl_path)
		strncpy(g_dmactl, dmactl_path, sizeof(g_dmactl) - 1);

	/* Auto-detect any paths that weren't explicitly overridden */
	auto_detect_devices(h2c_ov, c2h_ov, bar2_ov, qdma_ov);

	print_device_config();
}

GIOChannel* io_stdin = NULL;
guint  add_watch;

int flag = 0;

/* Verify that all required device nodes and binaries exist and are
 * accessible before prompting the user for use-case parameters.
 * Returns true if everything is ready, false if setup is incomplete.
 * On failure, prints a targeted diagnosis and the full discovery help. */
static bool verify_devices(void)
{
	bool ok = true;

	/* H2C QDMA character device ---------------------------------------- */
	if (access(g_h2c_dev, F_OK) != 0) {
		fprintf(stderr,
		        "\n[ERROR] H2C device not found: %s\n"
		        "  The QDMA H2C queue node does not exist.\n"
		        "  Either the QDMA PF driver is not loaded or queue 0 is not started.\n",
		        g_h2c_dev);
		ok = false;
	} else if (access(g_h2c_dev, R_OK | W_OK) != 0) {
		fprintf(stderr,
		        "\n[ERROR] H2C device not accessible: %s (%s)\n"
		        "  Check permissions — try: sudo chmod a+rw %s\n",
		        g_h2c_dev, strerror(errno), g_h2c_dev);
		ok = false;
	}

	/* C2H QDMA character device ---------------------------------------- */
	if (access(g_c2h_dev, F_OK) != 0) {
		fprintf(stderr,
		        "\n[ERROR] C2H device not found: %s\n"
		        "  The QDMA C2H queue node does not exist.\n"
		        "  Either the QDMA PF driver is not loaded or queue 1 is not started.\n",
		        g_c2h_dev);
		ok = false;
	} else if (access(g_c2h_dev, R_OK | W_OK) != 0) {
		fprintf(stderr,
		        "\n[ERROR] C2H device not accessible: %s (%s)\n"
		        "  Check permissions — try: sudo chmod a+rw %s\n",
		        g_c2h_dev, strerror(errno), g_c2h_dev);
		ok = false;
	}

	/* BAR2 PCIe register resource --------------------------------------- */
	if (access(g_reg_dev, F_OK) != 0) {
		fprintf(stderr,
		        "\n[ERROR] BAR2 resource not found: %s\n"
		        "  The VEK385 PCIe endpoint may not be enumerated by the host.\n"
		        "  Check: lspci | grep -i 'xilinx\\|versal\\|qdma'\n",
		        g_reg_dev);
		ok = false;
	} else if (access(g_reg_dev, R_OK | W_OK) != 0) {
		fprintf(stderr,
		        "\n[ERROR] BAR2 resource not accessible: %s (%s)\n"
		        "  Check permissions — try: sudo chmod a+rw %s\n",
		        g_reg_dev, strerror(errno), g_reg_dev);
		ok = false;
	}

	/* dma-ctl binary (needed for qdma_reset between runs) -------------- */
	if (access(g_dmactl, F_OK) != 0) {
		fprintf(stderr,
		        "\n[WARNING] dma-ctl not found: %s\n"
		        "  QDMA queue reset between runs will not work.\n"
		        "  Install the QDMA host tools package or pass --dmactl <path>.\n",
		        g_dmactl);
		/* dma-ctl absence is a warning only — allow startup to continue */
	}

	if (!ok) {
		fprintf(stderr,
		        "\n[INFO] QDMA queue setup commands:\n"
		        "  # Load QDMA PF driver (if not already loaded):\n"
		        "  sudo modprobe qdma-pf\n"
		        "\n"
		        "  # Start H2C queue 0 and C2H queue 1:\n"
		        "  sudo %s %s q add  idx 0 dir h2c mode mm\n"
		        "  sudo %s %s q add  idx 1 dir c2h mode mm\n"
		        "  sudo %s %s q start idx 0 dir h2c\n"
		        "  sudo %s %s q start idx 1 dir c2h\n"
		        "\n"
		        "  # Verify queues are running:\n"
		        "  %s %s q list\n"
		        "\n",
		        g_dmactl, g_qdma_dev,
		        g_dmactl, g_qdma_dev,
		        g_dmactl, g_qdma_dev,
		        g_dmactl, g_qdma_dev,
		        g_dmactl, g_qdma_dev);
		print_device_help();
	}

	return ok;
}

	static gboolean
handle_keyboard (GIOChannel *source, GIOCondition , gpointer *)
{
	gchar    *str   = NULL;
	gboolean ret    = TRUE;

	if (g_io_channel_read_line (source, &str, NULL, NULL, NULL) != G_IO_STATUS_NORMAL) {
		return FALSE;
	}
	if (g_ascii_tolower (str[0]) == 'q') {
		printf("Quitting usecase\n");
		app_running = false;   /* signal threads to stop before touching HW */
		set_sig = ((uint32_t *)(trans.map_base + PCIEP_SET_SIG));
		*set_sig = 0x1;
		g_source_remove(add_watch);
		g_io_channel_unref (io_stdin);
		flag = 0;
	}
	g_free (str);

	return ret;
}

int cb_init(circular_buffer *cb, size_t capacity, size_t sz)
{
	cb->buffer = (char *)malloc(capacity * sz);
	if (cb->buffer == NULL) {
		printf("[cb_init] ERROR: malloc failed for %zu bytes\n", capacity * sz);
		return -ENOMEM;
	}

	cb->buffer_end = (char *)cb->buffer + (capacity * sz);
	cb->capacity = capacity;
	cb->index = 0;
	cb->sz = sz;
	cb->head = cb->buffer;
	cb->tail = cb->buffer;
	cb->drop_count = 0;
	pthread_mutex_init(&cb->lock, NULL);

	printf("[cb_init] capacity=%zu frames, frame_sz=%zu bytes, total=%zu KB\n",
		capacity, sz, (capacity * sz) / 1024);
	return 0;
}

int cb_enque(circular_buffer *cb, char *data)
{
	pthread_mutex_lock(&cb->lock);
	if (cb->index == cb->capacity) {
		cb->drop_count++;
		if (cb->drop_count % 30 == 1)
			printf("[cb_enque] WARN: buffer full (cap=%zu), frame dropped "
			       "total_drops=%zu\n", cb->capacity, cb->drop_count);
		pthread_mutex_unlock(&cb->lock);
		return 1;
	}

	memcpy(cb->head, data, cb->sz);
	cb->head = cb->head + cb->sz;
	if (cb->head == cb->buffer_end)
		cb->head = cb->buffer;
	cb->index++;
	pthread_mutex_unlock(&cb->lock);
	return 0;
}

int cb_deque(circular_buffer *cb, char *data)
{
	pthread_mutex_lock(&cb->lock);
	if (cb->index == 0) {
		pthread_mutex_unlock(&cb->lock);
		return 1;
	}

	memcpy(data, cb->tail, cb->sz);
	cb->tail = (char *)cb->tail + cb->sz;
	if (cb->tail == cb->buffer_end)
		cb->tail = cb->buffer;
	cb->index--;
	pthread_mutex_unlock(&cb->lock);
	return 0;
}

/*
 * Only two use cases are currently supported:
 *   UC1 (user menu "1") = MIPI live → bypass → host display   (enum 1)
 *   UC2 (user menu "2") = File from host → bypass → host display (enum 2)
 *
 * Values must match the EP enum in pcie_main.h — they are written to BAR2.
 */
typedef enum {
    VGST_USECASE_TYPE_NONE                  = 0,
    VGST_USECASE_TYPE_MIPISRC_TO_HOST_BYPASS = 1,  /* UC1 */
    VGST_USECASE_TYPE_APPSRC_TO_HOST_BYPASS  = 2,  /* UC2 */
    VGST_USECASE_TYPE_MAX,                          /* = 3, bounds sentinel */
    VGST_USECASE_EXIT                        = 9,   /* exit application */
} VGST_USECASE_TYPE;

/* Re-register SIGINT/SIGTERM handler at the start of each run.
 * SA_RESETHAND auto-deregisters after one signal delivery, so without
 * re-registration, Ctrl+C kills the process on the second run. */
static void install_sigint_handler(void)
{
	struct sigaction sa;
	sa.sa_handler = sigint_handler;
	sa.sa_flags   = SA_RESETHAND;
	sigemptyset(&sa.sa_mask);
	sigaction(SIGINT,  &sa, NULL);
	sigaction(SIGTERM, &sa, NULL);
}

/* Clear RC-side BAR2 registers so the EP sees a clean state on open().
 *
 * NOTE on EP-side registers (0x80-0xBF from BAR2):
 * The pcie-reg-space PL IP uses SEPARATE register domains.  Host writes to
 * BAR2 offsets 0x80+ go to the HOST bank — NOT the EP bank.  Only the EP
 * can modify its own registers (via AXI at offsets 0x00-0x3F, which the IP
 * maps to host-visible offsets 0x80-0xBF with a +0x80 domain crossing).
 *
 * Stale EP-side READY flags are cleared by drain_stale_ep_ready() below,
 * which uses the EP driver's IRQ mechanism (TRANSFER_DONE triggers an IRQ
 * whose handler clears the READY bit).  Must be called after mmap. */
static void reset_bar2_state(void)
{
	*((volatile uint32_t *)(trans.map_base + PCIEP_SET_SIG)) = 0x0;
	*((volatile uint32_t *)(trans.map_base + PCIRC_HOST_DONE)) = 0x0;
	*((volatile uint32_t *)(trans.map_base + PCIRC_READ_BUFFER_TRANSFER_DONE)) = 0x0;
	*((volatile uint32_t *)(trans.map_base + PCIRC_WRITE_BUFFER_TRANSFER_DONE)) = 0x0;
	*((volatile uint32_t *)(trans.map_base + PCIRC_UCASE_SET)) = 0x0;
	*((volatile uint32_t *)(trans.map_base + PCIRC_FMT_SET)) = 0x0;
}

/* Drain stale EP-side READY flags via the EP driver's IRQ mechanism.
 *
 * After FLR or a previous run, the PL registers may retain
 * PCIEP_WRITE_BUFFER_READY=1 and/or PCIEP_READ_BUFFER_READY=1.
 * The host CANNOT write to those EP-domain registers directly (see
 * note in reset_bar2_state).  Instead, writing PCIRC_*_TRANSFER_DONE=1
 * triggers the pcie-reg-space interrupt, and the EP driver's IRQ handler
 * (registered at probe via devm_request_irq — always active even when no
 * EP app is running) clears the corresponding READY bit.
 *
 * Must be called AFTER reset_bar2_state() (which zeros TRANSFER_DONE)
 * and BEFORE the user starts the EP application (before the
 * "Please run pcie-gst-app" prompt), so the stale complete() from
 * the IRQ handler is safely reset by reinit_completion() in the EP
 * driver's open(). */
static void drain_stale_ep_ready(void)
{
	uint32_t ready;

	/* ── C2H direction: PCIEP_WRITE_BUFFER_READY ── */
	ready = *((volatile uint32_t *)(trans.map_base + PCIEP_WRITE_BUFFER_READY));
	if (ready & 0x1) {
		printf("[init] Stale C2H READY=0x%x — triggering EP IRQ to clear...\n", ready);
		*((volatile uint32_t *)(trans.map_base + PCIRC_WRITE_BUFFER_TRANSFER_DONE)) = 0x1;
		for (int i = 0; i < 50; i++) {           /* 500 ms timeout */
			usleep(10000);
			ready = *((volatile uint32_t *)(trans.map_base + PCIEP_WRITE_BUFFER_READY));
			if (!(ready & 0x1)) break;
		}
		*((volatile uint32_t *)(trans.map_base + PCIRC_WRITE_BUFFER_TRANSFER_DONE)) = 0x0;
		printf("[init] C2H READY drain: %s\n",
		       (ready & 0x1) ? "FAILED (EP IRQ not working — stale state persists)"
		                      : "OK");
	}

	/* ── H2C direction: PCIEP_READ_BUFFER_READY ── */
	ready = *((volatile uint32_t *)(trans.map_base + PCIEP_READ_BUFFER_READY));
	if (ready & 0x1) {
		printf("[init] Stale H2C READY=0x%x — triggering EP IRQ to clear...\n", ready);
		*((volatile uint32_t *)(trans.map_base + PCIRC_READ_BUFFER_TRANSFER_DONE)) = 0x1;
		for (int i = 0; i < 50; i++) {
			usleep(10000);
			ready = *((volatile uint32_t *)(trans.map_base + PCIEP_READ_BUFFER_READY));
			if (!(ready & 0x1)) break;
		}
		*((volatile uint32_t *)(trans.map_base + PCIRC_READ_BUFFER_TRANSFER_DONE)) = 0x0;
		printf("[init] H2C READY drain: %s\n",
		       (ready & 0x1) ? "FAILED (EP IRQ not working — stale state persists)"
		                      : "OK");
	}
}

/* Reset QDMA queues (stop → start) so the next run gets fresh descriptor
 * rings.  Only stop+start — no delete+add — so the device nodes in /dev/
 * are preserved along with the permissions the user set at initial setup.
 * Must be called AFTER closing all QDMA device fds. */
static void qdma_reset(void)
{
	/* Allocate the command buffer on the heap so the size adapts to the
	 * actual lengths of g_dmactl and g_qdma_dev rather than assuming a
	 * fixed upper bound on the stack. */
	size_t cmd_len = strlen(g_dmactl) + strlen(g_qdma_dev) + 64;
	char *cmd = (char *)malloc(cmd_len);
	if (!cmd) {
		printf("[qdma_reset] ERROR: out of memory — queues not reset\n");
		return;
	}
	printf("[qdma_reset] Resetting QDMA queues...\n");

	/* Stop both queues to flush pending descriptors */
	snprintf(cmd, cmd_len, "%s %s q stop idx 0 dir h2c 2>/dev/null", g_dmactl, g_qdma_dev);
	system(cmd);
	snprintf(cmd, cmd_len, "%s %s q stop idx 1 dir c2h 2>/dev/null", g_dmactl, g_qdma_dev);
	system(cmd);

	/* Restart with fresh descriptor rings */
	int r = 0;
	snprintf(cmd, cmd_len, "%s %s q start idx 0 dir h2c", g_dmactl, g_qdma_dev);
	r |= system(cmd);
	snprintf(cmd, cmd_len, "%s %s q start idx 1 dir c2h", g_dmactl, g_qdma_dev);
	r |= system(cmd);

	if (r == 0)
		printf("[qdma_reset] QDMA queues reset — ready for next run\n");
	else
		printf("[qdma_reset] WARNING: dma-ctl errors (rc=%d) — "
		       "check '%s' exists and syntax matches your QDMA driver\n", r, g_dmactl);
	free(cmd);
}

int cmaincall(struct MainWindow *frm)
{
	const char *h2c_device = H2C_DEVICE;
	const char *c2h_device = C2H_DEVICE;
	int ret;

	/* Verify device nodes BEFORE showing any menu.
	 * If QDMA queues are not configured the user should get immediate
	 * setup guidance, not discover the problem after answering prompts. */
	if (!verify_devices()) {
		fprintf(stderr,
		        "[ERROR] One or more required devices are missing or inaccessible.\n"
		        "        Please configure the QDMA queues (see setup commands above)\n"
		        "        and restart the application.\n\n");
		frm->getVidFrame0()->ctrlc();
		return -1;
	}

	while(1) {
		usecase_sel = 0;
		printf("Enter 1 to run  : MIPI --> pciesink --> displayonhost  (UC1)\n");
		printf("Enter 2 to run  : RAW Video File on Host --> pciesrc --> pciesink --> displayonhost (UC2)\n");
		printf("Enter 9 to \t: Exit application\n");

		printf("Enter your choice:");
		fflush(stdout);
		usecase_sel = 0;
		{
			/* Use a helper lambda/block to drain stdin after every read so that
			 * non-integer input (e.g. 'q' typed at the menu) never sticks in
			 * the buffer and causes an infinite print loop. */
			char line[64] = {0};
			if (fgets(line, sizeof(line), stdin) == NULL) {
				/* EOF / Ctrl-D → exit cleanly */
				frm->getVidFrame0()->ctrlc();
				return 0;
			}
			if (sscanf(line, "%d", &usecase_sel) != 1) {
				/* Non-integer input typed at the menu — re-prompt */
				printf("Enter choice 1, 2, or 9\n");
				continue;
			}
		}

		/* User input 1/2 maps directly to enum values UC1=1, UC2=2.
		 * No remapping needed. */

		/* Format selection — written to PCIRC_FMT_SET so the EP sets
		 * GStreamer caps and frame-size accordingly. */
		if (usecase_sel != VGST_USECASE_EXIT &&
		    usecase_sel != VGST_USECASE_TYPE_NONE) {
			int fmt_choice = 0;
			while (fmt_choice < 1 || fmt_choice > 3) {
				printf("Select video format:\n"
				       "  1. NV12   (4:2:0 semi-planar, default)\n"
				       "  2. YUY2   (4:2:2 packed)\n"
				       "  3. RGB888 (packed R-G-B)\n"
				       "Enter choice [1-3]: ");
				fflush(stdout);
				char line[64] = {0};
				if (fgets(line, sizeof(line), stdin) == NULL) {
					fmt_choice = 1;  /* EOF → default NV12 */
					break;
				}
				if (sscanf(line, "%d", &fmt_choice) != 1 ||
				    fmt_choice < 1 || fmt_choice > 3) {
					printf("Invalid choice — please enter 1, 2, or 3.\n");
					fmt_choice = 0;  /* reset to loop again */
				}
			}
			format_type = (fmt_choice == 2) ? FMT_YUY2 :
			              (fmt_choice == 3) ? FMT_RGB  : FMT_NV12;
			printf("[format] selected: %s\n",
			       (format_type == FMT_YUY2) ? "YUY2"   :
			       (format_type == FMT_RGB)  ? "RGB888" : "NV12");
		}

		switch(usecase_sel)
		{
			case VGST_USECASE_TYPE_MIPISRC_TO_HOST_BYPASS:
				ret = mipi_displayonhost(frm,c2h_device);
				if (ret < 0)
					printf("[cmaincall] UC1 returned error %d\n", ret);
				break;
			case VGST_USECASE_TYPE_APPSRC_TO_HOST_BYPASS:
				ret = host2host_without_filter(frm,h2c_device,c2h_device);
				if (ret < 0)
					printf("[cmaincall] UC2 returned error %d\n", ret);
				break;
			case VGST_USECASE_EXIT:
				frm->getVidFrame0()->ctrlc();
				return 0;
			default :
				printf("Enter choice 1, 2, or 9\n");
				break;
		}


	}
}

int mipi_displayonhost(struct MainWindow *frm,const char *c2h_device)
{
	int rc;
	volatile unsigned int *input_res = NULL;
	volatile unsigned int *ucase_params;
	volatile unsigned int *fps_mode_params;
	int choice;
	pthread_t  thread3;
	bool did_dma = false;

	{
		int choice = 0;
		while (choice != 1 && choice != 2) {
			printf("Select resolution:\n");
			printf("  1. 3840x2160 (4K)\n");
			printf("  2. 1920x1080 (FHD, default)\n");
			printf("Enter your choice [1-2]: ");
			fflush(stdout);
			char _ln[64] = {0};
			if (fgets(_ln, sizeof(_ln), stdin) == NULL) {
				choice = 2;  /* EOF → default FHD */
				break;
			}
			if (sscanf(_ln, "%d", &choice) != 1 ||
			    (choice != 1 && choice != 2)) {
				printf("Invalid choice — please enter 1 (4K) or 2 (FHD).\n");
				choice = 0;
			}
		}
		if (choice == 1) {
			in_width  = 3840;
			in_height = 2160;
		} else {
			in_width  = 1920;
			in_height = 1080;
		}
	}
	app_running = true;
	rc = 0;

	printf("[mipi_displayonhost] Starting: %dx%d @ %d fps, usecase=%d\n",
		in_width, in_height, fps, usecase_sel);

	frm->getVidFrame0()->setResolution(in_width,in_height,30);
	frm->getVidFrame0()->config_frame();

	trans.c2h_fd = open(c2h_device, O_RDWR);
	if (trans.c2h_fd < 0) {
		fprintf(stderr, "[ERROR] Cannot open C2H device '%s': %s\n"
		        "  Run 'ls /dev/qdma*' to list available QDMA devices.\n"
		        "  Use --c2h <path> to specify the correct device.\n",
		        c2h_device, strerror(errno));
		print_device_help();
		rc = -EINVAL;
		goto out;
	}
	trans.reg_fd = open(REG_DEVICE_NAME, O_RDWR);
	if (trans.reg_fd < 0) {
		fprintf(stderr, "[ERROR] Cannot open BAR2 resource '%s': %s\n"
		        "  Run 'lspci | grep -i xilinx' to find the PCIe BDF,\n"
		        "  then check /sys/bus/pci/devices/<BDF>/resource2.\n"
		        "  Use --bar2 <path> to specify the correct path.\n",
		        REG_DEVICE_NAME, strerror(errno));
		print_device_help();
		rc = -EINVAL;
		goto c2h_out;
	}

	trans.map_base = (char *)mmap(0, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, trans.reg_fd, 0);
	if (trans.map_base == (void *)-1) {
		printf("Memory mapped at address %p.\n", trans.map_base);
		fflush(stdout);
		rc = -ENOMEM;
		goto reg_fd;

	}

	/* Clear RC-side BAR2 registers + drain stale EP-side READY flags */
	reset_bar2_state();
	drain_stale_ep_ready();

	/* Re-register SIGINT handler (SA_RESETHAND deregistered it on first use) */
	install_sigint_handler();

	u_case = usecase_sel;
	ucase_params = ((uint32_t *)(trans.map_base + PCIRC_UCASE_SET));
	*ucase_params = u_case & 0xFFFFFFFF;

	/* Write video format to PCIRC_FMT_SET so EP selects correct GStreamer caps */
	*((volatile uint32_t *)(trans.map_base + PCIRC_FMT_SET)) = (uint32_t)format_type;

	fps = 30;
	fps_mode_params = ((uint32_t *)(trans.map_base + PCIRC_FPS_SET));
	*fps_mode_params = fps & 0xFFFFFFFF;

	input_res = ((uint32_t *)(trans.map_base + PCIRC_RAW_RESOLUTION));
	*input_res = (in_height << 16) | in_width;

	printf(KGREEN "\nPlease run pcie-gst-app from endpoint (To launch endpoint application)\n" RESET);
	printf(KRED "To quit usecase, hit <q+enter> from host \n\n" RESET);

	io_stdin = g_io_channel_unix_new (fileno (stdin));
	add_watch = g_io_add_watch (io_stdin, G_IO_IN, (GIOFunc)handle_keyboard, NULL);
	flag = 1;
	rc = cb_init(&queue_frame, HOST_DISPLAY_RING_DEPTH, frame_bytes(in_width, in_height));
	if (rc < 0)
		goto reg_unmap;

	printf("[mipi_displayonhost] queue_frame: %d frames × %zu bytes\n",
		HOST_DISPLAY_RING_DEPTH, frame_bytes(in_width, in_height));

	did_dma = true;
	g_h2c_seen_ready = false;
	g_c2h_seen_ready = false;
	pthread_create( &thread3, NULL, &pcie_dma_write, NULL);

	pthread_join( thread3, NULL);

	app_running = false;
	while (queue_frame.index)
		sched_yield();
	printf("[mipi_displayonhost] Queue drained, signalling host done\n");
	host_done = ((uint32_t *)(trans.map_base + PCIRC_HOST_DONE));
	*host_done = 0x1;
	/* Signal EP to stop so host_app_reg_read calls g_main_loop_quit */
	*((volatile uint32_t *)(trans.map_base + PCIEP_SET_SIG)) = 0x1;

	if (flag == 1) {
		g_source_remove(add_watch);
		g_io_channel_unref (io_stdin);
		flag = 0;
	}

	free(queue_frame.buffer);
reg_unmap:
	if (munmap(trans.map_base, MAP_SIZE) == -1)
		printf("error unmap\n");
	trans.map_base = NULL;
reg_fd :
	if (trans.reg_fd >= 0) {
		close(trans.reg_fd);
		trans.reg_fd = -1;
	}
c2h_out:
	if (trans.c2h_fd >= 0) {
		close(trans.c2h_fd);
		trans.c2h_fd = -1;
	}
out:
	if (did_dma)
		qdma_reset();
	app_running = false;
	return rc;
}

int host2host_without_filter(struct MainWindow *frm, const char *h2c_device, const char *c2h_device)
{
	ssize_t rc = 0;
	volatile unsigned int *host_done;
	volatile unsigned int *infile_len;
	unsigned long int file_len;
	volatile unsigned int *input_res = NULL;
	volatile unsigned int *fps_mode_params;
	char infilename[100];
	int choice = 2;   /* default FHD if fgets fails */
	volatile unsigned int *ucase_params;
	pthread_t thread1, thread2, thread3;
	bool did_dma = false;

	{
		int choice = 0;
		while (choice != 1 && choice != 2) {
			printf("Select resolution:\n");
			printf("  1. 3840x2160 (4K)\n");
			printf("  2. 1920x1080 (FHD, default)\n");
			printf("Enter your choice [1-2]: ");
			fflush(stdout);
			char _ln[64] = {0};
			if (fgets(_ln, sizeof(_ln), stdin) == NULL) {
				choice = 2;  /* EOF → default FHD */
				break;
			}
			if (sscanf(_ln, "%d", &choice) != 1 ||
			    (choice != 1 && choice != 2)) {
				printf("Invalid choice — please enter 1 (4K) or 2 (FHD).\n");
				choice = 0;
			}
		}
		if (choice == 1) {
			in_width  = 3840;
			in_height = 2160;
		} else {
			in_width  = 1920;
			in_height = 1080;
		}
	}

	app_running = true;
	frm->getVidFrame0()->setResolution(in_width,in_height,30);
	frm->getVidFrame0()->config_frame();

	trans.h2c_fd = open(h2c_device, O_RDWR);
	if (trans.h2c_fd < 0) {
		fprintf(stderr, "[ERROR] Cannot open H2C device '%s': %s\n"
		        "  Run 'ls /dev/qdma*' to list available QDMA devices.\n"
		        "  Use --h2c <path> to specify the correct device.\n",
		        h2c_device, strerror(errno));
		print_device_help();
		app_running = false;
		return -EINVAL;
	}

	trans.c2h_fd = open(c2h_device, O_RDWR);
	if (trans.c2h_fd < 0) {
		fprintf(stderr, "[ERROR] Cannot open C2H device '%s': %s\n"
		        "  Run 'ls /dev/qdma*' to list available QDMA devices.\n"
		        "  Use --c2h <path> to specify the correct device.\n",
		        c2h_device, strerror(errno));
		print_device_help();
		rc = -EINVAL;
		goto h2c_out;
	}

	trans.reg_fd = open(REG_DEVICE_NAME, O_RDWR);
	if (trans.reg_fd < 0) {
		fprintf(stderr, "[ERROR] Cannot open BAR2 resource '%s': %s\n"
		        "  Run 'lspci | grep -i xilinx' to find the PCIe BDF,\n"
		        "  then check /sys/bus/pci/devices/<BDF>/resource2.\n"
		        "  Use --bar2 <path> to specify the correct path.\n",
		        REG_DEVICE_NAME, strerror(errno));
		print_device_help();
		rc = -EINVAL;
		goto c2h_out;
	}

	/* map one page */
	trans.map_base = (char *) mmap(0, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, trans.reg_fd, 0);
	if (trans.map_base == (void *)-1) {
		printf("Memory mapped at address %p.\n", trans.map_base);
		fflush(stdout);
		rc = -ENOMEM;
		goto reg_fd;

	}

	/* Clear RC-side BAR2 registers + drain stale EP-side READY flags */
	reset_bar2_state();
	drain_stale_ep_ready();

	/* Re-register SIGINT handler (SA_RESETHAND deregistered it on first use) */
	install_sigint_handler();

	printf("Enter input filename with path to transfer:");
	{
		/* Use fgets to consume the full line (including \\n) so no stale newline
		 * is left in the libc stdio buffer to cause spurious 'Enter choice 1,2,9'
		 * error prompts when the menu re-appears after this run. */
		char _ln[256] = {0};
		if (fgets(_ln, sizeof(_ln), stdin) != NULL)
			sscanf(_ln, "%99s", infilename);
	}
	trans.infname = infilename;
	trans.infile_fd = open(infilename, O_RDONLY);
	if (trans.infile_fd < 0) {
		fprintf(stderr, "unable to open input file %s, %d.\n",
				infilename, trans.infile_fd);
		rc = -EINVAL;
		goto reg_unmap;
	}

	fps = 30;
	fps_mode_params = ((uint32_t *)(trans.map_base + PCIRC_FPS_SET));
	*fps_mode_params = fps & 0xFFFFFFFF;


	/* Get the input file length  */
	if (trans.infile_fd > 0) {
		file_len = lseek(trans.infile_fd, 0, SEEK_END);
		if (file_len <= 0)
		{
			printf("failed to lseek %s numbytes %lu\n", trans.infname, file_len);
			rc = -EINVAL;
			goto infile_out;
		}
		/* reset the file position indicator to
		the beginning of the file */
		lseek(trans.infile_fd, 0L, SEEK_SET);

		/* Advise kernel to read the input file sequentially and
		 * start pulling the entire file into the page cache now.
		 * Without this, the first pass through an uncached file
		 * incurs per-frame disk I/O latency (~30-50 ms on HDD)
		 * that limits throughput well below 30 fps. */
		posix_fadvise(trans.infile_fd, 0, file_len, POSIX_FADV_SEQUENTIAL);
		posix_fadvise(trans.infile_fd, 0, file_len, POSIX_FADV_WILLNEED);

		infile_len = ((uint32_t *)(trans.map_base + PCIRC_GET_FILE_LENGTH));
		*infile_len = (unsigned int)(file_len & 0xFFFFFFFF);
		infile_len = ((uint32_t *)(trans.map_base + PCIRC_GET_FILE_LENGTH - 4));
		*infile_len = (unsigned int)(file_len >> 32 & 0xFFFFFFFF);
	}

	/* setting input resolution */
	input_res = ((uint32_t *)(trans.map_base + PCIRC_RAW_RESOLUTION));
	*input_res = (in_height << 16) | in_width;

	/* setting Usecase type */
	u_case = usecase_sel;
	ucase_params = ((uint32_t *)(trans.map_base + PCIRC_UCASE_SET));
	*ucase_params = u_case & 0xFFFFFFFF;

	/* Write video format to PCIRC_FMT_SET so EP sets correct GStreamer caps */
	*((volatile uint32_t *)(trans.map_base + PCIRC_FMT_SET)) = (uint32_t)format_type;

	printf(KGREEN "\nPlease run pcie-gst-app from endpoint (To launch endpoint application)\n" RESET);
	printf(KRED "To quit usecase, hit <q+enter> from host \n\n" RESET);

	/* Register keyboard handler via GLib IO watch.
	 * cmaincall() runs in a QtConcurrent thread while QApplication::exec()
	 * keeps the Qt/GLib event loop alive on the main thread, so this callback
	 * fires even while pthread_join() blocks below. */
	io_stdin = g_io_channel_unix_new (fileno (stdin));
	add_watch = g_io_add_watch (io_stdin, G_IO_IN, (GIOFunc)handle_keyboard, NULL);
	flag = 1;

	rc = cb_init(&queue_frame, HOST_DISPLAY_RING_DEPTH, frame_bytes(in_width, in_height));
	if (rc < 0)
		goto reg_unmap;

	rc = cb_init(&queue_file_frame, HOST_FILE_RING_DEPTH, frame_bytes(in_width, in_height));
	if (rc < 0)
		goto free_qframe;

	did_dma = true;
	g_h2c_seen_ready = false;
	g_c2h_seen_ready = false;
	pthread_create( &thread2, NULL, &file_read, NULL);
	pthread_create( &thread1, NULL, &pcie_dma_read, NULL);
	pthread_create( &thread3, NULL, &pcie_dma_write, NULL);

	pthread_join( thread3, NULL);
	pthread_join( thread1, NULL);
	pthread_join( thread2, NULL);

	while(queue_frame.index)
		sched_yield();
	host_done = ((uint32_t *)(trans.map_base + PCIRC_HOST_DONE));
	*host_done = 0x1;

	/* Signal EP app to stop — host_app_reg_read on EP polls PCIRC_READ_SIG
	 * (PCIEP_SET_SIG on host side) and sends EOS to the GStreamer pipeline
	 * when it detects the signal, causing pcie_gst_app to exit cleanly. */
	*((volatile uint32_t *)(trans.map_base + PCIEP_SET_SIG)) = 0x1;

	if (flag == 1) {
		g_source_remove (add_watch);
		g_io_channel_unref (io_stdin);
		flag = 0;
	}

	*infile_len = 0x0;
	free(queue_file_frame.buffer);

free_qframe:
	free(queue_frame.buffer);
infile_out:
	if (trans.infile_fd >= 0)
		close(trans.infile_fd);
reg_unmap:
	if (munmap(trans.map_base, MAP_SIZE) == -1)
		printf("error unmap\n");
	trans.map_base = NULL;
reg_fd:
	if (trans.reg_fd >= 0) {
		close(trans.reg_fd);
		trans.reg_fd = -1;
	}
c2h_out:
	if (trans.c2h_fd >= 0) {
		close(trans.c2h_fd);
		trans.c2h_fd = -1;
	}
h2c_out:
	if (trans.h2c_fd >= 0) {
		close(trans.h2c_fd);
		trans.h2c_fd = -1;
	}
	if (did_dma)
		qdma_reset();
	app_running = false;
	return rc;

}

void *file_read (void *)
{
	char *read_allocated = NULL;
	int size;
	int iter, i, rc;
	struct stat st;
	unsigned long int file_size;
	int num_cpu;
#ifdef T_DEBUG
	struct timespec ts_start, ts_end;
	int k = 0;
#endif
	cpu_set_t cpuset;

	size = (int)frame_bytes(in_width, in_height);

	num_cpu = get_nprocs();
	if (num_cpu > 0 && num_cpu > 4) {
		CPU_ZERO(&cpuset);
		CPU_SET(3,&cpuset);
		rc = pthread_setaffinity_np(pthread_self(), sizeof(cpu_set_t), &cpuset);
		if (rc != 0)
			printf("set affinity failed\n");
	}
	fstat(trans.infile_fd, &st);
	file_size = st.st_size;
	posix_memalign((void **)&read_allocated, 4096 /*alignment */ , size + 4096);
	if (!read_allocated) {
		fprintf(stderr, "OOM %u.\n", size + 4096);
		rc = -ENOMEM;
		return NULL;
	}

	iter = (file_size / size);
	for(i = 0; i < iter; i++)   {
		if (!app_running) break;   /* user quit — stop producing frames */
#ifdef T_DEBUG
		if(k==1)
			clock_gettime(CLOCK_MONOTONIC, &ts_start);
#endif
		if (trans.infile_fd > 0) {
			rc = read_to_buffer(trans.infname, trans.infile_fd, read_allocated, size, 0);
			if (rc < 0) {
				printf("read to buffer failed size %d rc %d", size, rc);
				return NULL;
			}
		}
		rc = cb_enque(&queue_file_frame, read_allocated);
		if (rc == 1) {
			/* Wait for pcie_dma_read to consume a slot.
			 * Check app_running so we can exit if the user quit or
			 * pcie_dma_read already exited — otherwise this spins
			 * forever and pthread_join(thread2) never returns. */
			do {
				if (!app_running) goto file_read_out;
				sched_yield();
			} while(queue_file_frame.index == queue_file_frame.capacity);
			cb_enque(&queue_file_frame, read_allocated);
		}
#ifdef T_DEBUG
		if(k==30){
			clock_gettime(CLOCK_MONOTONIC, &ts_end);
			double time_spent = (ts_end.tv_sec - ts_start.tv_sec) +
				(ts_end.tv_nsec - ts_start.tv_nsec) / BILLION;
			printf("[file_read] 30 frames read in %.3f s (%.1f fps)\n",
			       time_spent, 30.0 / time_spent);
			k = 0;
		}
		k++;
#endif
	}

file_read_out:
	if (read_allocated) {
		free(read_allocated);
		read_allocated = NULL;
	}
	return NULL;
}

void *pcie_dma_read(void *)
{
	int rc;
	int num_cpu;
	volatile unsigned int addr_high,addr_low, size, buffer_ready, read_complete;
	volatile unsigned int *transfer_done;
	volatile uint64_t addr;
	char *read_allocated = NULL;
	cpu_set_t cpuset;
#ifdef T_DEBUG
	struct timespec ts_start, ts_end;
	int k = 0;
#endif
	num_cpu = get_nprocs();
	if (num_cpu > 0 && num_cpu > 4) {
		CPU_ZERO(&cpuset);
		CPU_SET(1,&cpuset);
		rc = pthread_setaffinity_np(pthread_self(), sizeof(cpu_set_t), &cpuset);
		if (rc != 0)
			printf("set affinity failed\n");
	}
	posix_memalign((void **)&read_allocated, 4096 /*alignment */ , frame_bytes(in_width, in_height) + 4096);
	if (!read_allocated) {
		fprintf(stderr, "OOM: failed to allocate DMA read buffer.\n");
		rc = -ENOMEM;
		goto read_out;
	}

	trans.read_buffer = read_allocated;

	printf("[pcie_dma_read] Thread started\n");

	/* Warn if stale READY survived the drain (EP IRQ may not be working) */
	{
		uint32_t rd = *((volatile uint32_t *)(trans.map_base + PCIEP_READ_BUFFER_READY));
		if (rd & 0x1)
			printf("[pcie_dma_read] WARNING: READ_BUFFER_READY=0x%x on entry "
			       "(stale — EP drain did not clear it)\n", rd);
	}

	while (1) {
		transfer_done = ((uint32_t *)(trans.map_base + PCIRC_READ_BUFFER_TRANSFER_DONE));
		buffer_ready = *((uint32_t *)(trans.map_base + PCIEP_READ_BUFFER_READY));
		read_complete = *((uint32_t *)(trans.map_base + PCIEP_READ_TRANSFER_COMPLETE));
		/* Clear READ TRANSFER_DONE before polling for the next frame.
		 * The pcie-reg-space IP generates an interrupt on a 0→1 value
		 * transition of the TRANSFER_DONE register.  Without this clear,
		 * the register stays at 1 from the previous frame, so re-writing 1
		 * produces no 0→1 edge and the READ IRQ is silently lost.
		 * The C2H thread already clears its WRITE TRANSFER_DONE — this
		 * matches that pattern for the H2C direction. */
		*transfer_done = 0x0;
#ifdef T_DEBUG
		if(k==1)
			clock_gettime(CLOCK_MONOTONIC, &ts_start);
#endif
		/* ── POLL: Wait for EP to arm READ buffer (READY=1) ── */
		{
			struct timespec poll_t0, poll_t1;
			clock_gettime(CLOCK_MONOTONIC, &poll_t0);
			while (!(buffer_ready & 0x1))
			{
				buffer_ready = *((uint32_t *)(trans.map_base + PCIEP_READ_BUFFER_READY));
				read_complete = *((uint32_t *)(trans.map_base + PCIEP_READ_TRANSFER_COMPLETE));
				/* Guard: only honour 0xef once this run has seen READY=1
				 * (g_h2c_seen_ready=true).  Without this, a stale 0xef left
				 * in the register from the previous run would cause the
				 * thread to exit before the new EP app opens the driver fd
				 * (which is what clears 0xef to 0 in open()). */
				if ((read_complete == 0xef && g_h2c_seen_ready) || !app_running)
					break;
				sched_yield();  /* do not starve other threads */
			}
			clock_gettime(CLOCK_MONOTONIC, &poll_t1);
			double poll_ms = (poll_t1.tv_sec - poll_t0.tv_sec) * 1000.0
				+ (poll_t1.tv_nsec - poll_t0.tv_nsec) / 1e6;
			if (poll_ms > 50.0)
				printf("[T+%7.3f] [pcie_dma_read] STALL: waited %.1f ms for EP READ READY=1\n",
				       host_now_s(), poll_ms);
		}
		/* Record that at least one buffer was armed this run so subsequent
		 * 0xef checks are treated as genuine end-of-stream. */
		if (buffer_ready & 0x1) g_h2c_seen_ready = true;

		if ((read_complete == 0xef && g_h2c_seen_ready) || !app_running)
			break;

		addr_low = *((uint32_t *)(trans.map_base + PCIEP_READ_BUFFER_ADDR_LOW));
		addr_high = *((uint32_t *)(trans.map_base + PCIEP_READ_BUFFER_ADDR_HIGH));
		addr = (uint64_t) addr_high << 32 | addr_low;
		size = *((uint32_t *) (trans.map_base + PCIEP_READ_BUFFER_SIZE));
		rc = cb_deque(&queue_file_frame, trans.read_buffer);
		if (rc == 1) {
			/* Spin waiting for file_read to produce the next frame.
			 * Also check for the EP's end-of-file signal (0xef) and user
			 * quit so we exit cleanly instead of spinning until the QDMA
			 * H2C times out (10 s).  That timeout corrupts the QDMA H2C
			 * queue state and causes <1 fps on subsequent runs. */
			do {
				read_complete = *((uint32_t *)(trans.map_base + PCIEP_READ_TRANSFER_COMPLETE));
				if (read_complete == 0xef || !app_running)
					goto out;   /* EP finished or user quit — exit cleanly */
				sched_yield();
			} while(queue_file_frame.index == 0);
			cb_deque(&queue_file_frame, trans.read_buffer);
		}
		rc = write_from_buffer((char *)H2C_DEVICE, trans.h2c_fd, trans.read_buffer, size, addr);
		if (rc < 0) {
			/* H2C QDMA error — close and reopen the device to reset the QDMA
			 * H2C queue state.  After a 10-second QDMA timeout the hardware
			 * descriptor ring is corrupted; reopening the fd triggers the driver's
			 * queue-stop / queue-start path which clears the error state. */
			printf("[pcie_dma_read] H2C EIO (addr=0x%llx) — reopening QDMA H2C device\n",
			       (unsigned long long)addr);
			close(trans.h2c_fd);
			trans.h2c_fd = open(H2C_DEVICE, O_RDWR);
			if (trans.h2c_fd < 0) {
				printf("[pcie_dma_read] H2C reopen failed: %s\n", strerror(errno));
				trans.h2c_fd = -1;
				goto h2c_fatal;
			}
			rc = write_from_buffer((char *)H2C_DEVICE, trans.h2c_fd, trans.read_buffer, size, addr);
			if (rc < 0) {
				printf("[pcie_dma_read] H2C still failed after reopen: rc=%d\n", rc);
				goto h2c_fatal;
			}
			printf("[pcie_dma_read] H2C recovery successful\n");
		}
		if (rc < 0) {
		h2c_fatal:
			/* QDMA H2C hardware is permanently stuck — a simple fd reopen did not
			 * clear the error.  The hardware descriptor ring needs a PCIe reset.
			 * Stop all threads immediately (set app_running=false) and signal the
			 * EP to exit so everything unwinds cleanly instead of hanging at
			 * 0.066 fps on read_complete timeouts.
			 *
			 * To recover before the next run, on the HOST run ONE of:
			 *   echo 1 > /sys/bus/pci/devices/0000:c1:00.0/reset
			 *   sudo rmmod qdma-pf && sudo insmod /path/to/qdma-pf.ko
			 */
			printf("\n[pcie_dma_read] FATAL: QDMA H2C hardware needs reset.\n");
			printf("[pcie_dma_read] Run on HOST to recover:\n");
			printf("[pcie_dma_read]   echo 1 > /sys/bus/pci/devices/0000:c1:00.0/reset\n");
			printf("[pcie_dma_read]   OR: sudo rmmod qdma-pf && sudo insmod qdma-pf.ko\n\n");
			/* Signal EP to stop → host_app_reg_read detects it → g_main_loop_quit() */
			if (trans.map_base && trans.map_base != (char *)-1)
				*((volatile uint32_t *)(trans.map_base + PCIEP_SET_SIG)) = 0x1;
			/* Stop C2H and file_read threads via the app_running flag */
			app_running = false;
			goto out;
		}
#ifdef T_DEBUG
		if(k==30){
			clock_gettime(CLOCK_MONOTONIC, &ts_end);
			double time_spent = (ts_end.tv_sec - ts_start.tv_sec) +
				(ts_end.tv_nsec - ts_start.tv_nsec) / BILLION;
			printf("[pcie_dma_read] 30 frames in %.3f s (%.1f fps)\n",
			       time_spent, 30.0 / time_spent);
			k = 0;
		}
		k++;
#endif

		*transfer_done = 0x1;
		/* ── POLL: Wait for EP IRQ to clear READ READY (READY=0) ──
		 *
		 * Normal case: IRQ fires in <1 ms.
		 * Lost-IRQ case: if READY hasn't cleared after 150 ms (well past
		 *   any normal IRQ latency) the pcie-reg-space interrupt was lost
		 *   by the Xilinx AXI INTC.  DMA is confirmed complete because
		 *   write_from_buffer() returned without error above.  Generate a
		 *   fresh 0→1 transition on TRANSFER_DONE to retrigger the EP's
		 *   interrupt.  The EP's wait_for_completion(200 ms) catches the
		 *   retriggered IRQ — stall reduces from 15 s to ~150 ms. */
		{
			struct timespec clr_t0, clr_t1, retrigger_ref, tnow;
			int retrigger_count = 0;
			clock_gettime(CLOCK_MONOTONIC, &clr_t0);
			retrigger_ref = clr_t0;
			while ((buffer_ready & 0x1)) {
				buffer_ready = *((uint32_t *)(trans.map_base + PCIEP_READ_BUFFER_READY));
				/* Step 1: update clock and check retrigger window FIRST.
				 * The 0xef check MUST come after the retrigger, not before.
				 * If 0xef is checked first and the EP exits while the IRQ is
				 * still pending (READY=1), the loop exits before the retrigger
				 * fires, the EP driver never gets the IRQ, and its 15s
				 * wait_for_completion stalls the GStreamer pipeline long enough
				 * for appsrc backpressure to stop feeding frames. */
				clock_gettime(CLOCK_MONOTONIC, &tnow);
				double retry_ms = (tnow.tv_sec - retrigger_ref.tv_sec) * 1000.0
					+ (tnow.tv_nsec - retrigger_ref.tv_nsec) / 1e6;
				if (retry_ms > 150.0) {
					retrigger_count++;
					printf("[T+%7.3f] [pcie_dma_read] IRQ lost: retrigger #%d "
					       "after %.0f ms — re-firing READ TRANSFER_DONE\n",
					       host_now_s(), retrigger_count, retry_ms);
					/* Force 0→1 transition: write 0, flush, brief gap,
					 * write 1.  The 100 µs usleep ensures the PCIe write
					 * with value 0 propagates to the pcie-reg-space IP
					 * before the value-1 write arrives. */
					*transfer_done = 0x0;
					(void)*((volatile uint32_t *)(trans.map_base +
					        PCIRC_READ_BUFFER_TRANSFER_DONE)); /* flush */
					usleep(100);
					*transfer_done = 0x1;
					retrigger_ref = tnow;   /* reset window for next retrigger */
				}
				/* Step 2: check exit conditions AFTER the retrigger window.
				 * Only honour 0xef once at least one retrigger has been sent,
				 * or after 200 ms total (safety: allows one full retrigger
				 * cycle before conceding to EP exit). */
				if (!app_running) break;
				read_complete = *((uint32_t *)(trans.map_base + PCIEP_READ_TRANSFER_COMPLETE));
				double total_ms = (tnow.tv_sec - clr_t0.tv_sec) * 1000.0
					+ (tnow.tv_nsec - clr_t0.tv_nsec) / 1e6;
				if (read_complete == 0xef && (retrigger_count > 0 || total_ms > 200.0)) break;
				sched_yield();
			}
			clock_gettime(CLOCK_MONOTONIC, &clr_t1);
			double clr_ms = (clr_t1.tv_sec - clr_t0.tv_sec) * 1000.0
				+ (clr_t1.tv_nsec - clr_t0.tv_nsec) / 1e6;
			if (clr_ms > 50.0)
				printf("[T+%7.3f] [pcie_dma_read] STALL: waited %.1f ms for "
				       "EP READ READY\u21920%s\n",
				       host_now_s(), clr_ms,
				       retrigger_count ? " [IRQ retriggered]" : " (IRQ)");
		}
	}

out:
	printf("\n** Read done\n");
read_out:
	if (read_allocated) {
		free(read_allocated);
		read_allocated = NULL;
	}
	return NULL;
}

void  *pcie_dma_write(void *)
{
	int rc;
	volatile unsigned int addr_low,addr_high, size,  write_buffer_ready, write_complete;
	volatile uint64_t addr;
	volatile unsigned int *transfer_done;
	volatile unsigned int *ucase_params;
	char *write_allocated = NULL;
	int num_cpu;
	cpu_set_t cpuset;
#ifdef T_DEBUG
	struct timespec ts_start, ts_end;
	int k = 0;
#endif
	num_cpu = get_nprocs();
	if (num_cpu > 0 && num_cpu > 4) {
		CPU_ZERO(&cpuset);
		CPU_SET(2,&cpuset);
		rc = pthread_setaffinity_np(pthread_self(), sizeof(cpu_set_t), &cpuset);
		if (rc != 0)
			printf("set affinity failed\n");
	}

	posix_memalign((void **)&write_allocated, 4096 /*alignment */ , frame_bytes(in_width, in_height) + 4096);
	if (!write_allocated) {
		fprintf(stderr, "OOM: failed to allocate DMA write buffer.\n");
		rc = -ENOMEM;
		goto out;
	}
	trans.write_buffer = write_allocated;

	printf("[pcie_dma_write] Thread started\n");

	/* Warn if stale READY survived the drain (EP IRQ may not be working) */
	{
		uint32_t wr = *((volatile uint32_t *)(trans.map_base + PCIEP_WRITE_BUFFER_READY));
		if (wr & 0x1)
			printf("[pcie_dma_write] WARNING: WRITE_BUFFER_READY=0x%x on entry "
			       "(stale — EP drain did not clear it)\n", wr);
	}

	while (1) {
		transfer_done = ((uint32_t *)(trans.map_base + PCIRC_WRITE_BUFFER_TRANSFER_DONE));
		write_buffer_ready = *((uint32_t *)(trans.map_base + PCIEP_WRITE_BUFFER_READY));
		write_complete = *((uint32_t *)(trans.map_base + PCIEP_WRITE_TRANSFER_COMPLETE));
		*transfer_done = 0x0;
#ifdef T_DEBUG
		if(k==1)
			clock_gettime(CLOCK_MONOTONIC, &ts_start);
#endif

		/* ── POLL: Wait for EP to arm WRITE buffer (READY=1) ── */
		{
			struct timespec poll_t0, poll_t1;
			clock_gettime(CLOCK_MONOTONIC, &poll_t0);
			while (!(write_buffer_ready & 0x1))
			{
				write_buffer_ready = *((uint32_t *)(trans.map_base + PCIEP_WRITE_BUFFER_READY));
				write_complete = *((uint32_t *)(trans.map_base + PCIEP_WRITE_TRANSFER_COMPLETE));
				if ((write_complete == 0xef && g_c2h_seen_ready) || !app_running) {
					break;
				}
				sched_yield();  /* do not starve Qt render thread */
			}
			clock_gettime(CLOCK_MONOTONIC, &poll_t1);
			double poll_ms = (poll_t1.tv_sec - poll_t0.tv_sec) * 1000.0
				+ (poll_t1.tv_nsec - poll_t0.tv_nsec) / 1e6;
			if (poll_ms > 50.0)
				printf("[T+%7.3f] [pcie_dma_write] STALL: waited %.1f ms for EP WRITE READY=1\n",
				       host_now_s(), poll_ms);
		}
		if (write_buffer_ready & 0x1) g_c2h_seen_ready = true;
		if ((write_complete == 0xef && g_c2h_seen_ready) || !app_running) {
			break;
		}

		addr_low = *((uint32_t *)(trans.map_base + PCIEP_WRITE_BUFFER_ADDR_LOW));
		addr_high = *((uint32_t *)(trans.map_base + PCIEP_WRITE_BUFFER_ADDR_HIGH));
		addr = (uint64_t) addr_high << 32 | addr_low;
		size = *((uint32_t *) (trans.map_base + PCIEP_WRITE_BUFFER_SIZE));
		if (trans.c2h_fd) {
			/* Never block the C2H DMA thread waiting for the display
			 * to consume frames.  If the display/conversion is slower
			 * than the source rate, cb_enque() will drop the frame
			 * and the DMA pipeline keeps flowing.  Blocking here was
			 * the root cause of the 0.066 fps stall: when the queue
			 * stayed full, the C2H thread stopped reading QDMA data,
			 * the EP's write_complete timed out at 15 s, and throughput
			 * collapsed permanently. */
			rc = read_to_buffer((char *)C2H_DEVICE, trans.c2h_fd, trans.write_buffer, size, addr);
			if (rc < 0) {
				/* C2H QDMA error — close and reopen the device to reset the QDMA
				 * C2H queue state.  After a 10-second QDMA timeout the hardware
				 * descriptor ring is corrupted; reopening the fd triggers the driver's
				 * queue-stop / queue-start path which clears the error state. */
				printf("[pcie_dma_write] C2H EIO (addr=0x%llx) — reopening QDMA C2H device\n",
				       (unsigned long long)addr);
				close(trans.c2h_fd);
				trans.c2h_fd = open(C2H_DEVICE, O_RDWR);
				if (trans.c2h_fd < 0) {
					printf("[pcie_dma_write] C2H reopen failed: %s\n", strerror(errno));
					trans.c2h_fd = -1;
					goto c2h_fatal;
				}
				rc = read_to_buffer((char *)C2H_DEVICE, trans.c2h_fd, trans.write_buffer, size, addr);
				if (rc < 0) {
					printf("[pcie_dma_write] C2H still failed after reopen: rc=%d\n", rc);
					goto c2h_fatal;
				}
				printf("[pcie_dma_write] C2H recovery successful\n");
			}
			if (rc < 0) {
			c2h_fatal:
				/* QDMA C2H hardware is permanently stuck — a simple fd reopen did not
				 * clear the error.  The hardware descriptor ring needs a PCIe reset.
				 * Stop all threads immediately (set app_running=false) and signal the
				 * EP to exit so everything unwinds cleanly instead of hanging at
				 * 0.066 fps on write_complete timeouts.
				 *
				 * To recover before the next run, on the HOST run ONE of:
				 *   echo 1 > /sys/bus/pci/devices/0000:c1:00.0/reset
				 *   sudo rmmod qdma-pf && sudo insmod /path/to/qdma-pf.ko
				 */
				printf("\n[pcie_dma_write] FATAL: QDMA C2H hardware needs reset.\n");
				printf("[pcie_dma_write] Run on HOST to recover:\n");
				printf("[pcie_dma_write]   echo 1 > /sys/bus/pci/devices/0000:c1:00.0/reset\n");
				printf("[pcie_dma_write]   OR: sudo rmmod qdma-pf && sudo insmod qdma-pf.ko\n\n");
				/* Signal EP to stop → host_app_reg_read detects it → g_main_loop_quit() */
				if (trans.map_base && trans.map_base != (char *)-1)
					*((volatile uint32_t *)(trans.map_base + PCIEP_SET_SIG)) = 0x1;
				/* Stop H2C and file_read threads via the app_running flag */
				app_running = false;
				goto out;
			}

			int enq_rc = cb_enque(&queue_frame, trans.write_buffer);
#ifdef T_DEBUG
			if (enq_rc != 0)
				printf("[pcie_dma_write] WARNING: cb_enque failed frame#%d "
				       "(total_drops=%zu)\n", k, queue_frame.drop_count);
#endif
		}
#ifdef T_DEBUG
		if(k==30){
			clock_gettime(CLOCK_MONOTONIC, &ts_end);
			double time_spent = (ts_end.tv_sec - ts_start.tv_sec) +
				(ts_end.tv_nsec - ts_start.tv_nsec) / BILLION;
			printf("[pcie_dma_write] 30 frames in %.3f s (%.1f fps) "
			       "queue_depth=%zu total_drops=%zu\n",
			       time_spent, 30.0 / time_spent,
			       queue_frame.index, queue_frame.drop_count);
			k = 0;
		}
		k++;
#endif

		*transfer_done = 0x1;
		/* ── POLL: Wait for EP IRQ to clear WRITE READY (READY=0) ── */
		{
			struct timespec clr_t0, clr_t1, retrigger_ref, tnow;
			int retrigger_count = 0;
			clock_gettime(CLOCK_MONOTONIC, &clr_t0);
			retrigger_ref = clr_t0;
			while(write_buffer_ready) {
				write_buffer_ready = *((uint32_t *)(trans.map_base + PCIEP_WRITE_BUFFER_READY));
				/* Same ordering fix as the H2C poll: retrigger before 0xef check */
				clock_gettime(CLOCK_MONOTONIC, &tnow);
				double retry_ms = (tnow.tv_sec - retrigger_ref.tv_sec) * 1000.0
					+ (tnow.tv_nsec - retrigger_ref.tv_nsec) / 1e6;
				if (retry_ms > 150.0) {
					retrigger_count++;
					printf("[T+%7.3f] [pcie_dma_write] IRQ lost: retrigger #%d "
					       "after %.0f ms — re-firing WRITE TRANSFER_DONE\n",
					       host_now_s(), retrigger_count, retry_ms);
					*transfer_done = 0x0;
					(void)*((volatile uint32_t *)(trans.map_base +
					        PCIRC_WRITE_BUFFER_TRANSFER_DONE)); /* flush */
					usleep(100);
					*transfer_done = 0x1;
					retrigger_ref = tnow;
				}
				if (!app_running) break;
				write_complete = *((uint32_t *)(trans.map_base + PCIEP_WRITE_TRANSFER_COMPLETE));
				double total_ms = (tnow.tv_sec - clr_t0.tv_sec) * 1000.0
					+ (tnow.tv_nsec - clr_t0.tv_nsec) / 1e6;
				if (write_complete == 0xef && (retrigger_count > 0 || total_ms > 200.0)) break;
				sched_yield();  /* do not starve other threads */
			}
			clock_gettime(CLOCK_MONOTONIC, &clr_t1);
			double clr_ms = (clr_t1.tv_sec - clr_t0.tv_sec) * 1000.0
				+ (clr_t1.tv_nsec - clr_t0.tv_nsec) / 1e6;
			if (clr_ms > 50.0)
				printf("[T+%7.3f] [pcie_dma_write] STALL: waited %.1f ms for "
				       "EP WRITE READY\u21920%s\n",
				       host_now_s(), clr_ms,
				       retrigger_count ? " [IRQ retriggered]" : " (IRQ)");
		}
	}
out:
	printf("** Write done\n");
	if (write_allocated) {
		free(write_allocated);
		write_allocated = NULL;
	}
	/* Setting Use case to zero */
	u_case = 0;
	ucase_params = ((uint32_t *)(trans.map_base + PCIRC_UCASE_SET));
	*ucase_params = u_case & 0xFFFFFFFF;
	return NULL;
}
