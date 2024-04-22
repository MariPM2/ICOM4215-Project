module Concatenate_si(
    output reg [2:0] conc_result,
    input wire value_one,
    input wire value_two,
    input wire value_three
);
    always @(*) begin
        conc_result = {value_one, value_two, value_three};
    end
endmodule