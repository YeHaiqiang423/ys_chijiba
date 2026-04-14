// ============================================================================
// 文件: tb_sc_fir_6tap.v
// 说明: 6阶SC-FIR的仿真testbench - 你的第一个数字信号处理验证
// ============================================================================
// 学习目标:
//   1. 理解testbench结构
//   2. 学会生成测试激励
//   3. 学会分析波形
//   4. 学会对比测试结果
// ============================================================================

`timescale 1ns/1ps

module tb_sc_fir_8tap;

    // =========================================
    // 1. 信号声明
    // =========================================
    reg clk, rst_n;
    reg sample_en;
    reg [7:0] din;
    reg [7:0] h0, h1, h2, h3, h4, h5, h6, h7;  // 8个系数 
    
    wire [8:0] dout;
    wire out_valid;

    // 测试计数
    integer i, sample_count;
    real input_signal, output_signal;

    // =========================================
    // 2. 实例化被测模块
    // =========================================
    sc_fir_8tap #(.WIDTH(8)) uut (
        .clk(clk),
        .rst_n(rst_n),
        .sample_en(sample_en),
        .x_in(din),
        .h0(h0), .h1(h1), .h2(h2), .h3(h3), .h4(h4), .h5(h5), .h6(h6), .h7(h7),
        .y_out(dout),
        .out_valid(out_valid)
    );

    // =========================================
    // 3. 时钟生成 (10ns周期 = 100MHz)
    // =========================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // =========================================
    // 4. 主测试流程
    // =========================================
    initial begin
        // 打开波形记录
        $dumpfile("tb_sc_fir_8tap.vcd");
        $dumpvars(0, tb_sc_fir_8tap);

        // ----- 初始化 -----
        $display("========== SC-FIR 8Tap 仿真开始 ==========");
        rst_n = 0;
        sample_en = 0;
        din = 0;
        h0 = 64; h1 = 64; h2 = 64; h3 = 64; h4 = 64; h5 = 64; h6 = 64; h7 = 64;  // 移动平均滤波器

        #100;
        rst_n = 1;
        #100;

        // ----- 测试1: 脉冲响应 -----
        $display("\n【测试1】脉冲响应");
        $display("输入: 一个脉冲 (当sample_en=1时输入100)");

        sample_en = 1;
        din = 100;
        #10;
        din = 0;

        for (i = 0; i < 300; i++) begin
            #10;
            if (out_valid)
                $display("样本%0d: dout=%d", i/256, dout);
        end

        sample_en = 0;
        #1000;

        // ----- 测试2: 正弦波 -----
        $display("\n【测试2】正弦波通过滤波器");
        $display("输入: 正弦波 f=1MHz (128点/周期)");

        sample_en = 0;
        sample_count = 0;

        for (i = 0; i < 512; i++) begin
            // 生成正弦波: sin(2*pi*i/128)
            // 量化到0-255
            input_signal = 128.0 + 50.0 * $sin(2.0 * 3.14159 * i / 128.0);
            din = $rtoi(input_signal) & 8'hFF;

            sample_en = 1;
            #10;
            sample_en = 0;

            wait(out_valid == 1'b1);
            output_signal = dout;
            $display("样本%0d: input=%0d, output=%0d", sample_count, din, dout);
            sample_count = sample_count + 1;
            #10;
        end

        sample_en = 0;
        #1000;

        // ----- 测试3: 阶跃响应 -----
        $display("\n【测试3】阶跃响应");
        $display("输入: 从0跳到200");

        sample_en = 1;
        din = 200;  // 持续输入200

        for (i = 0; i < 256; i++) begin
            #10;
            if (out_valid)
                $display("样本%0d: dout=%d (稳态应该~%0d)", i/256, dout, 200);
        end

        sample_en = 0;
        #1000;

        // 结束仿真
        $display("\n========== 仿真完成 ==========");
        $display("波形已保存到: tb_sc_fir_8tap.vcd");
        $display("用GTKWave打开查看:");
        $display("  gtkwave tb_sc_fir_8tap.vcd");
        $finish;
    end

    // =========================================
    // 5. 监控输出
    // =========================================
    initial begin
        // 每当out_valid=1时打印
        $monitor("Time=%0tns, valid=%b, dout=%d (0x%h)",
                 $time, out_valid, dout, dout);
    end

endmodule

/*
【使用方法】

1. 在Vivado中:
   Vivado → Tools → Simulate → Run Simulation
   (前提是已经正确设置了simulation source)

2. 或在命令行:
   iverilog -o sim.o sc_fir_6tap.v tb_sc_fir_6tap.v
   vvp sim.o
   gtkwave tb_sc_fir_6tap.vcd

【波形查看】

在GTKWave中:
  1. 左侧窗口找到信号
  2. 拖到右侧时间轴
  3. 右键信号 → Recreate Group
  4. 分组查看:
     - [输入信号] din, sample_en
     - [系数] h0, h1, ...
     - [输出信号] dout, out_valid
     - [内部信号] 展开模块查看rand_x, sc_m0等

【预期结果】

测试1 (脉冲响应):
  输入一个脉冲后，输出会逐渐增大然后稳定
  这是因为SC计算需要256个时钟周期收敛

测试2 (正弦波):
  低通滤波效果: 输出波形应该比输入更光滑
  这验证了滤波器工作正常

测试3 (阶跃响应):
  输入200持续一段时间，输出逐渐逼近200
  稳态误差应该很小 (±10以内)

【常见问题解决】

Q: 波形看不懂
A: 看这几个信号:
   - clk: 应该是规则的方波
   - out_valid: 应该每256个时钟周期出现一次
   - dout: 只在out_valid=1时有意义

Q: 输出都是0
A: 可能的原因:
   - rst_n没有释放 (检查复位逻辑)
   - sample_en没有拉高 (检查使能逻辑)
   - LFSR没有工作 (看rand_x是否在变)

Q: 输出波动太大
A: 这是正常的! SC计算本来就有随机波动
   但平均值应该逐渐收敛到理论值

*/
