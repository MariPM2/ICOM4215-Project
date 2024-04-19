module CONDITION_HANDLER(
    output reg control_hazard,
    // input wire[2:0] instruction_condition,
    // input wire[1:0] flags,
    input reg Z,
    input reg N,
    input reg C,
    input reg V,
    input wire[2:0] branch_type
);

    always @(*) begin
        if (ex_branch_enable) begin
            //B or BAL
            if (instruction_condition == 3'b000) begin
                control_hazard <= 1'b1;
            end
            //BEQ
            else if ((instruction_condition == 3'b001) && (flags[0] == 1'b1)) begin
                control_hazard <= 1'b1;
            end
            //BGEZ ot BGEZAL
            else if ((instruction_condition == 3'b010) && ((flags[0] == 1'b1) || (flags[1] == 1'b0))) begin
                control_hazard <= 1'b1;
            end
            //BGTZ
            else if ((instruction_condition == 3'b011) && (flags[0] == 1'b0) && (flags[1] == 1'b0)) begin
                control_hazard <= 1'b1;
            end
            //BLEZ
            else if ((instruction_condition == 3'b100) && ((flags[0] == 1'b1) || (flags[1] == 1'b1))) begin
                control_hazard <= 1'b1;
            end
            //BLTZ or BLTZAL
            else if ((instruction_condition == 3'b101) && ((flags[0] == 1'b0) && (flags[1] == 1'b1))) begin
                control_hazard <= 1'b1;
            end
            //BNE
            else if (instruction_condition == 3'b110) begin
                control_hazard <= 1'b1;
            end
            else control_hazard <= 1'b0;
        end
        else control_hazard <= 1'b0;
        //$display("Instr_cond: %b, Control_Hzrd: %b, Flags: %b", instruction_condition, control_hazard, flags);
    end

endmodule