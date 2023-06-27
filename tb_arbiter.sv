`timescale 1ns/1ns

// Testbench for testing arbiter.sv
// Author: Dongjun Lee (04/12/2023)

module tb_arbiter();

logic clk, rst_n, dly, done, req, reset;   // Input signals to the DUT.
logic gnt, tout;                           // Output signals from the DUT.

// Instantiate DUT //
arbiter iDUT(.clk(clk), .rst_n(rst_n), .dly(dly), .done (done), .req(req), .reset(reset),
	.gnt(gnt), .tout(tout));



initial begin

clk = 0;
rst_n = 0;
dly = 0;
done = 0;
req = 0;
reset = 0;

@(posedge clk);
@(negedge clk) rst_n = 1;

// Test case 1: IDLE > BUSY > WAIT > FREE > IDLE
repeat (2) @(negedge clk);
req = 1;
repeat (1) @(negedge clk);
done = 1;
dly = 1;
req = 0;
repeat (1) @(negedge clk);
done = 0;
dly = 0;
req = 0;
repeat (2) @(negedge clk);

// Test case 2: IDLE > BUSY > TIMEOUT> WAIT > FREE > IDLE
repeat (3) @(negedge clk);
req = 1;
reset = 0;
repeat (2) @(negedge clk);
reset = 0;
dly = 1;
req = 0;
repeat (2) @(negedge clk);
reset = 1;
dly = 1;
req = 0;
repeat (1) @(negedge clk);
reset = 0;
dly = 0;
repeat (2) @(negedge clk);

// Test case 3: IDLE > BUSY > TIMEOUT> FREE > IDLE
repeat (3) @(negedge clk);
req = 1;
repeat (2) @(negedge clk);
reset = 1;
dly = 0;
req = 0;
repeat (2) @(negedge clk);

// Test case 4: IDLE > BUSY > FREE > IDLE
repeat (3) @(negedge clk);
req = 1;
repeat (1) @(negedge clk);
done = 1;
dly = 0;
req = 0;
@(negedge clk) done = 0;
repeat (2) @(negedge clk);


$stop;

end  // End initial begin

always
	#5 clk = ~clk;


// For display

always @ (posedge gnt) begin
$display("%t : gnt becomes 1.", $time);
end

always @ (negedge gnt) begin
$display("%t : gnt becomes 0.", $time);
end

always @ (posedge tout) begin
$display("%t : tout becomes 1.", $time);
end

always @ (negedge tout) begin
$display("%t : tout becomes 0.", $time);
end


endmodule
