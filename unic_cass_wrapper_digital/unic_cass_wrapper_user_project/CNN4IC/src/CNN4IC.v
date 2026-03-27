module CNN4IC(
    `ifdef USE_POWER_PINS
    inout VPWR,
    inout VGND,
    `endif
    input  wire clk_i,
    input  wire rst_ni,
    input  wire [16:0] ui_PAD2CORE,
    output wire [16:0] uo_CORE2PAD
);

    CNNver2 cnn_inst (
        .CNNver2_SPICLOCK_50  (clk_i),
        .CNNver2_Reset_InHigh (~rst_ni),
        .CNNver2_SS_N         (ui_PAD2CORE[1]),
        .CNNver2_MOSI         (ui_PAD2CORE[2]),
        .CNNver2_CMD_Reset    (ui_PAD2CORE[4]),
        .CNNver2_MISO         (uo_CORE2PAD[0]),
        .CNNver2_MR1_Load     (uo_CORE2PAD[1]),
        .CNNver2_MR2_Load     (uo_CORE2PAD[2])
    );
    assign uo_CORE2PAD[16:3] = 14'b0;

endmodule