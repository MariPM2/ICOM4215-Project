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

reg [32:0] temp; //temporary value for A-B

always @(A, B, Op)
begin
    Z = 0;
    N = 0;
    C = 0;
    V = 0;

    case (Op)
        4'b0000: Out = B;

        4'b0001: Out = B+4;

        4'b0010: Out = A+B;

        4'b0011:
        begin
            //Out = A - B;
            temp = {1'b1, A} - {1'b0, B};
            Out = temp[31:0];

            if (Out == 32'b0) Z = 1; //if Out = 0, Z=1
            else Z = 0;

            N = Out[31]; //MSB

            C = ~temp[32];

            V = (A[31] ^ B[31]) & (A[31] ^ Out[31]);
        end

        4'b0100: Out = (A + B) & 32'b11111111111111111111111111111110;// 0xFFFFFFFE

        4'b0101: Out = A << B[4:0];//shifts A to the left B[4:0] bits

        4'b0110: Out = A >> B[4:0]; //shifts A to the right B[4:0] bits

        4'b0111: Out = $signed(A) >>> B[4:0]; //arithmetic right shift on A, B[4:0] bits

        4'b1000:
            begin
            temp = {1'b1, A} - {1'b0, B};
            Out = temp[31:0];

            if (Out == 32'b0) Z = 1; //if Out = 0, Z=1
            else Z = 0;

            N = Out[31]; //MSB

            C = ~temp[32];

            V = (A[31] ^ B[31]) & (A[31] ^ Out[31]);

            if(~(N)&V) Out =1;
            else Out =0;
        end

        4'b1001:
        begin
            temp = {1'b1, A} - {1'b0, B};
            Out = temp[31:0];

            if (Out == 32'b0) Z = 1; //if Out = 0, Z=1
            else Z = 0;

            N = Out[31]; //MSB

            C = ~temp[32];

            V = (A[31] ^ B[31]) & (A[31] ^ Out[31]);

            if(C == 1) Out =1;
            else Out =0;
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