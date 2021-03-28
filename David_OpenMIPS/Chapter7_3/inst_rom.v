`include "defines.v"

module inst_rom(
    input wire                  ce,
    input wire[`InstAddrBus]    addr,
    output reg[`InstBus]        inst
);

    //����һ�����飬��С��InstMemNum��Ԫ�ؿ����InstBus
    reg [`InstBus] inst_mem[0:`InstMemNum-1];

    //ʹ���ļ�inst_rom.data��ʼ���Ĵ���
    initial $readmemh ("C:/Users/David/Desktop/Chapter7_3/rtl/inst_rom.data",inst_mem);

    //����λ�ź���Чʱ����������ĵ�ַ������ָ��洢��ROM�ж�Ӧ��Ԫ��
    always @(*) begin
        if(ce == `ChipDisable) begin
            inst <= `ZeroWord;
        end
        else begin
            //ָ��Ĵ�����ÿ����ַ��32bit���֣�����Ҫ��OpenMips������ָ���ַ����4��ʹ��
            inst <= inst_mem[addr[`InstMemNumLog2+1:2]];
        end
    end

endmodule