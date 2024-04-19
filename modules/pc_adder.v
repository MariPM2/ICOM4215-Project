module PC_ADDER (
    output reg[31:0] adder_out,
    input[31:0] adder_in
);
    always @(adder_in) begin
        // adder_out = adder_in + 4;
        adder_out = adder_in + 32'b100;
    end
endmodule