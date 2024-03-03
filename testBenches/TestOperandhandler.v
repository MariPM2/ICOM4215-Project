`include "../modules/SecondOperandHandler.v"

module TestSecondOperandHandler;
    reg [2:0] Si;
    reg [31:0] PB;
    reg [31:0]imm12_I;
    reg [31:0] imm12_S;
    reg [31:0] PC;
    reg [19:0] imm20;
    wire [31:0] N;

    SecondOperandHandler SOH(
        .Si(Si),
        .PB(PB),
        .imm12_I(imm12_I),
        .imm12_S(imm12_S),
        .PC(PC),
        .imm20(imm20),
        .N(N)
    );

    initial begin
        $display("S2 S1 S0  \t\tN");
        
        PB = 32'b00000100001100011111111111101010;
        imm12_I = 32'b110000001100;
        imm12_S = 32'b011100001111;
        PC = 32'b11000100001100011111111111101010;
        imm20 = 20'b11101100010001001111; 

        for (Si = 0; Si <= 7; Si = Si + 1) begin

            #10;
            $display("%b  %b  %b\t\t%b", Si[2], Si[1], Si[0], N);

            if (Si == 3'b101) $finish;
        end
    end
endmodule