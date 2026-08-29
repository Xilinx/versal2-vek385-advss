/*
 * Copyright (C) 2020 Xilinx, Inc.  All rights reserved.
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

#include <QApplication>
#include <iostream>
#include "main.h"
#include "pcie_host.h"
#include <QDebug>
#include <QtConcurrent>
#include <getopt.h>
#include <stdint.h>
#include <cstring>
#include <cstdlib>

/* Declared in pcie_host.cpp */
extern void pcie_host_configure_devices(const char *h2c, const char *c2h,
                                         const char *bar2, const char *qdma,
                                         const char *dmactl_path);
extern void print_device_help(void);

int main(int argc, char *argv[])
{
	const char *opt_h2c    = NULL;
	const char *opt_c2h    = NULL;
	const char *opt_bar2   = NULL;
	const char *opt_qdma   = NULL;
	const char *opt_dmactl = NULL;

	static const struct option long_opts[] = {
		{ "h2c",    required_argument, NULL, '1' },
		{ "c2h",    required_argument, NULL, '2' },
		{ "bar2",   required_argument, NULL, '3' },
		{ "qdma",   required_argument, NULL, '4' },
		{ "dmactl", required_argument, NULL, '5' },
		{ "help",   no_argument,       NULL, 'h' },
		{ NULL,     0,                 NULL,  0  }
	};

	int opt, idx = 0;
	while ((opt = getopt_long(argc, argv, "h", long_opts, &idx)) != -1) {
		switch (opt) {
		case '1': opt_h2c    = optarg; break;
		case '2': opt_c2h    = optarg; break;
		case '3': opt_bar2   = optarg; break;
		case '4': opt_qdma   = optarg; break;
		case '5': opt_dmactl = optarg; break;
		case 'h':
			print_device_help();
			return 0;
		default:
			fprintf(stderr, "Unknown option. Run with --help for usage.\n");
			return 1;
		}
	}

	/* Apply CLI overrides + auto-detect any unspecified paths */
	pcie_host_configure_devices(opt_h2c, opt_c2h, opt_bar2, opt_qdma, opt_dmactl);

	QApplication a(argc, argv);
	w = new MainWindow;
	QtConcurrent::run(cmaincall, w);
	return a.exec();
}
