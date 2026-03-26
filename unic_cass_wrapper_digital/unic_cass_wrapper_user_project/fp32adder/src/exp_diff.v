// Verilog 2001 code
module exp_diff (
    `ifdef USE_POWER_PINS
    inout VPWR,    // Common digital supply
    inout VGND,    // Common digital ground
    `endif
    input  clk,
    input  reset,
    input  lde,
    input  [7:0] inp_exp_diff,
    output [7:0] out_exp_diff
);
    // Declare output port as a `reg` since it is assigned in a procedural block
    reg [7:0] temp_reg;

    // Sequential logic for the register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            temp_reg <= 8'h00; // Reset output to all zeros
        end else if (lde) begin
            temp_reg <= inp_exp_diff; // Load new value on positive clock edge if lde is high
        end
    end

    // Assign the internal register to the output port
    assign out_exp_diff = temp_reg;

endmodule
