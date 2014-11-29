# (c) Copyright 2009 - 2010 Xilinx, Inc. All rights reserved.
# 
# This file contains confidential and proprietary information
# of Xilinx, Inc. and is protected under U.S. and
# international copyright and other intellectual property
# laws.
# 
# DISCLAIMER
# This disclaimer is not a license and does not grant any
# rights to the materials distributed herewith. Except as
# otherwise provided in a valid license issued to you by
# Xilinx, and to the maximum extent permitted by applicable
# law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
# WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
# AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
# BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
# INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
# (2) Xilinx shall not be liable (whether in contract or tort,
# including negligence, or under any other theory of
# liability) for any loss or damage of any kind or nature
# related to, arising under or in connection with these
# materials, including for any direct, or any indirect,
# special, incidental, or consequential loss or damage
# (including loss of data, profits, goodwill, or any type of
# loss or damage suffered as a result of any action brought
# by a third party) even if such damage or loss was
# reasonably foreseeable or Xilinx had been advised of the
# possibility of the same.
# 
# CRITICAL APPLICATIONS
# Xilinx products are not designed or intended to be fail-
# safe, or for use in any application requiring fail-safe
# performance, such as life-support or safety devices or
# systems, Class III medical devices, nuclear facilities,
# applications related to the deployment of airbags, or any
# other applications that could lead to death, personal
# injury, or severe property or environmental damage
# (individually and collectively, "Critical
# Applications"). Customer assumes the sole risk and
# liability of any use of Xilinx products in Critical
# Applications, subject only to applicable laws and
# regulations governing limitations on product liability.
# 
# THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
# PART OF THIS FILE AT ALL TIMES.


set device xc6slx150tfgg676-3
set projName fifo_wr16_rd32
set design fifo_wr16_rd32
set projDir [file dirname [info script]]
create_project $projName $projDir/results/$projName -part $device -force
set_property design_mode RTL [current_fileset -srcset]
set top_module fifo_wr16_rd32_top
add_files -norecurse {../../example_design/fifo_wr16_rd32_top.vhd}
add_files -norecurse {./fifo_wr16_rd32.edf}
import_files -fileset [get_filesets constrs_1] -force -norecurse {../../example_design/fifo_wr16_rd32_top.xdc}
set_property top fifo_wr16_rd32_top [get_property srcset [current_run]]
synth_design
opt_design 
place_design 
route_design
set_param sta.dlyMediator true 
write_sdf -rename_top_module fifo_wr16_rd32_top -file routed.sdf 
write_verilog -nolib -mode sim -sdf_anno false -rename_top_module fifo_wr16_rd32_top routed.vhd
report_timing -nworst 30 -path_type full -file routed.twr
report_drc
