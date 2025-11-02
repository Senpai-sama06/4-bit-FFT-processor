/**
 * Module: fft_4pt
 * Description: A 3-stage pipelined 4-point FFT implementation (Radix-2 DIT).
 *
 * Algorithm (Inputs in bit-reversed order: x[0], x[2], x[1], x[3]):
 * Stage 1:
 * A = x[0] + x[2]
 * B = x[0] - x[2]
 * C = x[1] + x[3]
 * D = x[1] - x[3]
 *
 * Stage 2 (with twiddle factors W4_0=1, W4_1=-j):
 * X[0] = A + C
 * X[1] = B + (D * -j) = B + (Dr + j*Di) * -j = B + (Di - j*Dr)
 * X[2] = A - C
 * X[3] = B - (D * -j) = B - (Di - j*Dr)
 */
module fft_4pt #(
    parameter DATA_WIDTH = 16
) (
    input clk,
    input rst_n,
    input data_valid_in,

    // Inputs (x[0], x[1], x[2], x[3])
    input  signed [DATA_WIDTH-1:0] x0_r,
    input  signed [DATA_WIDTH-1:0] x0_i,
    input  signed [DATA_WIDTH-1:0] x1_r,
    input  signed [DATA_WIDTH-1:0] x1_i,
    input  signed [DATA_WIDTH-1:0] x2_r,
    input  signed [DATA_WIDTH-1:0] x2_i,
    input  signed [DATA_WIDTH-1:0] x3_r,
    input  signed [DATA_WIDTH-1:0] x3_i,

    output data_valid_out,

    // Outputs (X[0], X[1], X[2], X[3])
    output signed [DATA_WIDTH+1:0] X0_r,
    output signed [DATA_WIDTH+1:0] X0_i,
    output signed [DATA_WIDTH+1:0] X1_r,
    output signed [DATA_WIDTH+1:0] X1_i,
    output signed [DATA_WIDTH+1:0] X2_r,
    output signed [DATA_WIDTH+1:0] X2_i,
    output signed [DATA_WIDTH+1:0] X3_r,
    output signed [DATA_WIDTH+1:0] X3_i
);

    // Pipeline stage widths
    localparam S1_WIDTH = DATA_WIDTH + 1;
    localparam S2_WIDTH = DATA_WIDTH + 2;

    // --- Stage 0: Input Registers ---
    // Registers for inputs (bit-reversed order: 0, 2, 1, 3)
    reg signed [DATA_WIDTH-1:0] x0_r_reg, x0_i_reg;
    reg signed [DATA_WIDTH-1:0] x2_r_reg, x2_i_reg;
    reg signed [DATA_WIDTH-1:0] x1_r_reg, x1_i_reg;
    reg signed [DATA_WIDTH-1:0] x3_r_reg, x3_i_reg;
    reg valid_s0;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x0_r_reg <= 0; x0_i_reg <= 0;
            x2_r_reg <= 0; x2_i_reg <= 0;
            x1_r_reg <= 0; x1_i_reg <= 0;
            x3_r_reg <= 0; x3_i_reg <= 0;
            valid_s0 <= 1'b0;
        end else begin
            x0_r_reg <= x0_r; x0_i_reg <= x0_i;
            x2_r_reg <= x2_r; x2_i_reg <= x2_i;
            x1_r_reg <= x1_r; x1_i_reg <= x1_i;
            x3_r_reg <= x3_r; x3_i_reg <= x3_i;
            valid_s0 <= data_valid_in;
        end
    end

    // --- Stage 1: First Butterfly ---
    // Intermediate values (A, B, C, D)
    wire signed [S1_WIDTH-1:0] A_r, A_i, B_r, B_i;
    wire signed [S1_WIDTH-1:0] C_r, C_i, D_r, D_i;
    
    // Butterfly 1.1 (x0, x2)
    assign A_r = x0_r_reg + x2_r_reg;
    assign A_i = x0_i_reg + x2_i_reg;
    assign B_r = x0_r_reg - x2_r_reg;
    assign B_i = x0_i_reg - x2_i_reg;
    
    // Butterfly 1.2 (x1, x3)
    assign C_r = x1_r_reg + x3_r_reg;
    assign C_i = x1_i_reg + x3_i_reg;
    assign D_r = x1_r_reg - x3_r_reg;
    assign D_i = x1_i_reg - x3_i_reg;

    // Pipeline Registers for Stage 1 results
    reg signed [S1_WIDTH-1:0] A_r_reg, A_i_reg, B_r_reg, B_i_reg;
    reg signed [S1_WIDTH-1:0] C_r_reg, C_i_reg, D_r_reg, D_i_reg;
    reg valid_s1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            A_r_reg <= 0; A_i_reg <= 0;
            B_r_reg <= 0; B_i_reg <= 0;
            C_r_reg <= 0; C_i_reg <= 0;
            D_r_reg <= 0; D_i_reg <= 0;
            valid_s1 <= 1'b0;
        end else begin
            A_r_reg <= A_r; A_i_reg <= A_i;
            B_r_reg <= B_r; B_i_reg <= B_i;
            C_r_reg <= C_r; C_i_reg <= C_i;
            D_r_reg <= D_r; D_i_reg <= D_i;
            valid_s1 <= valid_s0;
        end
    end

    // --- Stage 2: Second Butterfly & Twiddles ---
    // Combinational logic for final outputs
    wire signed [S2_WIDTH-1:0] X0_r_w, X0_i_w;
    wire signed [S2_WIDTH-1:0] X1_r_w, X1_i_w;
    wire signed [S2_WIDTH-1:0] X2_r_w, X2_i_w;
    wire signed [S2_WIDTH-1:0] X3_r_w, X3_i_w;

    // X[0] = A + C
    assign X0_r_w = A_r_reg + C_r_reg;
    assign X0_i_w = A_i_reg + C_i_reg;

    // X[1] = B + D*(-j) = (Br + j*Bi) + (Dr + j*Di)*(-j) = (Br + j*Bi) + (Di - j*Dr)
    assign X1_r_w = B_r_reg + D_i_reg;
    assign X1_i_w = B_i_reg - D_r_reg;

    // X[2] = A - C
    assign X2_r_w = A_r_reg - C_r_reg;
    assign X2_i_w = A_i_reg - C_i_reg;

    // X[3] = B - D*(-j) = (Br + j*Bi) - (Di - j*Dr)
    assign X3_r_w = B_r_reg - D_i_reg;
    assign X3_i_w = B_i_reg + D_r_reg;
    
    // Output Registers
    reg signed [S2_WIDTH-1:0] X0_r_reg, X0_i_reg;
    reg signed [S2_WIDTH-1:0] X1_r_reg, X1_i_reg;
    reg signed [S2_WIDTH-1:0] X2_r_reg, X2_i_reg;
    reg signed [S2_WIDTH-1:0] X3_r_reg, X3_i_reg;
    reg valid_s2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            X0_r_reg <= 0; X0_i_reg <= 0;
            X1_r_reg <= 0; X1_i_reg <= 0;
            X2_r_reg <= 0; X2_i_reg <= 0;
            X3_r_reg <= 0; X3_i_reg <= 0;
            valid_s2 <= 1'b0;
        end else begin
            X0_r_reg <= X0_r_w; X0_i_reg <= X0_i_w;
            X1_r_reg <= X1_r_w; X1_i_reg <= X1_i_w;
            X2_r_reg <= X2_r_w; X2_i_reg <= X2_i_w;
            X3_r_reg <= X3_r_w; X3_i_reg <= X3_i_w;
            valid_s2 <= valid_s1;
        end
    end

    // --- Output Assignments ---
    assign X0_r = X0_r_reg;
    assign X0_i = X0_i_reg;
    assign X1_r = X1_r_reg;
    assign X1_i = X1_i_reg;
    assign X2_r = X2_r_reg;
    assign X2_i = X2_i_reg;
    assign X3_r = X3_r_reg;
    assign X3_i = X3_i_reg;
    assign data_valid_out = valid_s2;

endmodule
