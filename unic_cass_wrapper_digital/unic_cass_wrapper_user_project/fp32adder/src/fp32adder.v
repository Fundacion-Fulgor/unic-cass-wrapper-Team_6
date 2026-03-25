module fp32adder(
    `ifdef USE_POWER_PINS
    inout VPWR,    // Common digital supply
    inout VGND,    // Common digital ground
    `endif
    input  wire clk_i,
    input  wire rst_ni,
    input  wire go,
    input  wire inpab,
    output wire shift,
    output wire out_c,
    output wire over,
    output wire under,
    output wire done
);

    add_float add_float_inst(
    `ifdef USE_POWER_PINS
    .VPWR   (VPWR),
    .VGND   (VGND),
    `endif
    .clk   (clk_i),
    .reset (rst_ni),
    .go    (go),
    .inpab (inpab),
    .shift (shift),
    .out_c (out_c),
    .over  (over),
    .under (under),
    .done  (done)
    );

endmodule
