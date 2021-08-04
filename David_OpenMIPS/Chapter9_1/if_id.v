`include "defines.v"

module if_id(
    input wire              rst,
    input wire              clk,
    input wire [5:0]        stall,

    //����ȡֵ�׶ε��źţ�InstBus��ʾָ����Ϊ32
    input wire [`InstBus]   if_inst,

    //��Ӧ������׶ε��ź�
    output reg [`InstBus]   id_inst,

    input wire [`InstAddrBus] if_pc,
    output reg [`InstAddrBus] id_pc
);

    always @(posedge clk) begin
        if(rst == `RstEnable) begin
          id_inst <= `ZeroWord;
          id_pc <= `ZeroWord;
        end
        else if(stall[1] == `Stop && stall[2] == `NoStop) begin
          id_inst <= `ZeroWord;
          id_pc <= `ZeroWord;
        end
        else if(stall[1] == `NoStop) begin
          id_inst <= if_inst;
          id_pc <= if_pc;
        end
    end

endmodule
