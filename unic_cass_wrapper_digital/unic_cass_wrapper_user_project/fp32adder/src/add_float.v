// Verilog 2001 code
module add_float (
    `ifdef USE_POWER_PINS
    inout VPWR,    // Common digital supply
    inout VGND,    // Common digital ground
    `endif
    input  clk,
    input  reset,
    input  go,
    input  inpab,
    output shift,
    output out_c,
    output over,
    output under,
    output done
);

    // control signals between controller (FSM) and datapath
    wire lda, ldb, ldc, lde, ldt, ldex, ldm;
    wire shr, shlm, shrm;
    wire ince, dece, ope;
    wire sig_a, sig_b, cy;
    wire mant23;
    wire [7:0] diff;
    wire [23:0] suma;
    wire [7:0] expo;

    // Instantiate the control module
    control U_FSM (
        `ifdef USE_POWER_PINS
        .VPWR   (VPWR),
        .VGND   (VGND),
        `endif
        .clk(clk),
        .reset(reset),
        .go(go),
        .sig_a(sig_a),
        .sig_b(sig_b),
        .diff(diff),
        .suma(suma),
        .cy(cy),
        .expo(expo),
        .mant23(mant23),
	.shift(shift),
        .lda(lda),
        .ldb(ldb),
        .ldc(ldc),
        .lde(lde),
        .ldex(ldex),
        .ldm(ldm),
        .ldt(ldt),
        .shr(shr),
        .shlm(shlm),
        .shrm(shrm),
        .ince(ince),
        .dece(dece),
        .ope(ope),
        .over(over),
        .under(under),
        .done(done)
    );

    // Instantiate the datapath module
    datapath U_DATA (
        `ifdef USE_POWER_PINS
        .VPWR   (VPWR),
        .VGND   (VGND),
        `endif
        .clk(clk),
        .reset(reset),
        .lda(lda),
        .inpab(inpab),
        .ldb(ldb),
        .ldc(ldc),
        .lde(lde),
        .ldt(ldt),
        .shr(shr),
        .ldex(ldex),
        .ince(ince),
        .dece(dece),
        .ldm(ldm),
        .shlm(shlm),
        .shrm(shrm),
        .ope(ope),
        .sig_a(sig_a),
        .sig_b(sig_b),
        .diff(diff),
        .suma(suma),
        .cy(cy),
        .mant23(mant23),
        .expo(expo),
        .out_c(out_c)
    );

endmodule
