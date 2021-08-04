`include "defines.v"

module mem_wb(
    input wire                  clk,
    input wire                  rst,

    //�ô�׶εĽ��
    input wire[`RegAddrBus]     mem_wd,
    input wire                  mem_wreg,
    input wire[`RegBus]         mem_wdata,
    //��HI/LO�Ĵ�����ص�����ӿ�
    input wire                  mem_whilo,
    input wire[`RegBus]         mem_hi,
    input wire[`RegBus]         mem_lo,
    //��LLbit�Ĵ�����ؽӿ�
    input wire                  mem_LLbit_we,
    input wire                  mem_LLbit_value,

    //�͵���д�׶ε���Ϣ
    output reg[`RegAddrBus]     wb_wd,
    output reg                  wb_wreg,
    output reg[`RegBus]         wb_wdata,
    //��HI/LO�Ĵ�����ص�����ӿ�
    output reg                  wb_whilo,
    output reg[`RegBus]         wb_hi,
    output reg[`RegBus]         wb_lo,
    //��LLbit�Ĵ�����ؽӿ�
    output reg                  wb_LLbit_we,
    output reg                  wb_LLbit_value,

    input wire [5:0]            stall
);

    always @(posedge clk) begin
        if(rst == `RstEnable) begin
          wb_wd <= `NOPRegAddr;
          wb_wreg <= `WriteDisable;
          wb_wdata <= `ZeroWord;
          wb_whilo <= `WriteDisable;
          wb_hi <= `ZeroWord;
          wb_lo <= `ZeroWord;
          wb_LLbit_we <= 1'b0;
          wb_LLbit_value <= 1'b0;
        end
        else begin
          if(stall[4] == `Stop && stall[5] == `NoStop) begin
            wb_wd <= `NOPRegAddr;
            wb_wreg <= `WriteDisable;
            wb_wdata <= `ZeroWord;
            wb_whilo <= `WriteDisable;
            wb_hi <= `ZeroWord;
            wb_lo <= `ZeroWord;
            wb_LLbit_we <= 1'b0;
            wb_LLbit_value <= 1'b0;
          end
          else if(stall[4] == `NoStop) begin
            wb_wd <= mem_wd;
            wb_wreg <= mem_wreg;
            wb_wdata <= mem_wdata;
            wb_whilo <= mem_whilo;
            wb_hi <= mem_hi;
            wb_lo <= mem_lo;
            wb_LLbit_we <= mem_LLbit_we;
            wb_LLbit_value <= mem_LLbit_value;
          end
        end
    end

endmodule