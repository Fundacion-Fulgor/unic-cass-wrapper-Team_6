// Verilog 2001 code
module reg_c (
    `ifdef USE_POWER_PINS
    inout VPWR,    // Common digital supply
    inout VGND,    // Common digital ground
    `endif
    input  clk,
    input  reset,
    input  ldc,
    input  [31:0] inp_c,
    output out_c
);

    reg [31:0] r_reg = 32'b0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_reg <= 32'b0;
        end else begin
            if (ldc) begin
                r_reg <= inp_c;
			end else begin
				r_reg <= {r_reg[30:0], 1'b0};
            end
        end
    end

    assign out_c = r_reg[31];

endmodule
