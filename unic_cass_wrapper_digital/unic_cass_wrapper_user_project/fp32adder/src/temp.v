// Verilog 2001 code
module temp (
    `ifdef USE_POWER_PINS
    inout VPWR,    // Common digital supply
    inout VGND,    // Common digital ground
    `endif
    input  clk,
    input  reset,
    input  ldt,
    input  shr,
    input  [22:0] inp_temp,
    output [23:0] out_temp
);

    // Internal signal equivalent to VHDL's temp_out,
    // declared as 'reg' because it is assigned within an always block.
    reg [23:0] temp_reg;

    // The 'always' block describes the sequential logic.
    // The sensitivity list includes both the clock and the reset signal
    // to model an asynchronous, active-high reset.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Asynchronous reset: The register is cleared immediately
            // when the reset signal is high.
            temp_reg <= 24'b0;
        end else if (ldt) begin
            // Synchronous Load: On the rising edge of the clock,
            // if 'ldt' is high, load the input data.
            // The MSB (bit 23) is set to '1' and the rest of the bits
            // are loaded from the 23-bit input vector.
            temp_reg <= {1'b1, inp_temp};
        end else if (shr) begin
            // Synchronous Right Shift: If 'ldt' is low and 'shr' is high,
            // perform a logical right shift on the register.
            // A '0' is shifted into the MSB.
            temp_reg <= {1'b0, temp_reg[23:1]};
        end
    end
    // This is a continuous assignment that connects the internal register
    // to the output port. The output port is implicitly a 'wire'.
    assign out_temp = temp_reg;

endmodule
