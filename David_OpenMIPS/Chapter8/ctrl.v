`include "defines.v"
module ctrl(
    input wire rst,             //��λ�ź�
    input wire stallreq_from_id,//��������׶ε�ָ���Ƿ�������ˮ����ͣ
    input wire stallreq_from_ex,//����ִ�н׶ε�ָ���Ƿ�������ˮ����ͣ
    output reg [5:0] stall      //��ͣ��ˮ�߿����ź�
);

    always @(*) begin
        if(rst == `RstEnable) begin
            stall = 6'b0;
        end
        else if(stallreq_from_ex == `Stop) begin
            stall = 6'b001111;
        end
        else if(stallreq_from_id == `Stop) begin
            stall = 6'b000111;
        end
        else begin
            stall = 6'b000000;
        end
    end

endmodule