######################################################################
#
# File name : tb_compile.do
# Created on: Fri Jun 15 01:56:31 +0800 2018
#
# Auto generated by Vivado for 'post-synthesis' simulation
#
######################################################################
vlib work
vlib msim

vlib msim/xil_defaultlib

vmap xil_defaultlib msim/xil_defaultlib

vlog -64 -incr -work xil_defaultlib  \
"tb_func_synth.v" \
"../../../../mips54.srcs/sim_1/imports/new/tb.v" \


quit -force

