module SecondOperandHandler(
    output reg [31:0] N, 
    input [31:0] PB, 
    input [2:0] Si,
    input [11:0] imm12_I,
    input [11:0] imm12_S,
    input [19:0] imm20,
    input [31:0] PC
);

always @(PB, Si, imm12_I, imm12_S, imm20, PC)
begin
    case(Si)
        3'b000: N = PB; 

        //extend to 32 bit, imm12_I[11] MSB, 20{imm12_I[11]} replica el MSB 20 veces, {} concatena la replica 20bit con el 12bit 
        3'b001: N = {{20{imm12_I[11]}}, imm12_I};
        3'b010: N = {{20{imm12_S[11]}}, imm12_S};

        3'b011:  N = {imm20,  12'b0};//Place 12-bit immediate in upper bits

        3'b100: N = PC;
         /*
        NOT USED:
        3'b101:
        3'b110:
        3'b111:
        */
        default: N = 32'b0;
    endcase
end
endmodule