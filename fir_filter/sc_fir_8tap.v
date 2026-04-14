// ============================================================================
// 文件: sc_fir_6tap.v
// 说明: 基于4阶SC-FIR改写的6阶版本 - 你的第一个练习项目
// ============================================================================

module sc_fir_8tap #(
    parameter WIDTH = 8
)(
    input wire clk,
    input wire rst_n,
    input wire sample_en,
    input wire [WIDTH-1:0] x_in,
    input wire [WIDTH-1:0] h0, h1, h2, h3, h4, h5, h6, h7,
    output wire [WIDTH:0] y_out,
    output wire out_valid
);

    // =========================================
    // 1. 6级延迟线
    // =========================================
    reg [WIDTH-1:0] x_d1, x_d2, x_d3, x_d4, x_d5, x_d6, x_d7;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x_d1 <= 0; x_d2 <= 0; x_d3 <= 0; x_d4 <= 0; x_d5 <= 0; x_d6 <= 0; x_d7 <= 0;
        end else if (sample_en) begin
            x_d1 <= x_in;
            x_d2 <= x_d1;
            x_d3 <= x_d2;
            x_d4 <= x_d3;
            x_d5 <= x_d4;
            x_d6 <= x_d5;
            x_d7 <= x_d6;
        end
    end

    // =========================================
    // 2. 6个独立的LFSR产生随机数
    // =========================================
    // TODO: 你来补充这部分
    // 需要定义6个wire[WIDTH-1:0]: rand_x, rand_h0, ..., rand_h5
    // 调用6个RNS_LFSR实例

    wire [WIDTH-1:0] rand_x, rand_h0, rand_h1, rand_h2, rand_h3, rand_h4, rand_h5, rand_h6, rand_h7, rand_mux;

    RNS_LFSR #(.WIDTH(WIDTH), .TAP(8'hB8)) lfsr_x   (.clk(clk), .rst_n(rst_n), .seed(8'd13),  .rand_out(rand_x));
    RNS_LFSR #(.WIDTH(WIDTH), .TAP(8'hB8)) lfsr_h0  (.clk(clk), .rst_n(rst_n), .seed(8'd45),  .rand_out(rand_h0));
    RNS_LFSR #(.WIDTH(WIDTH), .TAP(8'hB8)) lfsr_h1  (.clk(clk), .rst_n(rst_n), .seed(8'd99),  .rand_out(rand_h1));
    RNS_LFSR #(.WIDTH(WIDTH), .TAP(8'hB8)) lfsr_h2  (.clk(clk), .rst_n(rst_n), .seed(8'd156), .rand_out(rand_h2));
    RNS_LFSR #(.WIDTH(WIDTH), .TAP(8'hB8)) lfsr_h3  (.clk(clk), .rst_n(rst_n), .seed(8'd211), .rand_out(rand_h3));
    RNS_LFSR #(.WIDTH(WIDTH), .TAP(8'hB8)) lfsr_h4  (.clk(clk), .rst_n(rst_n), .seed(8'd72),  .rand_out(rand_h4));
    RNS_LFSR #(.WIDTH(WIDTH), .TAP(8'hB8)) lfsr_h5  (.clk(clk), .rst_n(rst_n), .seed(8'd143), .rand_out(rand_h5));
    RNS_LFSR #(.WIDTH(WIDTH), .TAP(8'hB8)) lfsr_h6  (.clk(clk), .rst_n(rst_n), .seed(8'd200), .rand_out(rand_h6));
    RNS_LFSR #(.WIDTH(WIDTH), .TAP(8'hB8)) lfsr_h7  (.clk(clk), .rst_n(rst_n), .seed(8'd255), .rand_out(rand_h7));
    RNS_LFSR #(.WIDTH(WIDTH), .TAP(8'hB8)) lfsr_sel (.clk(clk), .rst_n(rst_n), .seed(8'd7),   .rand_out(rand_mux));

    // =========================================
    // 3. 转换为SC比特流
    // =========================================
    // TODO: 前向转换 (二进制 → 随机比特流)
    // 这里用比较器: sc_out = (bin_in > rand_in) ? 1 : 0

    wire sc_x0 = (x_in  > rand_x);
    wire sc_x1 = (x_d1  > rand_x);
    wire sc_x2 = (x_d2  > rand_x);
    wire sc_x3 = (x_d3  > rand_x);
    wire sc_x4 = (x_d4  > rand_x);
    wire sc_x5 = (x_d5  > rand_x);
    wire sc_x6 = (x_d6  > rand_x);
    wire sc_x7 = (x_d7  > rand_x);

    wire sc_h0 = (h0 > rand_h0);
    wire sc_h1 = (h1 > rand_h1);
    wire sc_h2 = (h2 > rand_h2);
    wire sc_h3 = (h3 > rand_h3);
    wire sc_h4 = (h4 > rand_h4);
    wire sc_h5 = (h5 > rand_h5);
    wire sc_h6 = (h6 > rand_h6);
    wire sc_h7 = (h7 > rand_h7);
    // =========================================
    // 4. SC乘法 (XNOR门, 双极性)
    // =========================================
    wire sc_m0 = ~(sc_x0 ^ sc_h0);
    wire sc_m1 = ~(sc_x1 ^ sc_h1);
    wire sc_m2 = ~(sc_x2 ^ sc_h2);
    wire sc_m3 = ~(sc_x3 ^ sc_h3);
    wire sc_m4 = ~(sc_x4 ^ sc_h4);
    wire sc_m5 = ~(sc_x5 ^ sc_h5);
    wire sc_m6 = ~(sc_x6 ^ sc_h6);
    wire sc_m7 = ~(sc_x7 ^ sc_h7);

    // =========================================
    // 5. SC加法 (MUX)
    // =========================================
    // TODO: 改进MUX选择器
    // 4阶时用 2'b,  6阶时需要用... 多少bit?
    // 提示: 6个数选1个，需要 log2(6) = 3bit

    wire [2:0] sel = rand_mux[2:0];  // 改成3bit
    reg sc_sum;

    always @(*) begin
        case(sel)
            3'b000: sc_sum = sc_m0;
            3'b001: sc_sum = sc_m1;
            3'b010: sc_sum = sc_m2;
            3'b011: sc_sum = sc_m3;
            3'b100: sc_sum = sc_m4;
            3'b101: sc_sum = sc_m5;
            3'b110: sc_sum = sc_m6;  
            3'b111: sc_sum = sc_m7;  
         endcase
    end

    // =========================================
    // 6. 后向转换 (SC比特流 → 二进制)
    // =========================================
    reg [WIDTH:0] counter;
    reg [WIDTH-1:0] cycle_cnt;
    reg [WIDTH:0] result;
    reg result_valid;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            cycle_cnt <= 0;
            result <= 0;
            result_valid <= 0;
        end else begin
            result_valid <= 0;

            if (cycle_cnt == {WIDTH{1'b1}}) begin
                // 完成一个2^WIDTH的计算周期
                result <= counter + sc_sum;  // 加上当前周期的结果
                result_valid <= 1;
                counter <= 0;
                cycle_cnt <= 0;
            end else begin
                cycle_cnt <= cycle_cnt + 1;
                if (sc_sum == 1'b1)
                    counter <= counter + 1;
            end
        end
    end

    assign y_out = result;
    assign out_valid = result_valid;

endmodule


// ============================================================================
// 辅助模块: RNS LFSR (从你原来的代码复制)
// ============================================================================
module RNS_LFSR #(
    parameter WIDTH = 8,
    parameter [WIDTH-1:0] TAP = 8'hB8
)(
    input wire clk,
    input wire rst_n,
    input wire [WIDTH-1:0] seed,
    output reg [WIDTH-1:0] rand_out
);
    wire feedback = ^(rand_out & TAP);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rand_out <= seed;
        end else begin
            rand_out <= {rand_out[WIDTH-2:0], feedback};
        end
    end
endmodule
