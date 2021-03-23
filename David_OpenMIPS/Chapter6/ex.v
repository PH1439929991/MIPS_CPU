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
    output reg[`RegBus] wdata_o,         //ִ�н׶�����Ҫд��Ŀ�ļĴ�����ֵ

    //����HI/LO����Ĵ�������ӵ��ź�
    input wire [31:0] hi_i,lo_i,    //HILOģ�������HI/LO�Ĵ�����ֵ
    //�ô�׶ε�����ǰ��
    input wire mem_whilo_i,         //���ڷô�׶ε�ָ���Ƿ�ҪдHI/LO�Ĵ���
    input wire [31:0] mem_hi_i,mem_lo_i, //���ڷô�׶ε�ָ��Ҫд��HI/LO�Ĵ�����ֵ
    //��д�׶ε�����ǰ��
    input wire wb_whilo_i,          //���ڻ�д�׶ε�ָ���Ƿ�Ҫд��HI/LO�Ĵ���
    input wire [31:0] wb_hi_i,wb_lo_i, //���ڻ�д�׶ε�ָ��Ҫд��HI/LO�Ĵ�����ֵ
    //HI/LO�����
    output reg whilo_o,
    output reg [31:0] hi_o,lo_o     //ִ�н׶ε�ָ��Ҫд��HI/LO�Ĵ�����ֵ
);

    //�����߼�����Ľ��
    reg [`RegBus] logicout;
    //������λ����Ľ��
    reg [`RegBus] shiftres;
    //�ƶ������Ľ��
    reg [`RegBus] moveres;

    //����HI/LO�Ĵ���������ֵ
    reg [`RegBus] HI,LO;

/****************************************************
** �õ����µ�HI/LO�Ĵ�����ֵ���˴����������������   *****
****************************************************/
  always @(*) begin
    if(rst == `RstEnable) begin
      {HI,LO} <= {`ZeroWord,`ZeroWord};
    end
    else if(mem_whilo_i == `WriteEnable) begin
      {HI,LO} <= {mem_hi_i,mem_lo_i};
    end
    else if(wb_whilo_i == `WriteEnable) begin
      {HI,LO} <= {wb_hi_i,wb_lo_i};
    end
    else begin
      {HI,LO} <= {hi_i,lo_i};
    end
  end

/****************************************************
** MFHI��MFLO��MOVN��MOVZָ��(���дͨ�üĴ���������)  ***
****************************************************/
    always @(*) begin
      if(rst == `RstEnable) begin
          moveres = `ZeroWord;
      end
      else begin
          case(aluop_i)
              `EXE_MFHI_OP:   moveres = HI;
              `EXE_MFLO_OP:   moveres = LO;
              `EXE_MOVN_OP:   moveres = reg1_i;
              `EXE_MOVZ_OP:   moveres = reg1_i;
              default:        moveres = `ZeroWord;
          endcase
      end
    end


    //�����߼�����
    always @(*) begin
        if(rst == `RstEnable) begin
          logicout = `ZeroWord;
        end
        else begin
            case(aluop_i)
                `EXE_OR_OP:     logicout = reg1_i | reg2_i;
                `EXE_AND_OP:    logicout = reg1_i & reg2_i;
                `EXE_NOR_OP:    logicout = ~(reg1_i | reg2_i);
                `EXE_XOR_OP:    logicout = reg1_i ^ reg2_i;
                default:    logicout = `ZeroWord;
            endcase
        end  
    end

    //������λ����
    always @(*) begin
        if(rst == `RstEnable) begin
          shiftres = `ZeroWord;
        end
        else begin
          case(aluop_i)
            `EXE_SLL_OP:    shiftres = reg2_i << reg1_i[4:0];
            `EXE_SRL_OP:    shiftres = reg2_i >> reg1_i[4:0];
            `EXE_SRA_OP:begin
              shiftres = ({32{reg2_i[31]}}<<(6'd32-{1'b0,reg1_i[4:0]})) | (reg2_i >> reg1_i[4:0]);
            end
            default:        shiftres = `ZeroWord;
          endcase
        end
    end

    //�����MTHI��MTLOָ��������whilo_o,hi_o,lo_o��ֵ
    always @(*) begin
      if(rst == `RstEnable) begin
        whilo_o = `WriteDisable;
        hi_o = `ZeroWord;
        lo_o = `ZeroWord;
      end
      else if(aluop_i == `EXE_MTHI_OP) begin
        whilo_o = `WriteEnable;
        hi_o = reg1_i;
        lo_o = LO;        //дHI�Ĵ���������LO���ֲ���
      end
      else if(aluop_i == `EXE_MTLO_OP) begin
        whilo_o = `WriteEnable;
        hi_o = HI;        //дLO�Ĵ���������HI���ֲ���
        lo_o = reg1_i;        
      end
      else begin
        whilo_o = `WriteDisable;
        hi_o = `ZeroWord;
        lo_o = `ZeroWord;
      end
    end

    //����aluselָʾ���������ͣ�ѡ��һ����������Ϊ���ս��
    //��ʱֻ���߼�������
    always @(*) begin
        wd_o = wd_i;
        wreg_o = wreg_i;
        case(alusel_i)
            `EXE_RES_LOGIC:     wdata_o = logicout;
            `EXE_RES_SHIFT:     wdata_o = shiftres;
            `EXE_RES_MOVE:      wdata_o = moveres;
            default:            wdata_o = `ZeroWord;
        endcase
    end

endmodule