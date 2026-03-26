// Verilog 2001 code
module expo (
   `ifdef USE_POWER_PINS
    inout VPWR,    // Common digital supply
    inout VGND,    // Common digital ground
    `endif
    input  clk,
    input  reset,
    input  ldex,
    input  ince,
    input  dece,
    input  [7:0] inp_expo,
    output [7:0] out_expo
);

    reg [7:0] temp_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            temp_reg <= 8'b00000000;
        end else begin
            if (ldex) begin
                temp_reg <= inp_expo;
            end else if (ince) begin
                temp_reg <= temp_reg + 1'b1;
            end else if (dece) begin
                temp_reg <= temp_reg - 1'b1;
            end
        end
    end

    assign out_expo = temp_reg;

endmodule
