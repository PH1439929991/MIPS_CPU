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
`define EXE_ORI     6'b001101   //ָ��ori��ָ����
`define EXE_NOP     6'b000000

//AluOp
`define EXE_OR_OP   8'b00100101
`define EXE_NOP_OP  8'b00000000

//AluSel
`define EXE_RES_LOGIC   3'b001
`define EXE_RES_NOP     3'b000