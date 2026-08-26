# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
# -----------------------------------------------

set_clock_groups -asynchronous -group [get_clocks clk_pl_0] -group [get_clocks qdma_0_axi_aclk]
set_clock_groups -asynchronous -group [get_clocks qdma_0_axi_aclk] -group [get_clocks clk_pl_0]

