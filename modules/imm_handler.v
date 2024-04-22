module IMM_HANDLER(
    output reg [31:0] imm_out,
    input wire Jal,
    input wire[31:0] instr
    );
    
    always @(*) begin
    // For j-type
        if (Jal) begin
            // 13 bits
            imm_out = {{12{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
            // $display("Imm_out_JAL:%d", imm_out);
        end
        else begin
            // 21 bits
            // imm_out = {{19{instr[24]}}, instr[24], instr[12:5], instr[13], instr[23:14], 1'b0};
            // Branch
            imm_out = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            // $display("Imm_out_B:%d", imm_out);
        end
    end
endmodule