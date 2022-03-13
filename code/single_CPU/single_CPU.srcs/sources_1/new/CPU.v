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
     
     wire [31:0] npc_out;
     wire [31:0] npc_in;
         
     ADDU NPC(				//NPCģ��
     .in1(npc_in),			//���ܣ�ÿ�ν�pc+4��ָ����һ��ָ���ַ
     .in2(32'd4),
     .out(npc_out)
     );
     
     wire [31:0] mux1_in1;
     wire [31:0] mux1_in2;
     wire [31:0] mux1_out;
     wire mux1_m;
     
     MUX MUX1(				//����ѡ����1
     .choice(mux1_m),			//���ܣ����ݲ�ͬ���ź�ѡ���õ�������Ϊ���
     .data_in1(mux1_in1),
     .data_in2(mux1_in2),
     .dataOut(mux1_out)
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
    
     wire [31:0] mux3_in1;
     wire [31:0] mux3_in2;
     wire [31:0] mux3_out;
     wire mux3_m;			//����ѡ����3
     MUX MUX3(
     .choice(mux3_m),
     .data_in1(mux3_in1),
     .data_in2(mux3_in2),
     .dataOut(mux3_out)
     );
    
     wire [31:0] mux4_in1;
     wire [31:0] mux4_in2;
     wire [31:0] mux4_out;
     wire mux4_m;			//����ѡ����4
     MUX MUX4(
     .choice(mux4_m),
     .data_in1(mux4_in1),
     .data_in2(mux4_in2),
     .dataOut(mux4_out)
     );
     
     wire [31:0] mux5_in1;
     wire [31:0] mux5_in2;
     wire [31:0] mux5_out;
     wire mux5_m;
     MUX MUX5(				//����ѡ����5
     .choice(mux5_m),
     .data_in1(mux5_in1),
     .data_in2(mux5_in2),
     .dataOut(mux5_out)
     );
     
     wire [31:0] mux6_in1;
     wire [31:0] mux6_in2;
     wire [31:0] mux6_out;
     wire mux6_m;
     MUX MUX6(				//����ѡ����6
     .choice(mux6_m),
     .data_in1(mux6_in1),
     .data_in2(mux6_in2),
     .dataOut(mux6_out)
     );
     
     wire [31:0] mux7_in1;
     wire [31:0] mux7_in2;
     wire [31:0] mux7_out;
     wire mux7_m;
     MUX MUX7(				//����ѡ����7
     .choice(mux7_m),
     .data_in1(mux7_in1),
     .data_in2(mux7_in2),
     .dataOut(mux7_out)
     );
     
     wire [31:0] mux8_in1;
     wire [31:0] mux8_in2;
     wire [31:0] mux8_out;
     wire mux8_m;
     MUX MUX8(				//����ѡ����8
     .choice(mux8_m),
     .data_in1(mux8_in1),
     .data_in2(mux8_in2),
     .dataOut(mux8_out)
     );
     
     wire [4:0] ext5_in;
     wire [31:0] ext5_out;
     wire ext5_c;
     Ext5 ext5(		//����������
     .dataInput(ext5_in),		//����������Ϊ32λ
     .dataOut(ext5_out),
     .ca(ext5_c)
     );
     
     wire [15:0] ext16_in;
     wire [31:0] ext16_out;
     wire ext16_c;
     Ext16 ext16(		//����������
     .dataInput(ext16_in),
     .dataOut(ext16_out),
     .ca(ext16_c)
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
     wire pc_clk;
     wire pc_rst;
     assign pc_rst=rst;
     wire [31:0] pc_data_in;
     wire [31:0] pc_data_out;
     wire [3:0] pc_data31_28;
     PCReg PC(				//PC�Ĵ���
     .clk(pc_clk),			//���ܣ������һ��ָ��ĵ�ַ
     .rst(pc_rst),
     .ew(1'b1),
     .inputData(pc_data_in),
     .outputData(pc_data_out),
     .type(pc_data31_28)
     );
          
     wire [31:0] alu_in1;
     wire [31:0] alu_in2;
     wire [31:0] alu_out;
     wire [5:0] ALUop;
     wire zf;
     wire cf;
     //wire n;
     wire of;
     ALU ALU(				//ALUģ��
     .in1(alu_in1),
     .in2(alu_in2),
     .out(alu_out),
     .op(ALUop),
     .zf(zf),
     .cf(cf),
     //.negative(n),
     .overflow(of)
     );
     
     
     //     wire imem_wena;
     //    assign imem_wena=0;
     //     wire [31:0] imem_addr;
     //    wire [31:0] imem_data_in;
     //     assign imem_data_in=32'b0;
     wire [31:0] imem_data_out;
     wire [25:0] target=imem_data_out[25:0];
     wire [4:0] sa=imem_data_out[10:6];
     wire [4:0] Rsc=imem_data_out[25:21];
     wire [4:0] Rtc=imem_data_out[20:16];
     wire [4:0] Rdc=imem_data_out[15:11];
     wire [5:0] RegOp=imem_data_out[31:26];
     wire [5:0] func=imem_data_out[5:0];
     wire [15:0] imm16=imem_data_out[15:0];
/*     IMEM imem(
     .clk(clk),
     .wena(imem_wena),
     .addr(imem_addr),
     .data_in(imem_data_in),
     .data_out(imem_data_out)
     );*/
     
     wire rf_clk;
     wire rf_rst;
     assign rf_rst=rst;
     wire rf_we;
     wire [4:0]rf_rsc;
     wire [4:0]rf_rtc;
     wire [4:0]rf_rdc;
     wire [31:0]rf_rd;
     wire [31:0]rf_rs;
     wire [31:0]rf_rt;
     RegFile cpu_ref(		//ͨ�üĴ���ģ��
     .clk(rf_clk),
     .rst(rf_rst),
     .we(rf_we),
     .raddr1(rf_rsc),
     .rdata1(rf_rs),
     .raddr2(rf_rtc),
     .rdata2(rf_rt),
     .waddr(rf_rdc),
     .wdata(rf_rd)
     );

     
endmodule
