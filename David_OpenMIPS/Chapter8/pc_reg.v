`include "defines.v"

module pc_reg(
    input wire                clk,
    input wire                rst,
    input wire [5:0]          stall,  //���Կ���ģ��ctrl
    input wire        branch_flag_i,  //�Ƿ���ת��
    //ת�Ƶ���Ŀ���ַ
    input wire [31:0] branch_target_address_i,
    output reg[`InstAddrBus]  pc,
    output reg                ce
);

    always @(posedge clk) begin
        if(rst == `RstEnable) begin
          ce <= `ChipDisable;   //��λʱָ��洢������
        end
        else begin
          ce <= `ChipEnable;    //��λ������ʹ��ָ��洢��
        end
    end

    //��stall[0]ΪNoStopʱ��pc��4������pc���ֲ���
    always @(posedge clk) begin
        if(ce == `ChipDisable) begin
          pc <= 32'h00000000;   //ָ��洢������ʱ��PCΪ0
        end
        else begin
          if(stall[0] == `NoStop) begin
              if(branch_flag_i == `Branch) begin
                  pc <= branch_target_address_i;
              end
              else begin
                  pc <= pc + 4'h4;      //ָ��洢��ʹ��ʱ��PC��ֵÿʱ�����ڼ�4
              end
              
          end  
        end 
    end

endmodule