# VGA Display Driver Example for the ElbertV2 FPGA Board
This project is an example of driving a VGA display using the ElbertV2 (Spartan3a) FPGA Board. It also provides a usable generic VGA Display Driver in Verilog for displays of arbitrary resolutions.

## Hardware
This project uses the [ElbertV2 Board from Numato Lab](https://numato.com/product/elbert-v2-spartan-3a-fpga-development-board). However, it can be easily adapted to any FPGA hooked up to a VGA display in a similar manner by adapting the constraints file and using or generating a 100Mhz clock. This projects relies on the Spartan3a-specific way of generating a 100Mhz clock signal from the 12Mhz input signal provided by the oscillator on the ElbertV2 board.

Some sort of VGA Display will be needed as well. The examples provided cover 640x480 and 800x600 (60Hz) displays, but in theory any VGA display should be usable if you override the default parameters with the [correct timings](https://www.epanorama.net/faq/vga2rgb/calc.html).

## Using this project
Create a new project, and configure the design properties as follows:
!(https://i.imgur.com/rxClI8z.png)
(Note the -4 speed rating).

Add _VGA_Display_Driver.v_, _VGA_Display_Driver.ucf_, and _dcm_100.xaw_ to the project.

_VGA_Display_Driver.v_: Verilog code defining the VGA Display Driver module and an example module showing how to use the display driver.
_VGA_Display_Driver.ucf_: Constraints defining how the pins on the Spartan3a connect to the VGA port on the ElbertV2.
_dcm_100.xaw_: Wizard that generates a verilog module that gives us a 100Mhz clock signal from the 12Mhz clock available on the ElbertV2 board.

Select _VGA_Display_Example (VGA_Display_Driver.v)_ in the Design Heirarchy. In the processess list in the box below, right click "Generate Programming File" and go to Properties. Check "Create Binary Configuration File."
!(https://i.imgur.com/QG1aHdb.png)

Click Apply and OK to close the options window. Click the "Implement Top Module" (green arrow) button in the toolbar to compile the project. Then, double click on "Generate Programming File" to generate a bin we can use to program the Spartan3a on the ElbertV2 board.

Plug in your ElbertV2 if it isn't already, and select the proper COM port in the ElbertV2 Configuration Tool. (Refer to the [ElbertV2 User Manual](https://numato.com/docs/elbert-v2-spartan-3a-fpga-development-board/)). Finally, select the generated bin file (_vga_display_example.bin_) and click Program. 

!(https://i.imgur.com/V20n1Lu.png)

If everything is hooked up correctly, you should see something like this on your display.
!(https://i.imgur.com/8SizvzJ.jpg)
