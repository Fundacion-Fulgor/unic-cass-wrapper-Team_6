//=======================================================
//  CNNver2 — Top Level (arquitectura reorganizada)
//=======================================================
//  Puertos externos (8):
//    CNNver2_MISO         — resultado final al exterior (SPI)
//    CNNver2_SPICLOCK_50  — reloj SPI
//    CNNver2_SS_N         — Chip Select (activo bajo)
//    CNNver2_MOSI         — datos/comandos del master
//    CNNver2_Reset_InHigh — reset global (activo alto)
//    CNNver2_CMD_Reset    — aborta comando SPI en curso
//    CNNver2_MR1_Load     — DEBUG: pulso activo bajo al cargar acc0 en MR1
//    CNNver2_MR2_Load     — DEBUG: pulso activo bajo al cargar acc1 en MR2
//
//  Flujo de uso desde MCU (sin cambios):
//    cmd 000 → carga imagen 10×10
//    cmd 001 → carga kernel0
//    cmd 010 → START → procesa kernel0 → acc0 → MR1
//    cmd 001 → carga kernel1
//    cmd 010 → START → procesa kernel1 → acc1 → MR2
//    cmd 110 → lee 1 bit comparador (MR1 > MR2) → clasificación
//
//  Jerarquía nueva:
//    CNNver2
//     ├── comm_mem_top              (comunicación + memoria)
//     │    ├── spi_cnn_slave_8
//     │    ├── Register_Imag  ×10
//     │    ├── Register_Weight ×5
//     │    ├── Master_register (MR1)
//     │    └── Master_register (MR2)
//     └── cnn_proc_top              (lógica + procesamiento)
//          ├── SC_STATEMACHINE_CNN_CTRL
//          │    └── cnn_top
//          │         ├── fragment_mux_10x10_6x6
//          │         └── mux_cnn
//          │              ├── window_mux_6x6_5x5
//          │              ├── mac_parallel
//          │              └── progressive_maxpool
//          └── Comparador (combinacional)
//=======================================================

module CNNver2 (
    output wire CNNver2_MISO,
    input  wire CNNver2_SPICLOCK_50,
    input  wire CNNver2_SS_N,
    input  wire CNNver2_MOSI,
    input  wire CNNver2_Reset_InHigh,
    input  wire CNNver2_CMD_Reset,
    output wire CNNver2_MR1_Load,     // DEBUG: activo bajo, pulso al cargar MR1
    output wire CNNver2_MR2_Load      // DEBUG: activo bajo, pulso al cargar MR2
);

    // ── Parámetros ────────────────────────────────────
    localparam DATAWIDTH_BUS        = 8;
    localparam DATAWIDTH_BUS_IMAGE  = 10;
    localparam DATAWIDTH_BUS_WEIGHT = 5;
    localparam BITS_PER_POS         = 3;
    localparam DATAWIDTH_BUS_FULL   = DATAWIDTH_BUS_IMAGE  * BITS_PER_POS; // 30
    localparam DATAWIDTH_WGT_FULL   = DATAWIDTH_BUS_WEIGHT * BITS_PER_POS; // 15

    // ── Wires entre comm_mem_top ↔ cnn_proc_top ──────

    // Imagen lista (comm_mem → proc)
    wire [DATAWIDTH_BUS_FULL-1:0] img_row00, img_row01, img_row02, img_row03, img_row04;
    wire [DATAWIDTH_BUS_FULL-1:0] img_row05, img_row06, img_row07, img_row08, img_row09;

    // Pesos listos (comm_mem → proc)
    wire [DATAWIDTH_WGT_FULL-1:0] wgt_row00, wgt_row01, wgt_row02, wgt_row03, wgt_row04;

    // Control (comm_mem → proc)
    wire start_cnn;

    // Resultados (proc → comm_mem)
    wire [15:0] acc0, acc1;
    wire        mr1_load, mr2_load;   // activo bajo

    // Resultado clasificación (proc → exterior, solo debug/info)
    wire comp_result;

    // ══════════════════════════════════════════════════
    // SUBTOP 1 — Comunicación y Memoria
    // ══════════════════════════════════════════════════
    comm_mem_top #(
        .DATAWIDTH_BUS       (DATAWIDTH_BUS),
        .DATAWIDTH_BUS_IMAGE (DATAWIDTH_BUS_IMAGE),
        .DATAWIDTH_BUS_WEIGHT(DATAWIDTH_BUS_WEIGHT),
        .BITS_PER_POS        (BITS_PER_POS)
    ) comm_mem_u0 (
        // SPI externo
        .i_SPI_Clk   (CNNver2_SPICLOCK_50),
        .i_SPI_CS_n  (CNNver2_SS_N),
        .i_SPI_MOSI  (CNNver2_MOSI),
        .o_SPI_MISO  (CNNver2_MISO),
        .i_RESET     (CNNver2_Reset_InHigh),
        .i_CMD_Reset (CNNver2_CMD_Reset),
        // Debug
        .o_MR1_Load_dbg(CNNver2_MR1_Load),
        .o_MR2_Load_dbg(CNNver2_MR2_Load),
        // Imagen hacia proc
        .o_img_row00(img_row00), .o_img_row01(img_row01), .o_img_row02(img_row02),
        .o_img_row03(img_row03), .o_img_row04(img_row04), .o_img_row05(img_row05),
        .o_img_row06(img_row06), .o_img_row07(img_row07), .o_img_row08(img_row08),
        .o_img_row09(img_row09),
        // Pesos hacia proc
        .o_wgt_row00(wgt_row00), .o_wgt_row01(wgt_row01), .o_wgt_row02(wgt_row02),
        .o_wgt_row03(wgt_row03), .o_wgt_row04(wgt_row04),
        // Control hacia proc
        .o_start_cnn(start_cnn),
        // Resultados desde proc
        .i_acc0      (acc0),
        .i_mr1_load  (mr1_load),
        .i_acc1      (acc1),
        .i_mr2_load  (mr2_load),
        // Comparador desde proc
        .i_comp_result(comp_result)
    );

    // ══════════════════════════════════════════════════
    // SUBTOP 2 — Lógica y Procesamiento CNN
    // ══════════════════════════════════════════════════
    cnn_proc_top proc_u0 (
        .i_CLOCK    (CNNver2_SPICLOCK_50),
        .i_RESET    (CNNver2_Reset_InHigh),
        // Control desde comm_mem
        .i_start_cnn(start_cnn),
        // Imagen
        .i_img_row00(img_row00), .i_img_row01(img_row01), .i_img_row02(img_row02),
        .i_img_row03(img_row03), .i_img_row04(img_row04), .i_img_row05(img_row05),
        .i_img_row06(img_row06), .i_img_row07(img_row07), .i_img_row08(img_row08),
        .i_img_row09(img_row09),
        // Pesos
        .i_wgt_row00(wgt_row00), .i_wgt_row01(wgt_row01), .i_wgt_row02(wgt_row02),
        .i_wgt_row03(wgt_row03), .i_wgt_row04(wgt_row04),
        // Resultados hacia comm_mem (Master Registers)
        .o_acc0    (acc0),
        .o_mr1_load(mr1_load),
        .o_acc1    (acc1),
        .o_mr2_load(mr2_load),
        // Clasificación
        .o_comp_result(comp_result),
        .o_done()
    );

endmodule

