`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Davidgu
// 
// Create Date: 2021/08/04 09:32:10
// Design Name: 
// Module Name: LLbit_reg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "defines.v"

module LLbit_reg(
    input   wire        clk,
    input   wire        rst,

    //�쳣�Ƿ�����Ϊ1��ʾ�쳣������Ϊ0��ʾû���쳣
    input   wire        flush,

    //д����
    input   wire        LLbit_i,
    input   wire        we,

    //LLbit�Ĵ�����ֵ
    output  reg         LLbit_o
    );

    always @(posedge clk) begin
        if(rst == `RstEnable) begin
            LLbit_o <= 1'b0;
        end
        else if(flush == 1'b1) begin
            LLbit_o <= 1'b0;
        end
        else if(we == `WriteEnable) begin
            LLbit_o <= LLbit_i;
        end
        else begin
            LLbit_o <= LLbit_o;
        end
    end

endmodule
