`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/12 18:32:50
// Design Name: 
// Module Name: CPU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CPU(
    input clk,				//ʱ�����ź�
    input rst,				//��λ�ź�
    output [31:0] pcdata,	//ָ�����ַpc
    input [31:0] inst,		//�����ָ����
    input [31:0] rdata,		//��ram���������
    output [31:0] addr,		//д��ram�ĵ�ַ
    output [31:0] wdata,	//д��ram������
    output im_r,			//ָ��Ĵ������ź�
    output dm_cs,			//
    output dm_r,			//���ݼĴ������ź�
    output dm_w,			//���ݼĴ���д�ź�
    output [5:0] op_out,	//���������...
    output Z            	//���������...
    );
     
     
     
     
     //CU
    wire PC_clk;
    wire [5:0] ALUControl;
    wire regFileW;
    wire regFileClk;
    wire memRead;
    wire memWrite;
    wire memToReg;
    wire ALUsrc;
    wire regWrite;
    wire jump;
    wire [3:0] branch;
    wire PCwrite;
    wire readShamt;
    wire zeroExt;
    //ALU
    wire [31:0] alu_out;
    wire zf;
    wire cf;
    //IMEM
     wire [31:0] imem_addr;
     wire [31:0] imem_data_in;
     wire [31:0] imem_data_out;
     wire [25:0] target=imem_data_out[25:0];
     wire [4:0] sa=imem_data_out[10:6];
     wire [4:0] Rsc=imem_data_out[25:21];
     wire [4:0] Rtc=imem_data_out[20:16];
     wire [4:0] Rdc=imem_data_out[15:11];
     wire [5:0] RegOp=imem_data_out[31:26];
     wire [5:0] func=imem_data_out[5:0];
     wire [15:0] imm16=imem_data_out[15:0];
     wire signExt_0_input16; 
     //ext01
     wire [31:0] ext01_out;
     //MUX1
     wire [31:0] mux_1_out;
     //pc
     wire pc_clk;
     wire pc_rst;
     assign pc_rst=rst;
     wire [31:0] pc_data_in;
     wire [31:0] pc_data_out;
     wire [3:0] pc_data31_28;
     //npc
     wire of;
     wire [31:0] npc_out;
     
     //RegFile
     wire rf_clk;
     wire rf_rst;
     wire rf_we;
     wire [4:0]readAddr1;
     wire [4:0]readAddr2;
     wire [4:0]rf_rdc;
     wire [31:0]rf_rd;
     wire [31:0]readData1;
     wire [31:0]readData2;
     //add32_1
     wire add32_1_out;
     //shifter_1
     wire shifter1_out;
     
     ADDU NPC(				//NPCģ��
     .in1(pc_data_out),			//���ܣ�ÿ�ν�pc+4��ָ����һ��ָ���ַ
     .in2(32'd4),
     .out(npc_out)
     );
     
     wire mux1_m;
     
     MUX MUX1(				//����ѡ����1
     .choice(ALUsrc),			//����ΪALUsrc������ALUin2��������Դ
     .data_in1(readData2),
     .data_in2(ext01_out),//ALUsrcΪ1,���������
     .dataOut(mux_1_out)
     );
     
     wire [31:0] mux2_in1;
     wire [31:0] mux2_in2;
     wire [31:0] mux2_in3;
     wire [31:0] mux2_out;
     wire [1:0] mux2_m;
     MMUX MUX2(				//����ѡ����2����·��
     .choice(mux2_m),
     .data_in1(mux2_in1),
     .data_in2(mux2_in2),
     .data_in3(mux2_in3),
     .dataOut(mux2_out)
     );
    
     wire [31:0] mux3_out;
     wire mux3_m;			//����ѡ����3
     MUX MUX3(
     .choice(mux3_m),
     .data_in1(npc_out),
     .data_in2(add32_1_out),
     .dataOut(mux3_out)
     );
     
     wire [4:0] ext5_in;
     wire [31:0] ext5_out;
     wire ext5_c;
     Ext5 ext5(		//����������
     .dataInput(ext5_in),		//����������Ϊ32λ
     .dataOut(ext5_out),
     .ca(ext5_c)
     );
     

     wire ext16_c;
      Ext16 Ext01(		//���������� ����ָ����16λ��������Ȼ��ת��Ϊ32λ
     .dataInput(imm16),
     .dataOut(ext01_out),
     .ca(zeroExt) //0Ϊ������չ
     );

     shifter shifter1(
     .in1(ext01_out),
     .in2(32'd2),
     .out(shifter1_out)
     );

     ADD32 add32_1(
     .in1(pc_data_out),
     .in2(shifter1_out),
     .out(add32_1_out)
     );
     
     
     wire [15:0] ext18_in;
     wire [31:0] ext18_out;
     wire ext18_c;
     Ext18 ext18(		//����������
     .dataInput(ext18_in),
     .dataOut(ext18_out),
     .ca(ext18_c)
     );
     
      //    wire pc_ena;

     PCReg PC(				//PC�Ĵ���
     .clk(clk),			//���ܣ������һ��ָ��ĵ�ַ
     .rst(pc_rst),
     .ew(PCwrite),
     .inputData(pc_data_in),
     .outputData(pc_data_out),
     .data31_28(pc_data31_28)
     );
          

     ALU ALU(				//ALUģ��
     .in1(),
     .in2(mux_1_out),
     .out(alu_out),
     .op(ALUControl),
     .zf(zf),
     .cf(cf),
     //.negative(n),
     .of(of)
     );
     
     
     assign imem_data_in=32'b0;

     IMEM imem(
     .clk(clk),
     .addr(imem_addr),
     .inpt(imem_data_in),
     .outp(imem_data_out)
     );
     

     assign rf_rst=rst;

     RegFile cpu_ref(		//ͨ�üĴ���ģ��
     .clk(rf_clk),
     .rst(rf_rst),
     .we(rf_we),
     .raddr1(readAddr1),
     .rdata1(readData1),
     .raddr2(readAddr2),
     .rdata2(readData2),
     .waddr(rf_rdc),
     .wdata(rf_rd)
     );
     
     //DMEM
     wire dmem_we;
     wire dmem_re;
     wire [31:0] dmem_addr;
     wire [31:0] dmem_data_in;
     wire [31:0] dmem_data_out;
     wire [31:0] dmem_data;
     DMEM dmem(
     .clk(clk),
     .WE(dmem_we),
     .addr(dmem_addr),
     .inpt(dmem_data_in),
     .outp(dmem_data_out)
     );
     wire [31:0] j_jal={npc_out[31:28],imem_data_out[25:0],2'b0};
    
    
    //CU

    controlUnit CU(
        .memRead(memRead),
        .memWrite(memWrite),
        .ALUControl(ALUControl),
        .memToReg(memToReg),
        .ALUsrc(ALUsrc),
        .regWrite(regWrite),
        .memRead(memRead),
        .memWrite(memWrite),
        .branch(branch),
        .jump(jump),
        .PCwrite(PCwrite),
        .readShamt(readShamt),
        .zeroExt(zeroExt)
        );
    //IR
    
     
endmodule
