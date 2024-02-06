module cam#(
	parameter CNT_N = 32, /* number of entries */
	parameter KEY_W = 8,
	localparam ADDR_W = $clog2(CNT_N) 
)(
	input nreset,
	input clk,

	/* alloc */
	input             alloc_i,
	input [CNT_N-1:0] alloc_pos_i,
	input [KEY_W-1:0] alloc_key_i, 	

	/* read */
	input             rd_i,
	input [KEY_W-1:0] rd_key_i,

	output              match_o,
	output [ADDR_W-1:0] addr_o,

	/* collision error, trying to re-assign exiting content */
	output error_o
);

/* table */
reg [KEY_W-1:0] line_q[CNT_N-1:0];
reg [CNT_N-1:0] line_v_q;

/* key match */
logic [CNT_N-1:0]  match;

genvar i;
generate
for(i=0; i< CNT_N; i++) begin
	always @(posedge(clk))begin
		if (~nreset) begin
			line_v_q[i] <= 1'b0;
			line_q[i] <= {KEY_W{1'bx}};
		end else if (alloc_pos_i[i])begin
			line_q[i] <= alloc_key_i;
			line_v_q[i] <= line_v_q[i] | alloc_i;
		end
	end

	assign match[i] = ( line_q[i] == rd_key_i ) & line_v_q[i];
end
endgenerate

/* convert match to decimal address */
logic [ADDR_W-1:0] match_addr;
always_comb begin
	match_addr = {ADDR_W{1'bX}}; //default
	for( int x=0; x <= CNT_N; x++ ) begin
		/* verilator lint_off WIDTHTRUNC */
		if ( match[x] == 1'b1 ) match_addr = x;
		/* verilator lint_on WIDTHTRUNC */
	end
end
assign match_o = |match & rd_i;
assign addr_o = match_addr;

/* check if match is onehot */
logic onehot_v;
assign onehot_v = |(( match - {{CNT_N-1{1'b0}}, 1'b1}) & match ); 
assign error_o = rd_i & onehot_v;


`ifdef FORMAL

alloc_pos_onehot : assert( ~alloc_i | ( alloc_i & $onehot(allow_pos_i)));

`endif
endmodule
