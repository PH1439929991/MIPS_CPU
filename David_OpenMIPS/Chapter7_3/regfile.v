`include "defines.v"

module regfile(
    input wire                clk,
    input wire                rst,

    //д�˿�
    input wire we,
    input wire[`RegAddrBus]   waddr,
    input wire[`RegBus]       wdata,

    //���˿�1
    input wire                re1,
    input wire[`RegAddrBus]   raddr1,
    output reg[`RegBus]       rdata1,

    //���˿�2
    input wire                re2,
    input wire[`RegAddrBus]   raddr2,
    output reg[`RegBus]       rdata2
);

//����32��λ��Ϊ32��ͨ�üĴ���
reg [`RegBus] regs[0:`RegNum-1];

//д����
always @(posedge clk) begin
    if(rst == `RstDisable) begin
      if((we == `WriteEnable) && (waddr != `RegNumLog2'h0)) begin   //�Ĵ���0����д
        regs[waddr] <= wdata;
      end
    end
end
//MIPS32�ܹ��涨$0��ֵֻ��Ϊ0

//������1,����߼�
always @(*) begin
    if(rst == `RstEnable) begin
      rdata1 <= `ZeroWord;
    end
    else if(raddr1 == `RegNumLog2'h0) begin
      rdata1 <= `ZeroWord;
    end
    else if((re1 == `ReadEnable) && (we == `WriteEnable) && (waddr == raddr1)) begin
      rdata1 <= wdata;
    end
    else if(re1 == `ReadEnable) begin
      rdata1 <= regs[raddr1];
    end
    else begin
      rdata1 <= `ZeroWord;
    end
end

//������2
always @(*) begin
    if(rst == `RstEnable) begin
      rdata2 <= `ZeroWord;
    end
    else if(raddr2 == `RegNumLog2'h0) begin
      rdata2 <= `ZeroWord;
    end
    else if((re2 == `ReadEnable) && (we == `WriteEnable) && (waddr == raddr2)) begin
      rdata2 <= wdata;
    end
    else if(re2 == `ReadEnable) begin
      rdata2 <= regs[raddr2];
    end
    else begin
      rdata2 <= `ZeroWord;
    end
end
 
endmodule