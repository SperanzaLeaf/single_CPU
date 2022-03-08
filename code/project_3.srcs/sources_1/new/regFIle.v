`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/08 11:06:32
// Design Name: 
// Module Name: regFIle
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


module regFile(
    input clk,//ʱ������
    input rst,//����
    input we, //д����
    input [4:0] raddr1,//��ȡ�ĵ�ַ1
    input [4:0] raddr2,//��ȡ�ĵ�ַ2
    input [4:0] waddr,//д��ĵ�ַ
    input [31:0] wdata,//д�������
    output [31:0] rdata1,//��ȡ������1
    output [31:0] rdata2 //��ȡ������2
    );
    
    reg [31:0] array_reg [0:31];//MIPS�ܹ���32��ͨ�üĴ���
    integer i;
    always@(posedge clk or posedge rst) begin
        if(rst) 
            begin//reset����
                for(i=0;i<32;i=i+1)
                    array_reg[i]<=32'b0;//�����е����ݹ���
            end
        else 
            begin
                if(we&&waddr!=5'b0) //���������д�룬��Ŀ��Ĵ�����Ϊ��Ĵ�������ΪĬ����Ĵ�����ֵ��Ϊ0��
                    array_reg[waddr]<=wdata;//д����Ҫд��ļĴ���
            end
    end
    
    assign rdata1=(raddr1==5'b0)?32'b0:array_reg[raddr1];//��ȡ���
    assign rdata2=(raddr2==5'b0)?32'b0:array_reg[raddr2];//��ȡ���
endmodule
