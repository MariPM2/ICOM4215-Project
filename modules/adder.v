module ADDER(
    output reg [31:0] addition,
    input wire [31:0] value_one,
    input wire [31:0] value_two
);
    always @(*) begin
        addition = value_one + value_two;
    end
endmodule