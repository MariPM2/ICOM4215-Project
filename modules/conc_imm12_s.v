module Concatenate_imm12_s(
    output reg [11:0] conc_result,
    input wire [6:0] value_one,
    input wire [4:0] value_two
);
    always @(*) begin
        conc_result = {value_one, value_two};
    end
endmodule