module GEN_MUX(
    output reg[31:0] selected,
    input wire[31:0] option_one, option_two,
    input wire signal
);

    always @(*) begin
        if(signal) selected <=option_two;
        else 
        selected <=option_one;
    end

endmodule