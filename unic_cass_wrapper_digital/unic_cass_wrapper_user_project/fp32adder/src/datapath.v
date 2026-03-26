// Verilog 2001 code
module datapath (
    `ifdef USE_POWER_PINS
    inout VPWR,    // Common digital supply
    inout VGND,    // Common digital ground
    `endif
    input  clk,
    input  reset,
    input  lda,
    input  inpab,
    input  ldb,
    input  ldc,
    input  lde,
    input  ldt,
    input  shr,
    input  ldex,
    input  ince,
    input  dece,
    input  ldm,
    input  shlm,
    input  shrm,
    input  ope,
    output sig_a,
    output sig_b,
    output [7:0] diff,
    output [23:0] suma,
    output cy,
    output mant23,
    output [7:0] expo,
    output out_c
);

// Internal signals (declared as `wire` as they are driven by module outputs or assign statements)
wire [31:0] out_a;
wire [31:0] out_b;
wire [23:0] temp;
wire [7:0]  small_res;
wire [23:0] big;
wire [23:0] mant;
wire [7:0]  exp;
wire carry;

// Continuous assignments for direct signal connections
assign sig_a = out_a[31];
assign sig_b = out_b[31];
assign suma = big;
assign cy = carry;
assign mant23 = mant[23];
assign expo = exp;

// Component Instantiations
reg_a U_REGA (
    `ifdef USE_POWER_PINS
    .VPWR   (VPWR),
    .VGND   (VGND),
    `endif
    .clk(clk),
    .reset(reset),
    .lda(lda),
    .inp_a(inpab),
    .out_a(out_a)
);
 
reg_b U_REGB (
    `ifdef USE_POWER_PINS
    .VPWR   (VPWR),
    .VGND   (VGND),
    `endif
    .clk(clk),
    .reset(reset),
    .ldb(ldb),
    .inp_b(inpab),
    .out_b(out_b)
);

reg_c U_REGC (
    `ifdef USE_POWER_PINS
    .VPWR   (VPWR),
    .VGND   (VGND),
    `endif
    .clk(clk),
    .reset(reset),
    .ldc(ldc),
    .inp_c({out_a[31], exp, mant[22:0]}), // Concatenation
    .out_c(out_c)
);
 
temp U_TEMP (
    `ifdef USE_POWER_PINS
    .VPWR   (VPWR),
    .VGND   (VGND),
    `endif
    .clk(clk),
    .reset(reset),
    .ldt(ldt),
    .shr(shr),
    .inp_temp(out_b[22:0]),
    .out_temp(temp)
);
 
exp_diff U_EXP_DIFF (
    `ifdef USE_POWER_PINS
    .VPWR   (VPWR),
    .VGND   (VGND),
    `endif
    .clk(clk),
    .reset(reset),
    .lde(lde),
    .inp_exp_diff(small_res),
    .out_exp_diff(diff)
);
 
mant U_MANT (
    `ifdef USE_POWER_PINS
    .VPWR   (VPWR),
    .VGND   (VGND),
    `endif
    .clk(clk),
    .reset(reset),
    .ldm(ldm),
    .shlm(shlm),
    .shrm(shrm),
    .cy(carry),
    .inp_mant(big),
    .out_mant(mant)
);
 
expo U_EXPO (
    `ifdef USE_POWER_PINS
    .VPWR   (VPWR),
    .VGND   (VGND),
    `endif
    .clk(clk),
    .reset(reset),
    .ldex(ldex),
    .ince(ince),
    .dece(dece),
    .inp_expo(out_a[30:23]),
    .out_expo(exp)
);
 
small_alu U_SMALL_ALU (
    `ifdef USE_POWER_PINS
    .VPWR   (VPWR),
    .VGND   (VGND),
    `endif
    .exp_a(out_a[30:23]),
    .exp_b(out_b[30:23]),
    .diff(small_res)
);
 
big_alu U_BIG_ALU (
    `ifdef USE_POWER_PINS
    .VPWR   (VPWR),
    .VGND   (VGND),
    `endif
    .ope(ope),
    .rega(out_a[22:0]),
    .temp(temp),
    .suma(big),
    .cy(carry)
);

endmodule
