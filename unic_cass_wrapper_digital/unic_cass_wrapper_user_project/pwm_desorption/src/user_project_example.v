module user_project_example(
`ifdef USE_POWER_PINS
    inout VPWR,
    inout VGND,
`endif
    input  wire        clk_i,
    input  wire        rst_ni,
    input  wire [16:0] ui_PAD2CORE,
    output wire [16:0] uo_CORE2PAD
);

    assign uo_CORE2PAD[16:1] = 16'd0;

    pwm1 pwm_inst (
`ifdef USE_POWER_PINS
        .VPWR       (VPWR),
        .VGND       (VGND),
`endif
        .clk        (clk_i),
        .rst_ni     (rst_ni),
        .ref_bits  (ui_PAD2CORE[1:0]),
        .state_bits(ui_PAD2CORE[3:2]),
        .pwm_out   (uo_CORE2PAD[0])
    );

endmodule
