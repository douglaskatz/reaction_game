/*
 * This module updates a counter every clock cycle and resets when the counter reaches maxCount
 *
 */
module REACTION_GAME_MCOUNTER
#(
	// Parameter Declarations
	parameter maxCount = 10'd1000,       // Maximum value the counter will count to.
	parameter bitWidth = 4'd10
)
(
	// Input Ports
	input logic                 reset,
	input logic                 clk,
	input logic                 en,

	// Output Ports
	output logic [bitWidth-1:0] count,
	output logic                max
);
	// Module Item(s)
	always @(posedge clk) begin
		if(reset) begin
			count <= 0;
			max <= 0;
		end else begin
			if(en) begin
				if(count == maxCount-1) begin
					count <= 0;
					max <= 1;
				end else begin
					count <= count + 1;
					max <= 0;
				end
			end else begin
				count <= count;
				max <= 0;
			end
		end
	end
endmodule

