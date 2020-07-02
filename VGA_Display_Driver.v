`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// This module takes as input the 12Mhz clock signal provided by the Elbert V2
// FPGA board, and outputs a parallel 8-bit bus containing color data along with
// horizontal and vertical sync signals used for driving a VGA display.
//////////////////////////////////////////////////////////////////////////////////
module VGA_Display_Example(i_clk, o_vga_rgb, o_vga_hsync, o_vga_vsync);
	input wire i_clk; // 12Mhz clock provided by Elbert V2 board
	output wire[7:0] o_vga_rgb; // parallel 8-bit VGA signal lines
	output wire o_vga_hsync;
	output wire o_vga_vsync;
	
	wire clk_100; // 100Mhz clock generated by dcm
	wire active_draw; // high if the display driver is working in the active drawing area of the screen
	wire reset = 0; // unused
	
	// Fractional Clock Divider to get 25Mhz (640x480) or 40Mhz (800x600) period for VGA
	// http://zipcpu.com/blog/2017/06/02/generating-timing.html
	reg vga_pix_draw; // Flag to indicate we're aligned with the 25 or 40Mhz period and can draw a pixel
	reg[15:0] vga_clk_counter; // 16 bit counter to get us close enough to the ideal period
	always @(posedge clk_100) begin
		// vga_pix_draw becomes 1 (high) when vga_clk_counter rolls over.
		// 640x480
		//{vga_pix_draw, vga_clk_counter} <= vga_clk_counter + 16'h4000; // Divide 100Mhz clock by 4 to get 25Mhz. (2^16)/4 = 0x4000.
		
		// 800x600
		{vga_pix_draw, vga_clk_counter} <= vga_clk_counter + 16'h6666; // Divide 100Mhz clock by 2.5 to get 40Mhz. (2^16)/2.5 = approx 0x6666.
	end
	
	// pix_x and pix_y hold the coordinates of the pixel currently being drawn
	wire[10:0] pix_x;
	wire[10:0] pix_y;
	
	// Draw vertical bars on the screen representing the primary colors and the color depth we can achieve
	// with 8 bits per pixel.
	// GOTCHA: vga color signal lines need to be low when outside the active drawing area or we'll just get a black screen.
	
	// 640x480
	/*assign o_vga_rgb[0] = active_draw ? (pix_x<80) : 0;
	assign o_vga_rgb[1] = active_draw ? (pix_x<160) : 0;
	assign o_vga_rgb[2] = active_draw ? (pix_x<240) : 0;
	assign o_vga_rgb[3] = active_draw ? (pix_x>=240 & pix_x<320) : 0;
	assign o_vga_rgb[4] = active_draw ? (pix_x>=240 & pix_x<400) : 0;
	assign o_vga_rgb[5] = active_draw ? (pix_x>=240 & pix_x<480) : 0;
	assign o_vga_rgb[6] = active_draw ? (pix_x>=480 & pix_x<560) : 0;
	assign o_vga_rgb[7] = active_draw ? (pix_x>=480 & pix_x<640) : 0;*/
	
	// 800x600
	assign o_vga_rgb[0] = active_draw ? (pix_x<100) : 0;
	assign o_vga_rgb[1] = active_draw ? (pix_x<200) : 0;
	assign o_vga_rgb[2] = active_draw ? (pix_x<300) : 0;
	assign o_vga_rgb[3] = active_draw ? (pix_x>=300 & pix_x<400) : 0;
	assign o_vga_rgb[4] = active_draw ? (pix_x>=300 & pix_x<500) : 0;
	assign o_vga_rgb[5] = active_draw ? (pix_x>=300 & pix_x<600) : 0;
	assign o_vga_rgb[6] = active_draw ? (pix_x>=600 & pix_x<700) : 0;
	assign o_vga_rgb[7] = active_draw ? (pix_x>=600 & pix_x<800) : 0;
	
	// Instantiate display driver
	VGA_Display_Driver display (
		.i_clk(clk_100),
		.i_pix_draw(vga_pix_draw),
		.o_active_draw(active_draw),
		.o_pix_x(pix_x),
		.o_pix_y(pix_y),
		.o_hsync(o_vga_hsync),
		.o_vsync(o_vga_vsync)
		);
		
		// Override default params for 800x600 to create a 640x480 display
		// See: https://www.epanorama.net/faq/vga2rgb/calc.html
		
		// Just comment these out for the default 800x600 display
		/*defparam display.H_REZ = 640;
		defparam display.H_SYNC_START = 16;
		defparam display.H_SYNC_END = 112;
		defparam display.H_SIZE = 800;
		
		defparam display.V_REZ = 480;
		defparam display.V_SYNC_START = 11;
		defparam display.V_SYNC_END = 13;
		defparam display.V_SIZE = 524;*/

	// Instantiate 100Mhz clock provider
	dcm_100 dcm_100Mhz_clock (
		 .CLKIN_IN(i_clk), 
		 .RST_IN(reset), 
		 .CLKFX_OUT(clk_100), 
		 .CLKIN_IBUFG_OUT(), 
		 .CLK0_OUT()
		 );
endmodule

// References for implementation:
// https://www.epanorama.net/faq/vga2rgb/calc.html (VESA 800x600 60Hz)
// https://timetoexplore.net/blog/arty-fpga-vga-verilog-01
// http://ece-research.unm.edu/jimp/vhdl_fpgas/slides/VGA.pdf
module VGA_Display_Driver (i_clk, i_pix_draw, o_active_draw, o_pix_x, o_pix_y, o_hsync, o_vsync);
	input wire i_clk;
	input wire i_pix_draw;
	output wire o_active_draw;
	output wire[10:0] o_pix_x;
	output wire[10:0] o_pix_y;
	output wire o_hsync;
	output wire o_vsync;
	
	// Horizontal measurements in pixels
	parameter H_REZ         = 800;
	parameter H_SYNC_START  = 40;
	parameter H_SYNC_END    = 168;
	parameter H_SIZE        = 1056;
	
	// Horizontal porch starts *before* the active drawing area, unlike vertical porch which starts after it.
	localparam H_ACTIVE_START = H_SIZE-H_REZ;
	
	// Vertical measurements in lines
	parameter V_REZ         = 600;
	parameter V_SYNC_START  = 601;
	parameter V_SYNC_END    = 605;
	parameter V_SIZE        = 628;
	
	// counters to hold x,y position of the full screen (i.e. including porch and sync)
	parameter CNT_SIZE = 10;
	reg[CNT_SIZE:0] h_count = 0;
	reg[CNT_SIZE:0] v_count = 0;
	
	// pulse sync signals according to VGA timing specs
	assign o_hsync = ((h_count >= H_SYNC_START) & (h_count < H_SYNC_END));
	assign o_vsync = ((v_count >= V_SYNC_START) & (v_count < V_SYNC_END));
	
	// Update pixel positions when in active drawing area of screen
	assign o_pix_x = (h_count >= H_ACTIVE_START) ? (h_count - H_ACTIVE_START) : 0;
	assign o_pix_y = (v_count < V_REZ) ? v_count : V_REZ-1;
	
	// Set high when in active drawing area
	assign o_active_draw = ((h_count >= H_ACTIVE_START) & (v_count < V_REZ));
	
	// Update positions
	always @(posedge i_clk) begin
		if (i_pix_draw) begin
			// Increment v_count and rollover h_count when we reach the end of a horizontal line
			if (h_count == H_SIZE) begin
				h_count <= 0;
				v_count <= v_count + 1;
			end else begin
				h_count <= h_count + 1;
			end
			
			//rollover v_count if we've reached the end of the screen
			if (v_count == V_SIZE) v_count <= 0;
		end
	end
	
endmodule













