module PW_SELECTOR(
    output reg[31:0] pw_in,
    input wire[31:0] alu_out, ram_out,
    input wire load_instr
    );
    
    always @(*) begin
        if (load_instr) begin
            pw_in = ram_out;
        end
        else pw_in = alu_out;
    end
endmodule