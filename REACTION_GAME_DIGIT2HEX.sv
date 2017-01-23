// Digit2Hex
// This module converts a digit into the correct array of bits for displaying on the seven segment display
/* Mapping shown below
      	HEX[0]
      	------
        |      |
 HEX[5] |      | HEX[1]
        |HEX[6]|
         ------
        |      |
 HEX[4] |      | HEX[2]
        |HEX[3]|
         ------ 0 UNCONNECTED


*/
module REACTION_GAME_DIGIT2HEX(
	input logic   [3:0]   digit, // the digit to convert
	input logic           en,    // disable to turn display off
	
	output logic  [6:0]   hex    // the equivalent seven segment display output

);

always_comb begin
	if(en) begin
		// x and z values are NOT treated as don't-care's
		case(digit)
		4'h0: hex = 7'b1000000;
		4'h1: hex = 7'b1111001;
		4'h2: hex = 7'b0100100;
		4'h3: hex = 7'b0110000;
		4'h4: hex = 7'b0011001;
		4'h5: hex = 7'b0010010;
		4'h6: hex = 7'b0000010;
		4'h7: hex = 7'b1111000;
		4'h8: hex = 7'b0000000;
		4'h9: hex = 7'b0010000;
		4'ha: hex = 7'b0001000;
		4'hb: hex = 7'b0000011;
		4'hc: hex = 7'b1000110;
		4'hd: hex = 7'b0100001;
		4'he: hex = 7'b0000110;
		4'hf: hex = 7'b0001110;
		default: hex = 7'b1111111;
		endcase
	end else begin
		hex = 7'b1111111;
	end
end


endmodule