`include "../modules/ALU.v"

module test_ALU;
  
  reg [31:0] A, B;
  reg [3:0] Op;
  wire [31:0] Out;
  wire Z, N, C, V;

  ALU alu_inst (
    .A(A),
    .B(B),
    .Op(Op),
    .Out(Out),
    .Z(Z),
    .N(N),
    .C(C),
    .V(V)
  );

  initial begin
    $display("OP    \t\tA(dec)      \t\tA(bin)     \t\t\t\tB(dec)      \t\tB(bin)      \t\t\t\tOut(dec)       \t\tOut (bin)       \t\t\tZ\tN\tC\tV");

    for (Op = 0; Op <= 15; Op = Op + 1) begin
      A = 32'b10011100000000000000000000111000;
      B = 32'b01110000000000000000000000000011;

      #2;

      $display("%b\t%d\t%b\t%d\t%b\t%d\t%b\t%b\t%b\t%b\t%b", Op, A, A, B, B, Out, Out, Z, N, C, V);

      if (Op == 15) begin
        $display("ALU test completed!");
        $finish;
      end
    end
  end
endmodule
