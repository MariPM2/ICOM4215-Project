/*
    512 ROM module by Mariana Pérez
*/

module rom(output reg [31:0] I, input [8:0] A);

    reg [7:0] Mem[0:511];

    always @(*) begin
        // I = {Mem[A+3], Mem[A+2], Mem[A+1], Mem[A]}; sale al revés
        I = {Mem[A], Mem[A+1], Mem[A+2], Mem[A+3]};
    end

endmodule
