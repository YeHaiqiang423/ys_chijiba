`timescale 1ns/1ps
// ------------------------------------------------
// 该模块实现触发捕获，默认8位输入，触发后捕获128个数据点数
// ------------------------------------------------
module trigger_capture #(
    parameter DATA_WIDTH = 8,
    parameter CAPTURE_LENGTH = 128
)(
    input   wire                            clk,            // 全局时钟
    input   wire                            rst_n,          // 全局复位
    input   wire    [DATA_WIDTH - 1 : 0]    data_in,        // 输入数据
    input   wire    [DATA_WIDTH - 1 : 0]    threshold,      // 设定阈值
    input   wire                            trigger_en,     // 触发使能
    
    output  reg     [DATA_WIDTH - 1 : 0]    data_out,       // 输出数据
    output  reg                             data_valid,     // 数据有效标志位，告诉下一级可以开始接收
    output  reg                             trigger_flag,   // 告诉外部系统捕获到触发条件了，开始记录了
    output  reg                             done_flag       // 数据已经捕获完成，可以从寄存器中读取
);

    // 内部寄存器
    reg     [DATA_WIDTH - 1 : 0]                data_in_d1;             // delay一个数据
    reg                                         is_capturing;           // 捕获状态
    reg     [$clog2(CAPTURE_LENGTH) - 1: 0]     capture_cnt;                

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)begin
            data_out        <= 0; 
            data_valid      <= 0;
            trigger_flag    <= 0;
            done_flag       <= 0;
            data_in_d1      <= 0;  
            is_capturing    <= 0;
            capture_cnt     <= 0; 
        end else begin
            data_in_d1      <= data_in; 

            // 单脉冲信号置零
            trigger_flag    <= 1'b0;
            done_flag       <= 1'b0;
            if (!is_capturing) begin
                data_valid  <= 1'b0;
                if (trigger_en && (data_in >= threshold) && (data_in_d1 < threshold)) begin
                    is_capturing    <= 1'b1;
                    trigger_flag    <= 1'b1;
                    // 捕获正式开始
                    data_out        <= data_in;
                    data_valid      <= 1'b1;
                    capture_cnt     <= 1;
                end 
            end 
            else begin
                data_out        <= data_in;
                data_valid      <= 1'b1;
                capture_cnt     <= capture_cnt + 1;

                if (capture_cnt == CAPTURE_LENGTH - 1) begin
                    is_capturing    <= 1'b0;
                    done_flag       <= 1'b1;
                    data_valid      <= 1'b0;
                end
            end
        end
    end

endmodule
