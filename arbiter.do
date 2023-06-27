# do file for arbiter
# author: Benjamin Warren
#
# ASSUMPTIONS:
# -The synthesized netlist: arbiter.gate.v
# -Work directory is created
# -Compiled arbiter.sv into work directory

# 0th: compile code (into "rtl_work" work library)
#vlog rtl_src/arbiter.sv -work rtl_work

# 1st: set up simulator (set time step to ns and optimizer off)
vsim arbiter -voptargs=+acc=npr -t ns

# 2nd_A: add all waveforms in model
add wave *

# 2nd_B: make a list that will be updated every 10ns...wait 9ns before sampling starts
# See modelsim_reference_manual_v11.c pg 60
# the second line(add...) removes the delta column. Then -label shortens the name of each column so it is more convenient to fit in a txtfile.
config list -strobeperiod {10 ns} -strobestart {9 ns} -usestrobe 1
add list -nodelta -notrigger -label Reset rst_n -label Clock clk -label Delay dly -label Done done -label Request req -label GNT gnt -label Timeout tout

# 3rd start simulation:
force rst_n 'd0
force dly 'd0
force done 'd0
force req 'd0
force clk 1 @ 0, 0 @ 5, 1 @ 10, 0 @ 15, 1 @ 20, 0 @ 25, 1 @ 30, 0 @ 35, 1 @ 40, 0 @ 45, 1 @ 50, 0 @ 55, 1 @ 60, 0 @ 65, 1 @ 70, 0 @ 75, 1 @ 80, 0 @ 85, 1 @ 90, 0 @ 95, 1 @ 100, 0 @ 105, 1 @ 110, 0 @ 115, 1 @ 120, 0 @ 125, 1 @ 130, 0 @ 135, 1 @ 140, 0 @ 145, 1 @ 150, 0 @ 155, 1 @ 160, 0 @ 165, 1 @ 170, 0 @ 175, 1 @ 180, 0 @ 185, 1 @ 190, 0 @ 195, 1 @ 200, 0 @ 205, 1 @ 210, 0 @ 215, 1 @ 220, 0 @ 225, 1 @ 230, 0 @ 235, 1 @ 240, 0 @ 245, 1 @ 250


###################
# IDLE, BBUSY, WAIT, BFREE

#IDLE
force rst_n 'd0
run 10ns

#BBUSY
force rst_n 'd1
force req 'd1
run 10ns
force req 'd0

#WAIT
force done 'd1
force dly 'd1
run 10ns
force done 'd0

#BFREE
force dly 'd0
run 10ns
run 10ns

##################

###################
# IDLE, BBUSY, TIMEOUT, WAIT, BFREE

#IDLE
force rst_n 'd0
run 10ns

#BBUSY
force rst_n 'd1
force req 'd1
run 10ns
force req 'd0

#TIMEOUT
force done 'd0
run 10ns
run 10ns
run 10ns

#WAIT
force dly 'd1
force reset 'd1
run 10ns
force reset 'd0

#BFREE
force dly 'd0
run 10ns
run 10ns

##################

###################
# IDLE, BBUSY, TIMEOUT, BFREE

#IDLE
force rst_n 'd0
run 10ns

#BBUSY
force rst_n 'd1
force req 'd1
run 10ns
force req 'd0

#TIMEOUT
force done 'd0
run 10ns
run 10ns
run 10ns

#BFREE
force reset 'd1
force dly 'd0
run 10ns
force reset 'd0

##################

###################
# IDLE, BBUSY, BFREE

#IDLE
force rst_n 'd0
run 10ns

#BBUSY
force rst_n 'd1
force req 'd1
run 10ns
force req 'd0

#BFREE
force dly 'd0
force done 'd1
run 10ns
force done 'd0
run 10ns

##################

# 4th: Write data in a .list and exit 
write list arbiter.list
exit

