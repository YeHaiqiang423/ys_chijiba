`timescale 1ns/1ps

module tb_trigger_capture();
    localparam DATA_WIDTH       = 8;
    localparam CAPTURE_LENGTH   = 16;

    logic   clk;
    logic   rst_n;
    logic   [DATA_WIDTH-1:0]        data_in;
    logic   [DATA_WIDTH - 1 : 0]    threshold;  
    logic                           trigger_en;
    logic   [DATA_WIDTH - 1 : 0]    data_out;  
    logic                           data_valid;
    logic                           trigger_flag;
    logic                           done_flag;

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

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("tb_trigger_capture.vcd");
        $dumpvars(0, tb_trigger_capture);
    end

    initial begin
        // 初始化
        rst_n       = 0;  // 先复位
        data_in     = 0;
        threshold   = 8'd100;
        trigger_en  = 0;

        #20 rst_n   = 1;

        // 开启触发使能
        @(posedge clk);
        trigger_en = 1;

        for (int i = 0; i < 20; i++) begin
            @(posedge clk);
            data_in +=  8'd10;
        end

        for (int i = 0; i < 10; i++) begin
            @(posedge clk);
            data_in =  8'd200;
        end

        #300;
        $display("✅ 仿真结束！");
        $finish;
    end
endmodule
