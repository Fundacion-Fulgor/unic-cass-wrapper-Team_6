// Verilog 2001 code
module reg_b (
    `ifdef USE_POWER_PINS
    inout VPWR,    // Common digital supply
    inout VGND,    // Common digital ground
    `endif
    input  clk,
    input  reset,
    input  ldb,
    input  inp_b,
    output [31:0] out_b
);

    reg [31:0] r_reg = 32'b0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_reg <= 32'b0;
        end else begin
            if (ldb) begin
                r_reg <= {r_reg[30:0], inp_b};
            end
        end
    end

    assign out_b = r_reg;

endmodule
