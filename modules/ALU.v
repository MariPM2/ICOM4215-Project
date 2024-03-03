module ALU(
    input [31:0] A,
    input [31:0] B,
    input [3:0] Op,
    output reg [31:0] Out,
    output reg Z,
    output reg N,
    output reg C,
    output reg V
    
);

always @(A, B, Op)
begin
    Z = 0;
    N = 0;
    C = 0;
    V = 0;
    case (Op)
        4'b0000: Out = B;

        4'b0001: Out = B+4;

        4'b0010: Out = A+B; //overflow??

        4'b0011:
        begin
            Out = A-B; //overflow?
            Z = (Out == 32'b0);
            N = Out[31];
            C = A >= B;
            V = (A[31] ^ B[31]) & (A[31] ^ Out[31]);
        end

        4'b0100: Out = (A + B) & 32'hFFFFFFFE;// 0xFFFFFFFE

        4'b0101: Out = A << B[4:0];

        4'b0110: Out = A >> B[4:0];

        4'b0111: Out = $signed(A) >>> B[4:0];

        4'b1000:
            begin
            if(A<B) Out =1;
            else Out =0;
            Z = (Out == 32'b0);
            N = Out[31];
            C = A >= B; //duda?
            V = (A[31] ^ B[31]) & (A[31] ^ Out[31]); //duda
        end

        4'b1001:
        begin
            if(A<B) Out =1;
            else Out =0;
            Z = (Out == 32'b0);
            N = Out[31];
            C = A >= B;//duda
            V = (A[31] ^ B[31]) & (A[31] ^ Out[31]);//duda
        end

        4'b1010: Out = A&B;

        4'b1011: Out = A|B;

        4'b1100: Out = A ^ B;

        /*
        NOT USED:
        4'b1101
        4'b1110
        4'b1111
        */
        default: Out =  32'b0;
    endcase
end
endmodule