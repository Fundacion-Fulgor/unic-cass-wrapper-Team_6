// Verilog 2001 code
module small_alu (
    `ifdef USE_POWER_PINS
    inout VPWR,    // Common digital supply
    inout VGND,    // Common digital ground
    `endif
    input  [7:0] exp_a,
    input  [7:0] exp_b,
    output [7:0] diff
);

    // Internal signals equivalent to VHDL signals
    reg [7:0] tmp_bb;
    reg [8:0] tmp_cy;
	reg [7:0] diff_reg;
    integer i;

    // Combinational logic block
    // The @(*) sensitivity list is a Verilog 2001 feature that automatically
    // includes all signals used as inputs inside the block.
    always @(exp_a or exp_b or tmp_bb or tmp_cy) begin
        // Set the initial carry-in bit to 1 for 2's complement subtraction (A + ~B + 1)
        tmp_cy[0] = 1'b1;
        // Loop through each bit to perform the subtraction
        for (i = 0; i < 8; i = i + 1) begin
            // Step 1: Invert the bits of B (1's complement)
            tmp_bb[i] = ~exp_b[i];
            // Step 2: Calculate the sum bit using the full adder equation
            // Sum = A XOR B XOR Carry_in
            diff_reg[i] = exp_a[i] ^ tmp_bb[i] ^ tmp_cy[i];
            // Step 3: Calculate the carry-out for the next bit
            // Carry_out = (A AND B) OR (A AND Carry_in) OR (B AND Carry_in)
            tmp_cy[i+1] = (exp_a[i] & tmp_bb[i]) | (exp_a[i] & tmp_cy[i]) | (tmp_bb[i] & tmp_cy[i]);
        end
    end
    // Assign the internal registers to the output ports
    assign diff = diff_reg;
	
endmodule
