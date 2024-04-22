module IF_MUX(
    output reg[31:0] pc_in,
    input wire[31:0] ex_TA,
    input wire[31:0] ex_alu,
    input wire[31:0] id_TA,
    input wire[31:0] adder_out,
    input [2:0] decision_output
    );
    
    always @(*) begin
        if (decision_output == 3'b001) begin
            pc_in = ex_TA;
        end
        else if (decision_output == 3'b010) begin
            pc_in = id_TA;
        end
        else if (decision_output == 3'b011) begin
            pc_in = ex_alu;
        end
        else pc_in = adder_out;
    end
endmodule