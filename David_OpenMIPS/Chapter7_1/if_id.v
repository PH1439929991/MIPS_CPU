`include "defines.v"

module if_id(
    input wire              rst,
    input wire              clk,

    //����ȡֵ�׶ε��źţ�InstBus��ʾָ����Ϊ32
    input wire [`InstBus]   if_inst,

    //��Ӧ������׶ε��ź�
    output reg [`InstBus]   id_inst
);

    always @(posedge clk) begin
        if(rst == `RstEnable) begin
          id_inst <= `ZeroWord;
        end
        else begin
          id_inst <= if_inst;
        end
    end

endmodule
