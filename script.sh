#!/bin/bash

# Create the work library
if [ ! -d "work" ]; then
   echo "work library does not exist"
   vlib work
fi

# Compile the SV file.
if [ -s arbiter.sv ]; then
   vlog arbiter.sv -work work
fi

#cp arbiter.sv rtl_src

vsim arbiter -do arbiter.do -quiet -c -t 1ps

# For design-vision, create dv_script
echo "analyze -format sverilog  -lib WORK arbiter.sv" >| script$$
echo "elaborate arbiter -lib WORK" >> script$$
echo "compile" >> script$$
echo "report_timing > timing.txt" >> script$$
echo "report_area > area.txt" >> script$$
echo "report_hierarchy > hierarchy.txt" >> script$$
echo "write -hierarchy -format verilog -output arbiter.gate.v" >> script$$
echo "quit" >> script$$
cp script$$ dv_script
rm script$$

# Synthesize the design by runnig dv_script that just created.
dc_shell-xg-t -f dv_script

mkdir gate_src
mv *.v gate_src/

