`include "defines.v"

module ex(
    input wire              rst,

    //����׶��͵�ִ�н׶ε���Ϣ
    input wire[`AluSelBus]  alusel_i,
    input wire[`AluOpBus]   aluop_i,
    input wire[`RegBus]     reg1_i,
    input wire[`RegBus]     reg2_i,
    input wire[`RegAddrBus] wd_i,
    input wire              wreg_i,

    //ִ�еĽ��
    output reg[`RegAddrBus] wd_o,       //ִ�н׶εĽ������Ҫд���Ŀ�ļĴ����ĵ�ַ
    output reg wreg_o,
    output reg[`RegBus] wdata_o         //ִ�н׶�����Ҫд��Ŀ�ļĴ�����ֵ
);

    //�����߼�����Ľ��
    reg [`RegBus] logicout;

    //����aluopָʾ�����������ͽ������㣬�˴�ֻ���߼�������
    always @(*) begin
        if(rst == `RstEnable) begin
          logicout = `ZeroWord;
        end
        else begin
            case(aluop_i)
                `EXE_OR_OP:  logicout = reg1_i | reg2_i;
                default:    logicout = `ZeroWord;
            endcase
        end  
    end

    //����aluselָʾ���������ͣ�ѡ��һ����������Ϊ���ս��
    //��ʱֻ���߼�������
    always @(*) begin
        wd_o = wd_i;
        wreg_o = wreg_i;
        case(alusel_i)
            `EXE_RES_LOGIC:     wdata_o = logicout;
            default:            wdata_o = `ZeroWord;
        endcase
    end

endmodule