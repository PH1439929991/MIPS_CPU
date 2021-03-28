`include "defines.v"

module pc_reg(
    input wire                clk,
    input wire                rst,
    input wire [5:0]          stall,  //来自控制模块ctrl
    output reg[`InstAddrBus]  pc,
    output reg                ce
);

    always @(posedge clk) begin
        if(rst == `RstEnable) begin
          ce <= `ChipDisable;   //复位时指令存储器禁用
        end
        else begin
          ce <= `ChipEnable;    //复位结束后使能指令存储器
        end
    end

    //当stall[0]为NoStop时，pc加4，否则pc保持不变
    always @(posedge clk) begin
        if(ce == `ChipDisable) begin
          pc <= 32'h00000000;   //指令存储器禁用时，PC为0
        end
        else begin
          if(stall[0] == `NoStop) begin
              pc <= pc + 4'h4;      //指令存储器使能时，PC的值每时钟周期加4
          end  
        end 
    end

endmodule