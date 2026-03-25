// Verilog 2001 code
module big_alu (
    `ifdef USE_POWER_PINS
    inout VPWR,    // Common digital supply
    inout VGND,    // Common digital ground
    `endif
    input  ope,
    input  [22:0] rega,
    input  [23:0] temp,
    output [23:0] suma,
    output cy
);

    // Internal signals
    wire [23:0] temp_rega;
    reg  [23:0] temp_xor;
    reg  [24:0] temp_cy;
    reg  [23:0] suma_reg;
    reg  cy_reg;

    // Continuous assignments for parts of the logic that are not in the procedural block.
    // This is required in Verilog 2001.
    assign temp_rega[22:0] = rega[22:0];
    assign temp_rega[23] = 1'b1;
    integer i;
		
    // The VHDL process is translated to an always block with all inputs and
    // internal signals in the sensitivity list.
    always @(ope or rega or temp or temp_rega or temp_xor or temp_cy) begin
        // Note: The `*` in `always @(*)` is the Verilog 2001 shorthand for this.
        // I am writing out the full list for clarity, as requested by the user's VHDL process.
        temp_cy[0] = ope;

        // A for loop is used for the bit-wise operations.
        // The loop variable must be declared with `integer` outside the loop in Verilog 2001.
        for (i = 0; i <= 23; i = i + 1) begin
            temp_xor[i] = temp[i] ^ ope;
            suma_reg[i] = temp_rega[i] ^ temp_xor[i] ^ temp_cy[i];
            temp_cy[i+1] = (temp_rega[i] & temp_xor[i]) | (temp_rega[i] & temp_cy[i]) | (temp_xor[i] & temp_cy[i]);
        end
    
        // The conditional assignment for cy
        if (ope == 1'b1) begin
            cy_reg = 1'b0;
        end else begin
            cy_reg = temp_cy[24];
        end
    end
    // Assign the internal registers to the output ports
    assign suma = suma_reg;
    assign cy = cy_reg;

endmodule
