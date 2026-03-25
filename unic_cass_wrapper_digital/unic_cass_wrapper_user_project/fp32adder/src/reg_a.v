// Verilog 2001 
module reg_a (
    `ifdef USE_POWER_PINS
    inout VPWR,    // Common digital supply
    inout VGND,    // Common digital ground
    `endif
    input  clk,
    input  reset,
    input  lda,
    input  inp_a,
    output [31:0] out_a
);

    reg [31:0] r_reg = 32'b0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_reg <= 32'b0;
        end else begin
            if (lda) begin
                r_reg <= {r_reg[30:0], inp_a};
            end
        end
    end

    assign out_a = r_reg;

endmodule
