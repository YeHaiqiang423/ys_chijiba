`timescale 1ns/1ps      // 时间单位1ns，精度1ps

module tb_trigger_capture;

    // 1.参数定义
    localparam DATA_WIDTH = 8;
    localparam CAPTURE_LENGTH = 16;

    // 2.信号定义
    reg                         clk;         
    reg                         rst_n;     
    reg [DATA_WIDTH - 1 : 0]    data_in;   
    reg [DATA_WIDTH - 1 : 0]    threshold;  
    reg                         trigger_en; 

    wire    [DATA_WIDTH - 1 : 0]    data_out;   
    wire                            data_valid; 
    wire                            trigger_flag;
    wire                            done_flag;    

    // 3.例化
    trigger_capture #(
        .DATA_WIDTH(DATA_WIDTH),
        .CAPTURE_LENGTH(CAPTURE_LENGTH)
    ) u_trigger_capture (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .threshold(threshold),
        .trigger_en(trigger_en),
        .data_out(data_out),
        .data_valid(data_valid),
        .trigger_flag(trigger_flag),
        .done_flag(done_flag)
    );

    // 4.时钟,10ns一个周期，就是100MHz
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 5.生成vcd波形文件
    initial begin
        $dumpfile("tb_trigger_capture.vcd");
        $dumpvars(0, tb_trigger_capture);
    end

    // 6.引入模拟数据输入
    initial begin
        // 初始化
        rst_n       = 0;  // 先复位
        data_in     = 0;
        threshold   = 8'd100;
        trigger_en  = 0;

        #20 rst_n   = 1;

        // 开启触发使能
        #10 trigger_en = 1;

        // 此时可以开始输入数据
        repeat (20) begin
            @(posedge clk)
                data_in = data_in + 8'd10;
        end

        repeat (10) begin
            @(posedge clk) 
                data_in = 8'd200;
        end

        #300;

        $display("✅ 仿真结束！");
        $finish;
    end
endmodule
