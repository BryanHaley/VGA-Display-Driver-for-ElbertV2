# VGA Display Driver Example for the ElbertV2 FPGA Board
This project is an example of driving a VGA display using the ElbertV2 (Spartan3a) FPGA Board. It also provides a usable generic VGA Display Driver in Verilog for driving arbitrary displays at arbitrary color depths with any capable FPGA.

## Hardware
While the VGA Display Driver in this project is generic to any FPGA and any resolution/color-depth/etc setup (it merely generates the correct timings and signal pulses based on its inputs), the example module is written specifically for the [ElbertV2 Board from Numato Lab](https://numato.com/product/elbert-v2-spartan-3a-fpga-development-board). However, the example module can easily be adapted to any FPGA hooked up to a VGA display in a similar manner (i.e. 8 signal lines for color information connected to the VGA display via a simple resistor ladder DAC). To do this, the constraints file must be changed to reflect the new pin configuration, and a 100Mhz clock source must be provided to replace the generated 100Mhz clock in the _VGA_Display_Example_ module (provided in the example by _dcm_100.xaw_).

![ElbertV2 Board](https://numato.com/help/wp-content/uploads/2016/03/elbertv2_4__09811.1437703972.1280.1280-e1459217096649.jpg)

Some sort of VGA Display will be needed as well. The examples provided cover 640x480 and 800x600 (60Hz) displays, but in theory any VGA display should be usable if you override the default parameters with the [correct timings](https://www.epanorama.net/faq/vga2rgb/calc.html).

## Using this project
Create a new project, and configure the design properties as follows:
![Project Design Properties](https://i.imgur.com/rxClI8z.png)

__(Note the -4 speed rating).__

Add _VGA_Display_Driver.v_, _VGA_Display_Driver.ucf_, and _dcm_100.xaw_ to the project.

* _VGA_Display_Driver.v_: Verilog code defining the VGA Display Driver module and an example module showing how to use the display driver.
* _VGA_Display_Driver.ucf_: Constraints defining how the pins on the Spartan3a connect to the VGA port on the ElbertV2 board.
* _dcm_100.xaw_: Wizard provided by Xilinx for the Spartan3a that generates a verilog module at compile time that gives us a 100Mhz clock signal from the 12Mhz clock available on the ElbertV2 board.

Select _VGA_Display_Example (VGA_Display_Driver.v)_ in the Design Heirarchy. In the processess list in the box below, right click "Generate Programming File" and go to Properties. Check "Create Binary Configuration File."
![Project Options](https://i.imgur.com/QG1aHdb.png)

Click Apply and OK to close the options window. This only needs to be done once for each project.

Click the "Implement Top Module" (green arrow) button in the toolbar to compile the project. Whenever you make changes to the project, you will need to recompile it. Once the compiling process is finished, double click on "Generate Programming File" to generate a binary dump we can use to program the Spartan3a on the ElbertV2 board.

Plug in your ElbertV2 if it isn't already, and select the proper COM port in the ElbertV2 Configuration Tool. (Refer to the [ElbertV2 User Manual](https://numato.com/docs/elbert-v2-spartan-3a-fpga-development-board/)). Finally, select the generated bin file (_vga_display_example.bin_) and click Program. 
![Programming the board](https://i.imgur.com/V20n1Lu.png)

If everything is hooked up correctly, you should see something like this on your display.
![Testing the project](https://i.imgur.com/8SizvzJ.jpg)

Read the code and comments for an explanation on how it works. Try playing with the VGA RGB signal wires in the _VGA_Display_Example_ module to produce new images on the screen.
