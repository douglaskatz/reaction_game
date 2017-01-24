/*
 * This module tests the reaction time of a player. It resets using switch SW0 to begin. After a countdown the player must try to press
 * button SW1 as quickly as possible. The board will then display how quickly after the countdown the button was pressed. If a player presses
 * too early the display will show "dis" (disqualified).
 * 
 */

//`define ENABLE_DDR2LP
//`define ENABLE_HSMC_XCVR
//`define ENABLE_SMA
//`define ENABLE_REFCLK
//`define ENABLE_GPIO

module REACTION_GAME(

      ///////// ADC ///////// 1.2 V ///////
      output             ADC_CONVST,
      output             ADC_SCK,
      output             ADC_SDI,
      input              ADC_SDO,

      ///////// AUD ///////// 2.5 V ///////
      input              AUD_ADCDAT,
      inout              AUD_ADCLRCK,
      inout              AUD_BCLK,
      output             AUD_DACDAT,
      inout              AUD_DACLRCK,
      output             AUD_XCK,

      ///////// CLOCK /////////
      input              CLOCK_125_p, ///LVDS
      input              CLOCK_50_B5B, ///3.3-V LVTTL
      input              CLOCK_50_B6A,
      input              CLOCK_50_B7A, ///2.5 V
      input              CLOCK_50_B8A,

      ///////// CPU /////////
      input              CPU_RESET_n, ///3.3V LVTTL

`ifdef ENABLE_DDR2LP
      ///////// DDR2LP ///////// 1.2-V HSUL ///////
      output      [9:0]  DDR2LP_CA,
      output      [1:0]  DDR2LP_CKE,
      output             DDR2LP_CK_n, ///DIFFERENTIAL 1.2-V HSUL
      output             DDR2LP_CK_p, ///DIFFERENTIAL 1.2-V HSUL
      output      [1:0]  DDR2LP_CS_n,
      output      [3:0]  DDR2LP_DM,
      inout       [31:0] DDR2LP_DQ,
      inout       [3:0]  DDR2LP_DQS_n, ///DIFFERENTIAL 1.2-V HSUL
      inout       [3:0]  DDR2LP_DQS_p, ///DIFFERENTIAL 1.2-V HSUL
      input              DDR2LP_OCT_RZQ, ///1.2 V
`endif /*ENABLE_DDR2LP*/

`ifdef ENABLE_GPIO
      ///////// GPIO ///////// 3.3-V LVTTL ///////
      inout       [35:0] GPIO,
`else	
      ///////// HEX2 ///////// 1.2 V ///////
      output      [6:0]  HEX2,

      ///////// HEX3 ///////// 1.2 V ///////
      output      [6:0]  HEX3,		
		
		
`endif /*ENABLE_GPIO*/

      ///////// HDMI /////////
      output             HDMI_TX_CLK,
      output      [23:0] HDMI_TX_D,
      output             HDMI_TX_DE,
      output             HDMI_TX_HS,
      input              HDMI_TX_INT,
      output             HDMI_TX_VS,

      ///////// HEX0 /////////
      output      [6:0]  HEX0,

      ///////// HEX1 /////////
      output      [6:0]  HEX1,


      ///////// HSMC ///////// 2.5 V ///////
      input              HSMC_CLKIN0,
      input       [2:1]  HSMC_CLKIN_n,
      input       [2:1]  HSMC_CLKIN_p,
      output             HSMC_CLKOUT0,
      output      [2:1]  HSMC_CLKOUT_n,
      output      [2:1]  HSMC_CLKOUT_p,
      inout       [3:0]  HSMC_D,
`ifdef ENABLE_HSMC_XCVR		
      input       [3:0]  HSMC_GXB_RX_p, /// 1.5-V PCML
      output      [3:0]  HSMC_GXB_TX_p, /// 1.5-V PCML
`endif /*ENABLE_HSMC_XCVR*/		
      inout       [16:0] HSMC_RX_n,
      inout       [16:0] HSMC_RX_p,
      inout       [16:0] HSMC_TX_n,
      inout       [16:0] HSMC_TX_p,


      ///////// I2C ///////// 2.5 V ///////
      output             I2C_SCL,
      inout              I2C_SDA,

      ///////// KEY ///////// 1.2 V ///////
      input       [3:0]  KEY,

      ///////// LEDG ///////// 2.5 V ///////
      output      [7:0]  LEDG,

      ///////// LEDR ///////// 2.5 V ///////
      output      [9:0]  LEDR,

`ifdef ENABLE_REFCLK
      ///////// REFCLK ///////// 1.5-V PCML ///////
      input              REFCLK_p0,
      input              REFCLK_p1,
`endif /*ENABLE_REFCLK*/

      ///////// SD ///////// 3.3-V LVTTL ///////
      output             SD_CLK,
      inout              SD_CMD,
      inout       [3:0]  SD_DAT,

`ifdef ENABLE_SMA
      ///////// SMA ///////// 1.5-V PCML ///////
      input              SMA_GXB_RX_p,
      output             SMA_GXB_TX_p,
`endif /*ENABLE_SMA*/

      ///////// SRAM ///////// 3.3-V LVTTL ///////
      output      [17:0] SRAM_A,
      output             SRAM_CE_n,
      inout       [15:0] SRAM_D,
      output             SRAM_LB_n,
      output             SRAM_OE_n,
      output             SRAM_UB_n,
      output             SRAM_WE_n,

      ///////// SW ///////// 1.2 V ///////
      input       [9:0]  SW,

      ///////// UART ///////// 2.5 V ///////
      input              UART_RX,
      output             UART_TX


);

logic reset;
logic clk;

logic       usecMax;   // 1000 ns reached
logic       msecMax;   // 1000 us reached
logic       secMax;    // 1000 ms reached
logic       tenSecMax; // 10 s reached

logic [9:0] msec; // how many miliseconds have passed
logic [9:0] sec;  // how many seconds have passed

logic       counterReset; // reset all counters 
logic       counterEn;    // enables counters

assign clk = CLOCK_50_B5B; // 50 MHz clock
assign reset = ~SW[0]; // reset button
assign button = ~KEY[0]; // button press

//-----------------------------------------------------------------------------------
// Timers:
// These timers keep track of seconds and milliseconds when en is driven high
//-----------------------------------------------------------------------------------
REACTION_GAME_MCOUNTER #(6'd50,3'd6) nsecCounter(
.reset(reset | counterReset),
.clk(clk),
.en(counterEn),

.count(),
.max(usecMax)
);

REACTION_GAME_MCOUNTER usecCounter(
.reset(reset | counterReset),
.clk(clk),
.en(usecMax),

.count(),
.max(msecMax)
);

REACTION_GAME_MCOUNTER msecCounter(
.reset(reset | counterReset),
.clk(clk),
.en(msecMax),

.count(msec),
.max(secMax)
);

REACTION_GAME_MCOUNTER #(4'd10,3'd4) secCounter(
.reset(reset | counterReset),
.clk(clk),
.en(secMax),

.count(sec),
.max(tenSecMax)
);

//-----------------------------------------------------------------------------------
// State Machine
//-----------------------------------------------------------------------------------
logic [3:0] secDigit;     // Digit displayed in second slot
logic       secDigitEn;   // Enables displaying the second digit
logic [3:0] dsecDigit;    // Digit displayed in decisecond slot
logic       dsecDigitEn;   // Enables displaying the decisecond digit
logic [3:0] csecDigit;    // Digit displayed in centisecond slot
logic       csecDigitEn;   // Enables displaying the centisecond digit
logic [3:0] msecDigit;    // Digit displayed in millisecond slot
logic       msecDigitEn;   // Enables displaying the millisecond digit


enum int unsigned { STATE_RESET = 0, STATE_COUNTDOWN = 2, STATE_COUNTUP = 4, STATE_RESULT = 8, STATE_FALSE = 16} state, next_state;

// Seven segment display/State machine outputs
always_comb begin
	counterReset = 0;
	counterEn    = 0;
	case(state)
		STATE_RESET: begin
			secDigit    = 4'd0;
			secDigitEn  = 1;
			dsecDigit   = 4'd0;
			dsecDigitEn = 1;
			csecDigit   = 4'd0;
			csecDigitEn = 1;
			msecDigit   = 4'd0;
			msecDigitEn = 1;
		end
		STATE_COUNTDOWN: begin
			secDigit     = 4'd10 - sec;
			secDigitEn   = 1;
			dsecDigit     = 4'd0;
			dsecDigitEn  = 0;
			csecDigit     = 4'd0;
			csecDigitEn  = 0;
			msecDigit     = 4'd0;
			msecDigitEn  = 0;
			counterEn   = 1;
		end
		STATE_COUNTUP: begin
			secDigit    = 4'd0;
			secDigitEn  = 1;
			dsecDigit   = 4'd0;
			dsecDigitEn = 0;
			csecDigit   = 4'd0;
			csecDigitEn = 0;
			msecDigit   = 4'd0;
			msecDigitEn = 0;
			counterEn   = 1;
		end
		STATE_RESULT: begin
			secDigit    = sec;
			secDigitEn  = 1;
			dsecDigit   = msec / 8'd100;
			dsecDigitEn = 1;
			csecDigit   = (msec % 8'd100) / 4'd10;
			csecDigitEn = 1;
			msecDigit   = msec % 4'd10;
			msecDigitEn = 1;
			counterEn   = 0;
		end
		STATE_FALSE: begin
			secDigit    = 4'hf;
			secDigitEn  = 1;
			dsecDigit   = 4'hf;
			dsecDigitEn = 1;
			csecDigit   = 4'hf;
			csecDigitEn = 1;
			msecDigit   = 4'hf;
			msecDigitEn = 1;
		end
		default: begin
			secDigit    = 4'd0;
			secDigitEn  = 1;
			dsecDigit   = 4'd0;
			dsecDigitEn = 1;
			csecDigit   = 4'd0;
			csecDigitEn = 1;
			msecDigit   = 4'd0;
			msecDigitEn = 1;
			counterReset = 1;
		end
	endcase
end

// State transitions
always_comb begin
	case(state)
		STATE_RESET:begin
			if(reset)
				next_state = STATE_RESET;
			else
				next_state = STATE_COUNTDOWN;
		end
		STATE_COUNTDOWN: begin
			// if button is pressed too early
			if(button)
				next_state = STATE_FALSE;
			else begin
				// if ten second countdown has ended
				if(tenSecMax)
					next_state = STATE_COUNTUP;
				else
					next_state = STATE_COUNTDOWN;
			end
		end
		STATE_COUNTUP: begin
			// if button is pressed at correct time
			if(button)
				next_state = STATE_RESULT;
			else begin
				if(tenSecMax) 
					next_state = STATE_RESULT;
				else
					next_state = STATE_COUNTUP;
			end
		end
		// display results or false start until reset
		STATE_RESULT: begin
			next_state = STATE_RESULT;
		end
		STATE_FALSE: begin
			next_state = STATE_FALSE;
		end
		default:
			next_state = STATE_RESET;
	endcase
end
	

always_ff@(posedge clk) begin
	if(reset)
		state <= STATE_RESET;
	else
		state <= next_state;
end



//-----------------------------------------------------------------------------------
// Digit to Hex Display Converters
//-----------------------------------------------------------------------------------

// milliseconds
REACTION_GAME_DIGIT2HEX d2h0 (
.digit(msecDigit),
.en(msecDigitEn),
.hex(HEX0)
);

// Centiseconds
REACTION_GAME_DIGIT2HEX d2h1 (
.digit(csecDigit),
.en(csecDigitEn),
.hex(HEX1)
);

// Deciseconds
REACTION_GAME_DIGIT2HEX d2h2 (
.digit(dsecDigit),
.en(dsecDigitEn),
.hex(HEX2)
);

// Seconds
REACTION_GAME_DIGIT2HEX d2h3 (
.digit(secDigit),
.en(secDigitEn),
.hex(HEX3)
);

endmodule
