######################################################################
#
# File name : tb_simulate.do
# Created on: Fri Jun 15 13:04:19 +0800 2018
#
# Auto generated by Vivado for 'post-synthesis' simulation
#
######################################################################
vsim -voptargs="+acc" +transport_int_delays +pulse_r/0 +pulse_int_r/0 -L simprims_ver -L secureip -L xil_defaultlib -lib xil_defaultlib xil_defaultlib.tb xil_defaultlib.glbl

do {tb_wave.do}

view wave
view structure
view signals

do {tb.udo}

run 1000ns
