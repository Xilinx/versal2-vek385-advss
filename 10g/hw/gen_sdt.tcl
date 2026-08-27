# Copyright (c) 2026 Advanced Micro Devices, Inc.
# SPDX-License-Identifier: MIT
# -----------------------------------------------

# parse arguments
for { set i 0 } { $i < $argc } { incr i } {
  # xsa path
  if { [lindex $argv $i] == "-xsa_path" } {
    incr i
    set xsa_path [lindex $argv $i]
  }
}

sdtgen set_dt_param -debug enable
sdtgen set_dt_param -dir ./mmi_10g_sdt
sdtgen set_dt_param -xsa $xsa_path
sdtgen set_dt_param -board_dts versal2-vek385-revb
sdtgen generate_sdt
