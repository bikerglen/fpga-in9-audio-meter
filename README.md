# fpga-in9-audio-meter
Clone repo to convenient location
Launch Vivado 2018.2
In TCL console:
cd <path to create project>
source <path to repo>/vivado/create-project.tcl
generate bitstream
export hardware / local / do not include bitstream
launch sdk
create new standalone hello world application
replace helloworld C code with contents of sdk-c/helloworld.c

to do: rewrite cordic using generate loops
