module pwm1 (
`ifdef USE_POWER_PINS
    inout VPWR,   // Power supply (used for physical integration)
    inout VGND,   // Ground (used for physical integration)
`endif
    input  wire clk,
    input  wire rst_ni,          // Active-low asynchronous reset
    input  wire [1:0] ref_bits,  // Reference temperature level
    input  wire [1:0] state_bits,// Measured temperature level
    output reg  pwm_out          // PWM control output
);

    reg [1:0] counter;           // 2-bit PWM counter (period = 4)
    reg [1:0] effective_duty;    // Computed duty cycle

    // PWM counter (0–3)
    always @(posedge clk or negedge rst_ni) begin
        if (!rst_ni)
            counter <= 2'b00;
        else
            counter <= counter + 1'b1;
    end

    // Duty cycle computation
    always @(*) begin
        if (state_bits < ref_bits)
            effective_duty = ref_bits;              // Maximum duty
        else if (state_bits > ref_bits)
            effective_duty = state_bits - ref_bits; // Reduced duty
        else
            effective_duty = 2'b00;
    end

    // PWM generation
    always @(*) begin
        pwm_out = (counter < effective_duty);
    end

endmodule