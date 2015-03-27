module project (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7, LEDR, CLOCK_50, GPIO_0, SW, LEDG, SOUND_SELECT);
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
	output [1:0] LEDR;
	input [1:0] SW; 
	input [0:0] GPIO_0;
	input CLOCK_50;
	reg output [3:0] SOUND_SELECT; // To be used in DE2_Audio_Example.v
	output [3:0] LEDG;
	
	reg [5:0] GOAL, LAST_G_AT;
	wire [5:0] TIMER;
	wire [3:0] MSD_t, LSD_t, MSD_g, LSD_g;
	
	assign LEDG = LSD_g;
	assign LEDR = SW;
	
	initial GOAL = 0;
	initial LAST_G_AT = 60;
	initial SOUND_SELECT = 4'b1010; // Start sound
	
	counter C0 (TIMER, CLOCK_50, SW[0], SW[1]);
	
	always @ (negedge SW[1], negedge GPIO_0)
		if (~SW[1])
			GOAL <= 0;
			LAST_G_AT <= 60;
			if (~SOUND_SELECT)
				SOUND_SELECT = 4'b1010; // Start sound
			else
				SOUND_SELECT = 4'b1000; // Enough start sound
		else if (~GPIO_0) begin
			if ((TIMER != 0) && (LAST_G_AT - TIMER >= 1)) begin
				GOAL <= GOAL + 1;
				LAST_G_AT <= TIMER;
				SOUND_SELECT <= 4'b1111;  // Make goal sound
			end
			else 
				SOUND_SELECT <= 4'b0000;  // Turn off the sound
		end
	
	bcd_decoder T0 (MSD_t, LSD_t, TIMER);
	bcd_decoder T1 (MSD_g, LSD_g, GOAL);
	
	seg_display S0 (HEX0, LSD_t);
	seg_display S1 (HEX1, MSD_t);
	seg_display S2 (HEX4, LSD_g);
	seg_display S3 (HEX5, MSD_g);
	
	make_blank M0 (HEX2);
	make_blank M1 (HEX3);
	make_blank M2 (HEX6);
	make_blank M3 (HEX7);

endmodule

module counter (Q, Clk, SW, Clr);
	output reg [5:0] Q;
	input Clk, SW, Clr;
	
	reg [25:0] i;
	
	initial begin
		Q = 6'd60;
		i = 0;
	end
	
	always @ (negedge Clr, posedge Clk)
		if (~Clr) begin
			Q <= 6'd60;
			i <= 0;
		end
		else if (i == 26'd50000000) begin
			if (SW && (Q != 0)) begin
				Q <= Q - 1;
				i <= 0;
			end
		end
		else 
			i <= i + 1;

endmodule

module bcd_decoder (MSD, LSD, I);
	output reg [3:0] MSD, LSD;
	input [5:0] I;

	always @ (I) begin
		MSD <= I / 10;
		LSD <= I % 10;
	end
endmodule  

module seg_display (s_s, S);
  input [3:0] S;
  output [6:0] s_s;

	assign s_s[0] = ((~S[3]&~S[2]&~S[1]&S[0]) | (~S[3]&S[2]&~S[1]&~S[0]) 
						| (S[3]&~S[2]&S[1]&S[0]) | (S[3]&S[2]&~S[1]&S[0]));
	assign s_s[1] = ((~S[3]&S[2]&~S[1]&S[0]) | (~S[3]&S[2]&S[1]&~S[0]) 
						| (S[3]&~S[2]&S[1]&S[0]) | (S[3]&S[2]&~S[1]&~S[0]) 
						| (S[3]&S[2]&S[1]&~S[0]) | (S[3]&S[2]&S[1]&S[0]));
	assign s_s[2] = ((~S[3]&~S[2]&S[1]&~S[0]) | (S[3]&S[2]&~S[1]&~S[0]) 
						| (S[3]&S[2]&S[1]&~S[0]) | (S[3]&S[2]&S[1]&S[0]));
	assign s_s[3] = ((~S[3]&~S[2]&~S[1]&S[0]) | (~S[3]&S[2]&~S[1]&~S[0]) 
						| (~S[3]&S[2]&S[1]&S[0]) | (S[3]&~S[2]&S[1]&~S[0]) 
						| (S[3]&S[2]&S[1]&S[0]));
	assign s_s[4] = ((~S[3]&~S[2]&~S[1]&S[0]) | (~S[3]&~S[2]&S[1]&S[0]) 
						| (~S[3]&S[2]&~S[1]&~S[0]) | (~S[3]&S[2]&~S[1]&S[0]) 
						| (~S[3]&S[2]&S[1]&S[0]) | (S[3]&~S[2]&~S[1]&S[0]));
	assign s_s[5] = ((~S[3]&~S[2]&~S[1]&S[0]) | (~S[3]&~S[2]&S[1]&~S[0]) 
						| (~S[3]&~S[2]&S[1]&S[0]) | (~S[3]&S[2]&S[1]&S[0]) 
						| (S[3]&S[2]&~S[1]&S[0]));
	assign s_s[6] = ((~S[3]&~S[2]&~S[1]&~S[0]) | (~S[3]&~S[2]&~S[1]&S[0]) 
						| (~S[3]&S[2]&S[1]&S[0]) | (S[3]&S[2]&~S[1]&~S[0]));
						
endmodule 

module make_blank(HEX);
	output [6:0] HEX;
	
	assign HEX = 7'b1111111;
	
endmodule
