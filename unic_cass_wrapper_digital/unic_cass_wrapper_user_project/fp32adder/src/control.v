// Verilog 2001 code
module control (
   `ifdef USE_POWER_PINS
    inout VPWR,    // Common digital supply
    inout VGND,    // Common digital ground
    `endif
    input  clk,
    input  reset,
    input  go,
    input  sig_a,
    input  sig_b,
    input  [7:0] diff,
    input  [23:0] suma,
    input  cy,
    input  [7:0] expo,
    input  mant23,
    output shift,
    output lda,
    output ldb,
    output ldc,
    output lde,
    output ldex,
    output ldm,
    output ldt,
    output shr,
    output shlm,
    output shrm,
    output ince,
    output dece,
    output ope,
    output over,
    output under,
    output done
);

// State machine encoding
localparam 
    A = 5'd0,   B = 5'd1,   Ca = 5'd2, Cb = 5'd3, C = 5'd4,  D = 5'd5,  
    E = 5'd6,   F = 5'd7,   G = 5'd8,  H = 5'd9,  I = 5'd10, J = 5'd11, K = 5'd12, 
    La = 5'd13, Lb = 5'd14, L = 5'd15, M = 5'd16, N = 5'd17, O = 5'd18;

// Internal signals
reg [4:0] est;
reg [7:0] cnt;
reg [4:0] cnt2;
reg lda_reg, ldb_reg, ldc_reg, lde_reg, ldex_reg;
reg ldm_reg, ldt_reg, shr_reg, shlm_reg, shrm_reg, shift_reg;
reg ince_reg, dece_reg, ope_reg, over_reg, under_reg, done_reg;

// Main state machine logic
always @(posedge clk or posedge reset) begin
    if (reset) begin
        // Reset state
        lda_reg <= 1'b0; ldb_reg <= 1'b0; ldc_reg <= 1'b0; lde_reg <= 1'b0; ldex_reg <= 1'b0;
        ldm_reg <= 1'b0; ldt_reg <= 1'b0; shr_reg <= 1'b0; shlm_reg <= 1'b0; shrm_reg <= 1'b0; shift_reg <= 1'b0;
        ince_reg <= 1'b0; dece_reg <= 1'b0; ope_reg <= 1'b0; over_reg <= 1'b0; under_reg <= 1'b0; done_reg <= 1'b0;
        cnt <= 8'h00; cnt2 <= 5'b0;
        est <= A;
    end else begin
        // State transitions and output assignments based on current state
        case (est)
            A: begin // reset state
                lda_reg <= 1'b0; ldb_reg <= 1'b0; ldc_reg <= 1'b0; lde_reg <= 1'b0; ldex_reg <= 1'b0;
                ldm_reg <= 1'b0; ldt_reg <= 1'b0; shr_reg <= 1'b0; shlm_reg <= 1'b0; shrm_reg <= 1'b0; shift_reg <= 1'b0;
                ince_reg <= 1'b0; dece_reg <= 1'b0; ope_reg <= 1'b0; over_reg <= 1'b0; under_reg <= 1'b0; done_reg <= 1'b0;
                cnt <= 8'h00; cnt2 <= 5'b0;
                est <= B;
            end
            B: begin // waiting for go='0'
                if (go == 1'b1) begin
                    est <= B;
                end else begin
                    lda_reg <= 1'b1; shift_reg <= 1'b1;
                    est <= Ca;
                end
            end
            Ca: begin // load reg_a by shift-in to the left 32 bits from LSB
                if (cnt2 < 31) begin
                    lda_reg  <= 1'b1; shift_reg <= 1'b1;
                    cnt2 <= cnt2 + 1'b1;
                    est  <= Ca;
                end else begin
                    lda_reg  <= 1'b0; ldb_reg  <= 1'b1; shift_reg <= 1'b1;
                    cnt2 <= 5'b0;
                    est  <= Cb;
                end
            end
            Cb: begin // load reg_b by shift-in to the left 32 bits from LSB
                if (cnt2 < 31) begin
                    ldb_reg  <= 1'b1; shift_reg <= 1'b1;
                    cnt2 <= cnt2 + 1'b1;
                    est  <= Cb;
                end else begin
                    ldb_reg  <= 1'b0; shift_reg <= 1'b0;
                    cnt2 <= 5'b0;
                    est  <= C;
                end
            end
            C: begin // load reg_a and reg_b with operands
                lda_reg <= 1'b0; ldb_reg <= 1'b0; lde_reg <= 1'b1; ldt_reg <= 1'b1;
                est <= D;
            end
            D: begin // load exp_diff with the difference of (reg_a'exponent - reg_b'exponent)
                // also, load temp with reg_b' mantissa
                ope_reg <= sig_a ^ sig_b;
                lde_reg <= 1'b0; ldt_reg <= 1'b0;
                est <= E;
            end
            E: begin
                cnt <= diff;
                est <= F;
            end
            F: begin // shift right temp while cnt > 0
                if (cnt == 8'h00) begin
                    shr_reg <= 1'b0; ldm_reg <= 1'b1; ldex_reg <= 1'b1; // load mant and expo
                    est <= G;
                end else begin
                    cnt <= cnt - 1'b1; 
                    shr_reg <= 1'b1; ldm_reg <= 1'b0; ldex_reg <= 1'b0;
                    est <= F;
                end
            end
            G: begin // load mant with big_alu output and expo with reg_a's exponent
                ldm_reg <= 1'b0; ldex_reg <= 1'b0;
                est <= H;
            end
            H: begin // align mant and modify expo accordingly
                if (cy == 1'b1) begin // shr mant and increment expo
                    shrm_reg <= 1'b1; ince_reg <= 1'b1;
                    est <= I;
                end else if ((|suma) && (suma[23] == 1'b0)) begin // shl mant and decrement expo
                    shlm_reg <= 1'b1; dece_reg <= 1'b1;
                    est <= J;
                end else if ((|suma) && (suma[23] == 1'b1)) begin // result is aligned
                    ldc_reg <= 1'b1;
                    est <= La;
                end else begin // underflow (all bits of suma are zero)
                    under_reg <= 1'b1;
                    est <= M;
                end
            end
            I: begin // cy was '1', verify for overflow
                shrm_reg <= 1'b0; ince_reg <= 1'b0;
                if (expo >= 8'hfe) begin // 2026-01-30 overflow will occur next clock, since expo will be incremented to xff
                    over_reg <= 1'b1;
                    est <= N;
                end else begin // alignment is OK
                    ldc_reg <= 1'b1;
                    est <= La;
                end
            end
            J: begin // cy = 0, suma[23] was 0, and suma != 0
                if (expo <= 8'h01) begin // 2026-01-31 underflow will occur next clock, since expo will be decremented to x00
                    shlm_reg <= 1'b0; dece_reg <= 1'b0;
                    under_reg <= 1'b1;
                    est <= M;
                end else if (mant23 == 1'b0) begin // keep doing shift left mant and decrement expo
                    shlm_reg <= 1'b0; dece_reg <= 1'b0;
                    est <= K;
                end
            end
            K: begin
                if (mant23 == 1'b0) begin
                    shlm_reg <= 1'b1; dece_reg <= 1'b1;
                    est <= J;
                end else begin
                    est <= O;
                end
            end
            L: begin // result is aligned, show the results
                ldc_reg <= 1'b0; done_reg <= 1'b0;
                est <= L;
            end
            M: begin // underflow state
                ldc_reg <= 1'b0; under_reg <= 1'b1; done_reg <= 1'b1;
                est <= M;
            end
            N: begin // overflow state
                ldc_reg <= 1'b0; over_reg <= 1'b1; done_reg <= 1'b1;
                est <= N;
            end
            O: begin // adjust mant
                ldc_reg <= 1'b1;
                est <= La;
            end
			La: begin
				ldc_reg <= 1'b0; done_reg <= 1'b1;
				est <= Lb;
			end
			Lb: begin // shift-out to the left 32 bits from reg_c
				if (cnt2 < 31) begin
					ldc_reg  <= 1'b0; done_reg <= 1'b1;
					cnt2 <= cnt2 + 1'b1;
					est  <= Lb;
				end else begin
					cnt2 <= 5'b0;
					done_reg <= 1'b0;
					est  <= L;
				end
			end
            default: begin
                est <= A;
            end
        endcase
    end
end

// Assign internal registers to output ports
assign lda   = lda_reg;
assign ldb   = ldb_reg;
assign ldc   = ldc_reg;
assign lde   = lde_reg;
assign ldex  = ldex_reg;
assign ldm   = ldm_reg;
assign ldt   = ldt_reg;
assign shift = shift_reg;
assign shr   = shr_reg;
assign shlm  = shlm_reg;
assign shrm  = shrm_reg;
assign ince  = ince_reg;
assign dece  = dece_reg;
assign ope   = ope_reg;
assign over  = over_reg;
assign under = under_reg;
assign done  = done_reg;

endmodule
