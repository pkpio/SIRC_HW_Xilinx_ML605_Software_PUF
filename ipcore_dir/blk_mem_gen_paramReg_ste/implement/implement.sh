#!/bin/sh

# Clean up the results directory
rm -rf results
mkdir results

#Synthesize the Wrapper Files
echo 'Synthesizing XST wrapper file (core_top.vhd) with XST';
echo 'Synthesizing example design with XST';
xst -ifn xst.scr
cp blk_mem_gen_paramReg_top.ngc ./results/


# Copy the netlist generated by Coregen
echo 'Copying files from the netlist directory to the results directory'
cp ../../blk_mem_gen_paramReg.ngc results/

#  Copy the constraints files generated by Coregen
echo 'Copying files from constraints directory to results directory'
cp ../example_design/blk_mem_gen_paramReg_top.ucf results/

cd results

echo 'Running ngdbuild'
ngdbuild -p xc6vlx240t-ff1156-1 blk_mem_gen_paramReg_top

echo 'Running map'
map blk_mem_gen_paramReg_top -o mapped.ncd -pr i

echo 'Running par'
par mapped.ncd routed.ncd

echo 'Running trce'
trce -e 10 routed.ncd mapped.pcf -o routed

echo 'Running design through bitgen'
bitgen -w routed

echo 'Running netgen to create gate level Verilog model'
netgen -ofmt verilog -sim -tm blk_mem_gen_paramReg_top -pcf mapped.pcf -w routed.ncd routed.v
cp routed.sdf ../../production/timing/
