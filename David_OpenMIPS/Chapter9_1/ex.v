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
    input wire[`RegBus]     inst_i,//��ǰ����ִ�н׶ε�ָ��

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
    //���ۼӡ����ۼ�����ӵĽӿ�
    input wire [`DoubleRegBus] hilo_temp_i, //��һ��ִ�����ڵõ��ĳ˷����
    input wire [1:0] cnt_i,         //��ǰ����ִ�н׶εĵڼ���ʱ������
    output reg [`DoubleRegBus] hilo_temp_o, //��һ��ִ�����ڵõ��ĳ˷����
    output reg [1:0] cnt_o,         //��һ��ʱ�����ڴ���ִ�н׶εĵڼ���ʱ������
    
    //HI/LO�����
    output reg whilo_o,
    output reg [31:0] hi_o,lo_o,     //ִ�н׶ε�ָ��Ҫд��HI/LO�Ĵ�����ֵ

    output reg stallreq,

    //����ģ�������Ľӿ�
    output reg signed_div_o,        //�Ƿ�Ϊ�з��ų�����Ϊ1��ʾ���з��ų���
    output reg [31:0] div_opdata1_o,//������
    output reg [31:0] div_opdata2_o,//����
    output reg div_start_o,         //�Ƿ�ʼ��������
    input wire [63:0] div_result_i, //����������
    input wire div_ready_i,         //���������Ƿ����
    
    //���ء��洢ָ�����������ӿ�
    output wire[`AluOpBus]  aluop_o,
    output wire[`RegBus]    mem_addr_o,
    output wire[`RegBus]    reg2_o,

    //����ִ�н׶ε�ת��ָ��Ҫ����ķ��ص�ַ
    input wire [`RegBus] link_address_i,
    //��ǰִ�н׶ε�ָ���Ƿ�λ���ӳٲ�
    input wire is_in_delayslot_i
);

    //�����߼�����Ľ��
    reg [`RegBus] logicout;
    //������λ����Ľ��
    reg [`RegBus] shiftres;
    //�ƶ������Ľ��
    reg [`RegBus] moveres;

    //����HI/LO�Ĵ���������ֵ
    reg [`RegBus] HI,LO;

    //������������ı���
    reg[`RegBus] arithmeticres; //��������������
    wire ov_sum;				//����������
    wire reg1_eq_reg2;			//��һ���������Ƿ���ڵڶ���������
    wire reg1_lt_reg2;			//��һ���������Ƿ�С�ڵڶ���������
    wire[`RegBus] reg2_i_mux;	//��������ĵڶ�������reg2_i�Ĳ���
    wire[`RegBus] reg1_i_not;	//��������ĵ�һ��������reg1_iȡ�����ֵ
    wire[`RegBus] result_sum;	//����ӷ����
    wire[`RegBus] opdata1_mult;	//�˷������еı�����
    wire[`RegBus] opdata2_mult;	//�˷������еĳ���
    wire[`DoubleRegBus] hilo_temp;	//��ʱ����˷���������Ϊ64λ
    reg[`DoubleRegBus] hilo_temp1;
    reg stallreq_for_madd_msub;    //�Ƿ����ڳ��ۼӡ����ۼ�������ˮ����ͣ
    reg stallreq_for_div;         //�Ƿ����ڳ������㵼����ˮ����ͣ
    reg[`DoubleRegBus] mulres;		//����˷���������Ϊ64λ

//��������������ر�����ֵ
    //���Ϊ�������з��űȽ����㣬��reg2Ӧȡ������ʽ������ȡԭ��
    assign reg2_i_mux = ((aluop_i == `EXE_SUB_OP) || (aluop_i == `EXE_SUBU_OP) ||
                         (aluop_i == `EXE_SLT_OP)) ? (~reg2_i) + 1'b1 : reg2_i;
    //����Ǽӷ����㣬��reg2_i_mux=reg2_i������result_sum���Ǽӷ��Ľ��
    //����Ǽ������㣬��reg2_i_mux��reg2_i�Ĳ��룬����result_sum���Ǽ����Ľ��
    //������з��űȽ����㣬result_sum���Ǽ����Ľ�������ɸý����һ�����д�С���ж�
    assign result_sum = reg1_i + reg2_i_mux;
    //�Ӽ���ָ��ִ��ʱ�����жϽ���Ƿ���������������Ϊ���������������Ϊ����ʱ���������
    assign ov_sum = ((reg1_i[31] && reg2_i_mux[31] && (~result_sum[31]))) ||
                    (((~reg1_i[31] && ~reg2_i_mux[31]) && result_sum[31]));
    //�Ƚϲ�����1�Ƿ�С�ڲ�����2����з��űȽϺ��޷��űȽ����ַ�ʽ
    assign reg1_lt_reg2 = (aluop_i == `EXE_SLT_OP) ? ((reg1_i[31] && ~reg2_i[31]) ||
                          (~reg1_i[31] && ~reg2_i[31] && result_sum[31]) || 
                          (reg1_i[31] && reg2_i[31] && result_sum[31])): (reg1_i < reg2_i);
    //��reg_1��λȡ��������reg1_i_not
    assign reg1_i_not = ~reg1_i;
    //����1����Ϊ�з��ų˷��Ҹó���Ϊ��������ȡ�䲹�룬���򲻱�
    assign opdata1_mult = (((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP) || 
                            (aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MSUB_OP))
                          && (reg1_i[31] == 1'b1)) ? (~reg1_i + 1'b1) : reg1_i;
    //����2����Ϊ�з��ų˷��Ҹó���Ϊ��������ȡ�䲹�룬���򲻱�
    assign opdata2_mult = (((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP) ||
                            (aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MSUB_OP))
                          && (reg2_i[31] == 1'b1)) ? (~reg2_i + 1'b1) : reg2_i;
    //�õ���ʱ�ĳ˷���������浽hilo_temp��
    assign hilo_temp = opdata1_mult * opdata2_mult;
    //aluop_o�ᴫ�ݵ��ô�׶Σ���ʱ��������ȷ�����ء��洢����
    assign aluop_o = aluop_i;
    //mem_addr_o�ᴫ�ݵ��ô�׶Σ��Ǽ��ء��洢ָ���Ӧ�Ĵ洢����ַ
    assign mem_addr_o = reg1_i + {{16{inst_i[15]}},inst_i[15:0]};
    //reg2_i�Ǵ洢ָ��Ҫ�洢�����ݣ���lwl��lwrָ��Ҫ���ص�Ŀ�ļĴ�����ԭʼֵ
    //����ֵͨ��reg2_o�ӿڴ��ݵ��ô�׶�
    assign reg2_o = reg2_i;


    //����ʱ�˷�������������������ս������mulres��
    always @(*) begin
        if(rst == `RstEnable) begin
            mulres = {`ZeroWord,`ZeroWord};
        end
        else if((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP) ||
                (aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MSUB_OP)) begin
            if(reg1_i[31] ^ reg2_i[31] == 1'b1) begin
                mulres = ~hilo_temp + 1'b1;
            end
            else begin
                mulres = hilo_temp;
            end
        end
        else begin
            mulres = hilo_temp;
        end
    end
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
**                ���ۼӡ����ۼ�����                  **
****************************************************/
    always @(*) begin
      if(rst == `RstEnable) begin
          hilo_temp_o = {`ZeroWord,`ZeroWord};
          cnt_o = 2'b00;
          stallreq_for_madd_msub = `NoStop;
      end
      else begin
          case(aluop_i)
              `EXE_MADD_OP,`EXE_MADDU_OP:begin  //madd��madduָ��
                if(cnt_i == 2'b00) begin        //ִ�н׶ε�һ������
                    hilo_temp_o = mulres;
                    cnt_o = 2'b01;
                    hilo_temp1 = {`ZeroWord,`ZeroWord};
                    stallreq_for_madd_msub = `Stop;
                end
                else if(cnt_i == 2'b01) begin   //ִ�н׶εڶ�������
                    hilo_temp_o = {`ZeroWord,`ZeroWord};
                    cnt_o = 2'b10;
                    hilo_temp1 = hilo_temp_i + {HI,LO};
                    stallreq_for_madd_msub = `NoStop;
                end
              end
              `EXE_MSUB_OP,`EXE_MSUBU_OP:begin  //msub��msubuָ��
                if(cnt_i == 2'b00) begin
                  hilo_temp_o = ~mulres + 1'b1; //ֱ��ȡ����洢
                  cnt_o = 2'b01;
                  hilo_temp1 = {`ZeroWord,`ZeroWord};
                  stallreq_for_madd_msub = `Stop;
                end
                else if(cnt_i == 2'b01) begin
                  hilo_temp_o = {`ZeroWord,`ZeroWord};
                  cnt_o = 2'b10;
                  hilo_temp1 = hilo_temp_i + {HI,LO};
                  stallreq_for_madd_msub = `NoStop;
                end
              end
              default:begin
                  hilo_temp_o = {`ZeroWord,`ZeroWord};
                  cnt_o = 2'b00;
                  stallreq_for_madd_msub = `NoStop;
              end
          endcase
      end
    end

/****************************************************
**                    ��������                      **
****************************************************/
    always @(*) begin
        if(rst == `RstEnable) begin
            stallreq_for_div = `NoStop;
            div_opdata1_o = `ZeroWord;
            div_opdata2_o = `ZeroWord;
            div_start_o = `DivStop;
            signed_div_o = 1'b0;
        end
        else begin
            case(aluop_i)
                `EXE_DIV_OP:begin
                    stallreq_for_div = div_ready_i ? `NoStop : `Stop;
                    div_opdata1_o = reg1_i;
                    div_opdata2_o = reg2_i;
                    div_start_o = div_ready_i ? `DivStop : `DivStart;
                    signed_div_o = 1'b1;
                end
                `EXE_DIVU_OP:begin
                    stallreq_for_div = div_ready_i ? `NoStop : `Stop;
                    div_opdata1_o = reg1_i;
                    div_opdata2_o = reg2_i;
                    div_start_o = div_ready_i ? `DivStop : `DivStart;
                    signed_div_o = 1'b0;
                end
            endcase
        end
    end

/****************************************************
**                     ��ͣ��ˮ��                    **
****************************************************/
    //Ŀǰֻ�г��ۼӡ����ۼ�ָ��ᵼ����ˮ����ͣ
    //����stallreq��ֱ�ӵ���stallreq_for_madd_msub��ֵ
    always @(*) begin
      stallreq = stallreq_for_madd_msub || stallreq_for_div;
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

    //������������
    always @(*) begin
        if(rst == `RstEnable) begin
            arithmeticres = `ZeroWord;
        end
        else begin
            case(aluop_i)
                `EXE_SLT_OP,`EXE_SLTU_OP:begin        //�Ƚ�����
                    arithmeticres = reg1_lt_reg2;
                end
                `EXE_ADD_OP,`EXE_ADDU_OP,`EXE_ADDI_OP,`EXE_ADDIU_OP:begin //�ӷ�����
                    arithmeticres = result_sum;
                end
                `EXE_SUB_OP,`EXE_SUBU_OP:begin        //��������
                    arithmeticres = result_sum;
                end
                `EXE_CLZ_OP:begin
                    arithmeticres = reg1_i[31] ? 0 : reg1_i[30] ? 1 : reg1_i[29] ? 2 :
													 reg1_i[28] ? 3 : reg1_i[27] ? 4 : reg1_i[26] ? 5 :
													 reg1_i[25] ? 6 : reg1_i[24] ? 7 : reg1_i[23] ? 8 : 
													 reg1_i[22] ? 9 : reg1_i[21] ? 10 : reg1_i[20] ? 11 :
													 reg1_i[19] ? 12 : reg1_i[18] ? 13 : reg1_i[17] ? 14 : 
													 reg1_i[16] ? 15 : reg1_i[15] ? 16 : reg1_i[14] ? 17 : 
													 reg1_i[13] ? 18 : reg1_i[12] ? 19 : reg1_i[11] ? 20 :
													 reg1_i[10] ? 21 : reg1_i[9] ? 22 : reg1_i[8] ? 23 : 
													 reg1_i[7] ? 24 : reg1_i[6] ? 25 : reg1_i[5] ? 26 : 
													 reg1_i[4] ? 27 : reg1_i[3] ? 28 : reg1_i[2] ? 29 : 
													 reg1_i[1] ? 30 : reg1_i[0] ? 31 : 32 ;
                end
                `EXE_CLO_OP:begin
                    arithmeticres = reg1_i_not[31] ? 0 : reg1_i_not[30] ? 1 : reg1_i_not[29] ? 2 :
													 reg1_i_not[28] ? 3 : reg1_i_not[27] ? 4 : reg1_i_not[26] ? 5 :
													 reg1_i_not[25] ? 6 : reg1_i_not[24] ? 7 : reg1_i_not[23] ? 8 : 
													 reg1_i_not[22] ? 9 : reg1_i_not[21] ? 10 : reg1_i_not[20] ? 11 :
													 reg1_i_not[19] ? 12 : reg1_i_not[18] ? 13 : reg1_i_not[17] ? 14 : 
													 reg1_i_not[16] ? 15 : reg1_i_not[15] ? 16 : reg1_i_not[14] ? 17 : 
													 reg1_i_not[13] ? 18 : reg1_i_not[12] ? 19 : reg1_i_not[11] ? 20 :
													 reg1_i_not[10] ? 21 : reg1_i_not[9] ? 22 : reg1_i_not[8] ? 23 : 
													 reg1_i_not[7] ? 24 : reg1_i_not[6] ? 25 : reg1_i_not[5] ? 26 : 
													 reg1_i_not[4] ? 27 : reg1_i_not[3] ? 28 : reg1_i_not[2] ? 29 : 
													 reg1_i_not[1] ? 30 : reg1_i_not[0] ? 31 : 32 ;
                end
                default:begin
                    arithmeticres = `ZeroWord;
                end
            endcase
        end
    end

    //�����MTHI��MTLOָ��������whilo_o,hi_o,lo_o��ֵ
    //���ۼӺͳ��ۼ�ָ�����޸�HI��LO�Ĵ�����д��Ϣ
    always @(*) begin
      if(rst == `RstEnable) begin
        whilo_o = `WriteDisable;
        hi_o = `ZeroWord;
        lo_o = `ZeroWord;
      end
      else if((aluop_i == `EXE_MSUB_OP)||(aluop_i == `EXE_MSUBU_OP)
            ||(aluop_i == `EXE_MADD_OP)||(aluop_i == `EXE_MADDU_OP)) begin
        whilo_o = `WriteEnable;
        hi_o = hilo_temp1[63:32];
        lo_o = hilo_temp1[31:0];        
      end
      else if((aluop_i == `EXE_MULT_OP)||(aluop_i == `EXE_MULTU_OP)) begin
        whilo_o = `WriteEnable;
        hi_o = mulres[63:32];
        lo_o = mulres[31:0];
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
      else if((aluop_i == `EXE_DIV_OP) || (aluop_i == `EXE_DIVU_OP)) begin
        whilo_o = `WriteEnable;
        hi_o = div_result_i[63:32];
        lo_o = div_result_i[31:0];
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
          if(((aluop_i == `EXE_ADD_OP) || (aluop_i == `EXE_ADDI_OP) || 
            (aluop_i == `EXE_SUB_OP)) && (ov_sum == 1'b1))begin
              wreg_o = `WriteDisable;
          end
          else begin
              wreg_o = wreg_i;
          end
        case(alusel_i)
            `EXE_RES_LOGIC:     wdata_o = logicout;
            `EXE_RES_SHIFT:     wdata_o = shiftres;
            `EXE_RES_MOVE:      wdata_o = moveres;
            `EXE_RES_ARITHMETIC:wdata_o = arithmeticres;
            `EXE_RES_MUL:       wdata_o = mulres[31:0];
            `EXE_RES_JUMP_BRANCH:begin
                wdata_o <= link_address_i;
            end
            default:            wdata_o = `ZeroWord;
        endcase
    end

endmodule