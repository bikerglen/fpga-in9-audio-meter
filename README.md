# fpga-in9-audio-meter
<p>Clone repo to convenient location</p>
<p>Launch Vivado 2018.2</p>
<p>In TCL console:</p>
<p>cd [path to create project]</p>
<p>source [path to repo]/vivado/create-project.tcl</p>
<p>generate bitstream</p>
<p>export hardware / local / do not include bitstream</p>
<p>launch sdk</p>
<p>create new xilinx standalone hello world application</p>
<p>replace helloworld C code with contents of sdk-c/helloworld.c</p>
<p>add 'm' to helloworld -> properties -> C/C++ Build -> Settings -> Libraries
</p>
<p>to do: rewrite cordic using generate loops</p>
