// Verilog 2001 code
module mant (
    `ifdef USE_POWER_PINS
    inout VPWR,    // Common digital supply
    inout VGND,    // Common digital ground
    `endif
    input  clk,
    input  reset,
    input  ldm,
    input  shlm,
    input  shrm,
    input  cy,
    input  [23:0] inp_mant,
    output [23:0] out_mant
);

    reg [23:0] temp_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            temp_reg <= 24'b0;
        end else begin
            if (ldm) begin
                temp_reg <= inp_mant;
            end else if (shrm) begin
                temp_reg <= {cy, temp_reg[23:1]}; // shift right, MSB <- cy
            end else if (shlm) begin
                temp_reg <= {temp_reg[22:0], 1'b0}; // shift left, LSB <- 0
            end
        end
    end

    assign out_mant = temp_reg;

endmodule
