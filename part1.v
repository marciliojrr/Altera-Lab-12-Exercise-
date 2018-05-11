
module part1 (CLOCK_50, CLOCK2_50, KEY, I2C_SCLK, I2C_SDAT, AUD_XCK, 
		        AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT, AUD_DACDAT, KEY2);

	input CLOCK_50, CLOCK2_50;
	input [0:0] KEY;
	input [0:0] KEY2;
	// I2C Audio/Video config interface
	output I2C_SCLK;
	inout I2C_SDAT;
	// Audio CODEC
	output AUD_XCK;
	input AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input AUD_ADCDAT;
	output AUD_DACDAT;
	
	// Local wires.
	wire read_ready, write_ready, read, write;
	wire [23:0] readdata_left, readdata_right;
	wire [23:0] writedata_left, writedata_right;
	wire reset = ~KEY[0];
	reg [23:0] outputL;
	reg [23:0] outputR;
	reg [24:0] delayedL;
	reg [24:0] delayedR;
	reg [23:0] L;
	reg [23:0] R;
	
	//Finite Impulse Response (FIR) filter
  
	always@(posedge CLOCK_50) begin
			if(KEY2) begin
				delayedL <= readdata_left;
				delayedR <= readdata_right;
			end
	end
	
	always@(posedge CLOCK_50) begin
			if(KEY2) begin
				outputL <= readdata_left + delayedL;
				outputR <= readdata_right + delayedR;
			end else begin
				outputL <= writedata_left;
				outputR <= writedata_right;
			end
	end

				
				
				

	//assign writedata_left = readdata_left;
	//assign writedata_right = readdata_right;
	assign read = 1;
	assign write = 1;
	
/////////////////////////////////////////////////////////////////////////////////
// Audio CODEC interface. 
//
// The interface consists of the following wires:
// read_ready, write_ready - CODEC ready for read/write operation 
// readdata_left, readdata_right - left and right channel data from the CODEC
// read - send data from the CODEC (both channels)
// writedata_left, writedata_right - left and right channel data to the CODEC
// write - send data to the CODEC (both channels)
// AUD_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio CODEC
// I2C_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio/Video Config module
/////////////////////////////////////////////////////////////////////////////////
	clock_generator my_clock_gen(
		// inputs
		CLOCK2_50,
		reset,

		// outputs
		AUD_XCK
	);

	audio_and_video_config cfg(
		// Inputs
		CLOCK_50,
		reset,

		// Bidirectionals
		I2C_SDAT,
		I2C_SCLK
	);

	audio_codec codec(
		// Inputs
		CLOCK_50,
		reset,

		read,	write,
		outputL, outputR,

		AUD_ADCDAT,

		// Bidirectionals
		AUD_BCLK,
		AUD_ADCLRCK,
		AUD_DACLRCK,

		// Outputs
		read_ready, write_ready,
		readdata_left, readdata_right,
		AUD_DACDAT
	);

endmodule
