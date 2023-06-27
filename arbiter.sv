module arbiter(
	input clk,			 // clock input
	input rst_n,		 // active low asychronous rst
	input dly,			 // delay input
	input done,			 // done input
	input req,			 // request input
	input reset,		 // reset for TIMEOUT
	output logic gnt = 0,
	output logic tout = 0	 // timeout augment
);
	
reg [1:0] counter;		 // register to counter clock cycles

// Moore mahchine state encoding
enum logic [2:0]{
	IDLE = 3'b000,
	BBUSY = 3'b001,
	BWAIT = 3'b010,
	BFREE = 3'b011,
	TIMEOUT = 3'b100
} arbiter_ps, arbiter_ns;

// State storage
always_ff @(posedge clk, negedge rst_n)		// ff -> state storage (D-latch)
	if (!rst_n) begin
		counter = 0;
		arbiter_ps <= IDLE; //at rst (active low), go to idle state 
	end else begin
		if (arbiter_ps == BBUSY && arbiter_ns == BBUSY) begin
			counter = counter + 1;
		end else if (arbiter_ps != BBUSY && arbiter_ns == BBUSY) begin
			counter = 0;
		end
		arbiter_ps <= arbiter_ns; //otherwise, go to the next state
		$display("%t : [arbiter_ps] becomes: %0h", $time, arbiter_ns);
	end

// Next state decoder
always_comb begin 							// comb -> combinational (not state holding storage)
	unique case (arbiter_ps)				//unique -> only one case true at a time
		IDLE: begin							// if current state is x
			gnt = 1'b0;
			if (req) begin
				arbiter_ns = BBUSY;			// set next state to go to
			end else begin
				arbiter_ns = IDLE;
			end
		end
		BBUSY: begin						// if current state is x
			gnt = 1'b1;
			if (!done && counter < 2) begin // stay in BBUSY for a max of 2 cycles
				arbiter_ns = BBUSY;			// set next state to go to=
			end else if (!done && counter == 2) begin
				arbiter_ns = TIMEOUT;		// TIMEOUT due to 3 consecutive clk cycles of BB
			end else if (dly) begin
				arbiter_ns = BWAIT;
			end else begin
				arbiter_ns = BFREE;
			end
		end
		BWAIT: begin						// if current state is x
			gnt = 1'b1;
			if (!dly) begin
				arbiter_ns = BFREE;			// set next state to go to
			end else begin
				arbiter_ns = BWAIT;
			end
		end
		BFREE: begin						// if current state is x
			gnt = 1'b0;
			if (req) begin
				arbiter_ns = BBUSY;			// set next state to go to
			end else begin
				arbiter_ns = IDLE;
			end
		end
		TIMEOUT: begin							// if current state is x
			gnt = 1'b0;
			tout = 1'b1;
			if (reset) begin
				if (dly) begin
					tout = 1'b0;
					arbiter_ns = BWAIT;			// WAIT if dly is 1
				end else begin
					tout = 1'b0;
					arbiter_ns = BFREE;			// else BFREE is ns
				end
			end else begin
				arbiter_ns = TIMEOUT;
			end
		end
	endcase
end
endmodule
