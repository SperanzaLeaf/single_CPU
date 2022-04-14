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
    output reg [31:0] test,
        output reg [31:0] test4,
    output reg test2,
    output reg test3
    );
     //

     
     
     
     //CU
    wire PC_clk;
    wire [5:0] ALUControl;
    wire regFileW;
    wire regFileClk;
    wire regDst;
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
    wire [1:0] saveOpt;
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
     //MUX6
     wire [31:0] mux_6_out;
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
     assign rf_clk=clk;
     wire rf_rst;
     wire [4:0]readAddr1;
     wire [4:0]readAddr2;
     wire [4:0]rf_rdc;
     wire [31:0]rf_rd;
     wire [31:0]readData1;
     wire [31:0]readData2;
     //add32_1
     wire [31:0] add32_1_out;
     //shifter_1
     wire [31:0] shifter1_out;
     //BranchControl
     wire BranchControlOut;
     //JumpADDer_1
     wire [31:0] jumpAddr_1_out;
     
     //DMEM
     wire dmem_we;
     wire dmem_re;
     wire [31:0] dmem_addr;
     wire [31:0] dmem_data_in;
     wire [31:0] dmem_data_out;
     wire [31:0] dmem_data;
     
     //ext5
     wire [31:0] ext02_out;
     
     ADDU NPC(				//NPCģ�� �������PC+4
     .in1(pc_data_out),			//���ܣ�ÿ�ν�pc+4��ָ����һ��ָ���ַ
     .in2(32'd1),
     .out(npc_out)// ������PC+4�ĵ�ַ
     );
     
     wire mux1_m;
     
     MUX MUX1(				//����ѡ����1
     .choice(ALUsrc),			//����ΪALUsrc������ALUin2��������Դ
     .data_in1(readData2),
     .data_in2(ext01_out),//ALUsrcΪ1,���������
     .dataOut(mux_1_out)
     );
    
     wire mux2_out;
     MMUX MUX2(
     .choice(saveOpt),
     .data_in1(alu_out),
     .data_in2(npc_out), 
     .data_in3(dmem_data_out),
     .dataOut(rf_rd)
     );
     
     wire [31:0] mux3_out;
     wire mux3_m;			//����ѡ����3
     MUX MUX3(
     .choice(BranchControlOut),
     .data_in1(npc_out),//һ����PC+4
     .data_in2(add32_1_out),//��һ������ת��ַ
     .dataOut(mux3_out)
     );
     
     wire mux4_out;
     MUX MUX4(
     .choice(jump),
     .data_in1(mux3_out),//PC+4����BXX�ĵ�ַ
     .data_in2(jumpAddr_1_out),
     .dataOut(pc_data_in)
     );
     
     spMUX MUX5(
     .choice(regDst),
     .data_in1(Rtc),
     .data_in2(Rdc),
     .dataOut(rf_rdc)
     );
     
     MUX MUX6(
     .choice(readShamt),
     .data_in1(readData1),
     .data_in2(ext02_out),
     .dataOut(mux_6_out)
     );

     JumpADDer JumpADDer_1(
     .inst_add(target),
     .PCPlus4(npc_out[31:28]),
     .out(jumpAddr_1_out)
     );
     
    
    
     wire ext16_c;
      Ext16 Ext01(		//���������� ����ָ����16λ��������Ȼ��ת��Ϊ32λ�����ﴦ�����BXXָ�����������תΪ32λ
     .dataInput(imm16),
     .dataOut(ext01_out),
     .ca(zeroExt) //0Ϊ������չ
     );
     
      Ext5 Ext02(		//���������� ����ָ����5λshamt��Ȼ��ת��Ϊ32λ�����ﴦ�����BXXָ�����������תΪ32λ
         .dataInput(sa),
         .dataOut(ext02_out),
         .ca(zeroExt) //0Ϊ������չ
      );

     shifter shifter1(//���ﴦ��BXXָ�����������ַ
     .in1(ext01_out),
     .in2(32'd2),
     .out(shifter1_out)
     );

     ADDU add32_1(  //���ﴦ�����PC+4+BXXָ���������ת���ĵ�ַ
     .in1(pc_data_out),
     .in2(shifter1_out),
     .out(add32_1_out)
     );

     
     PCReg PC(				//PC�Ĵ���
     .clk(clk),			//���ܣ������һ��ָ��ĵ�ַ
     .rst(pc_rst),
     .ew(PCwrite),
     .inputData(pc_data_in),
     //.inputData(npc_out),
     .outputData(pc_data_out),
     .data31_28(pc_data31_28)
     );
          

     ALU ALU(				//ALUģ��
     .in1(mux_6_out),
     .in2(mux_1_out),
     .out(alu_out),
     .op(ALUControl),
     .zf(zf),
     .cf(cf),
     .smt(sa),
     //.negative(n),
     .of(of)
     );
  
/*IMEM IMEM(
.outp(imem_data_out),
.addr(pc_data_out)
);*/
blk_mem_gen_0 imem(
     .clka(clk),
     .addra(pc_data_out),
     .douta(imem_data_out)
     );

     assign rf_rst=rst;

     RegFile cpu_ref(		//ͨ�üĴ���ģ��
     .clk(rf_clk),
     .rst(rf_rst),
     .we(regWrite),
     .raddr1(Rsc),
     .rdata1(readData1),
     .raddr2(Rtc),
     .rdata2(readData2),
     .waddr(rf_rdc),
     .wdata(rf_rd)
     );
     
     //DMEM
     DMEM dmem(
     .WE(memWrite),
     .RE(memRead),
     .addr(alu_out),
     .inpt(readData2),
     .outp(dmem_data_out)
     );
     wire [31:0] j_jal={npc_out[31:28],imem_data_out[25:0],2'b0};
    
    
    //CU
    controlUnit CU(
        .op(RegOp),
        .fun(func),
        .ALUControl(ALUControl),
        .memToReg(memToReg),
        .regDst(regDst),
        .ALUsrc(ALUsrc),
        .regWrite(regWrite),
        .memRead(memRead),
        .memWrite(memWrite),
        .branch(branch),
        .jump(jump),
        .PCwrite(PCwrite),
        .readShamt(readShamt),
        .zeroExt(zeroExt),
        .saveOpt(saveOpt)
        );
    
     BranchControl BranchControl(
     .Input(branch),
     .Output(BranchControlOut),
     .Sign_in(alu_out[0]),
     .Zero_in(zf)
     );
     
always@(*)
     begin
        test <= pc_data_out;
        test2<=PCwrite;
        test3<=BranchControlOut;
        test4 <= npc_out;
        
     end 
endmodule
