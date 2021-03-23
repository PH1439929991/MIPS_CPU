//ȫ�ֺ궨��
`define RstEnable 1'b1          //��λ�ź���Ч
`define RstDisable 1'b0         //��λ�ź���Ч
`define ChipEnable 1'b1         //оƬʹ��
`define ChipDisable 1'b0        //оƬ��ֹ
`define ZeroWord 32'h00000000   //32λ����ֵ0
`define WriteEnable 1'b1        //ʹ��д
`define WriteDisable 1'b0       //��ֹд
`define ReadEnable 1'b1         //ʹ�ܶ�
`define ReadDisable 1'b0        //��ֹ��
`define AluSelBus 2:0           //����׶ε����alusel_o�Ŀ��
`define AluOpBus 7:0            //����׶ε����aluop_o�Ŀ��
`define InstValid 1'b1          //ָ����Ч
`define InstInvalid 1'b0        //ָ����Ч

//��ָ��洢����صĶ���
`define InstAddrBus     31:0    //ROM�ĵ�ַ���߿��
`define InstBus     31:0        //ROM���������߿��
`define InstMemNum 131071       //ROM��ʵ�ʴ�СΪ128KB
`define InstMemNumLog2  17      //ROMʵ��ʹ�õĵ�ַ�߿��

//��ͨ�üĴ���Regfile�йصĺ궨��
`define RegAddrBus 4:0          //Regfileģ��ĵ�ַ�߿��
`define RegBus 31:0             //Regfileģ��������߿��
`define RegNum 32               //ͨ�üĴ���������
`define RegNumLog2 5            //Ѱַͨ�üĴ������õĵ�ַλ��
`define NOPRegAddr  5'b00000

//�����ָ����صĺ궨��
`define EXE_AND     6'b100100   //andָ��Ĺ�����
`define EXE_OR      6'b100101   //orָ��Ĺ�����
`define EXE_XOR     6'b100110   //xorָ��Ĺ�����
`define EXE_NOR     6'b100111   //norָ��Ĺ�����
`define EXE_ANDI    6'b001100   //andiָ���ָ����
`define EXE_ORI     6'b001101   //oriָ���ָ����
`define EXE_XORI    6'b001110   //xoriָ���ָ����
`define EXE_LUI     6'b001111   //luiָ���ָ����
`define EXE_NOP     6'b000000

`define EXE_SLL     6'b000000   //sllָ��Ĺ�����
`define EXE_SLLV    6'b000100   //sllvָ��Ĺ�����
`define EXE_SRL     6'b000010   //srlָ��Ĺ�����
`define EXE_SRLV    6'b000110   //srlvָ��Ĺ�����
`define EXE_SRA     6'b000011   //sraָ��Ĺ�����
`define EXE_SRAV    6'b000111   //sravָ��Ĺ�����
// MOV EXE  
`define EXE_MOVZ    6'b001010
`define EXE_MOVN    6'b001011
`define EXE_MFHI    6'b010000
`define EXE_MTHI    6'b010001
`define EXE_MFLO    6'b010010
`define EXE_MTLO    6'b010011

`define EXE_SYNC    6'b001111   //syncָ��Ĺ�����
`define EXE_PREF    6'b110011   //prefָ���ָ����
`define EXE_SPECIAL_INST    6'b000000   //SPECIAL��ָ���ָ����



//AluOp
`define EXE_AND_OP      8'b00100100
`define EXE_OR_OP       8'b00100101
`define EXE_XOR_OP      8'b00100110
`define EXE_NOR_OP      8'b00100111
`define EXE_ANDI_OP     8'b01011001
`define EXE_ORI_OP      8'b01011010
`define EXE_XORI_OP     8'b01011011
`define EXE_LUI_OP      8'b01011100   

`define EXE_SLL_OP      8'b01111100
`define EXE_SLLV_OP     8'b00000100
`define EXE_SRL_OP      8'b00000010
`define EXE_SRLV_OP     8'b00000110
`define EXE_SRA_OP      8'b00000011
`define EXE_SRAV_OP     8'b00000111

`define EXE_NOP_OP      8'b00000000
//MOVE OP
`define EXE_MOVZ_OP     8'b00001010
`define EXE_MOVN_OP     8'b00001011
`define EXE_MFHI_OP     8'b00010000
`define EXE_MTHI_OP     8'b00010001
`define EXE_MFLO_OP     8'b00010010
`define EXE_MTLO_OP     8'b00010011

//AluSel
`define EXE_RES_LOGIC   3'b001
`define EXE_RES_SHIFT   3'b010
`define EXE_RES_MOVE    3'b011
`define EXE_RES_NOP     3'b000