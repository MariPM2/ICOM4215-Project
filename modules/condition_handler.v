module CONDITION_HANDLER(
    output reg control_hazard,
    // input wire[2:0] instruction_condition,
    // input wire[1:0] flags,
    input Z,
    input N,
    input C,
    input V,
    input wire[2:0] branch_type
);

    always @(*) begin
        // NOT A BRANCH
        if (branch_type == 3'b000) begin
            // control_hazard <= 1'b1;
            control_hazard <= 1'b0;
        end

        // Z = 1 si rs1 = rs2
        // N = 1 si rs1 < rs2

        //BEQ
        else if ((branch_type == 3'b010) && (Z == 1'b1)) begin
            control_hazard <= 1'b1;
        end
        //BNE
        else if ((branch_type == 3'b001) && (Z == 1'b0)) begin
            control_hazard <= 1'b1;
        end
        //BLT
        else if ((branch_type == 3'b100) && (Z == 1'b0) && (N == 1'b1)) begin
            control_hazard <= 1'b1;
        end
        //BGE
        else if ((branch_type == 3'b101) && ((Z == 1'b1) || (N == 1'b0))) begin
            control_hazard <= 1'b1;
        end
        //BLTU
        else if ((branch_type == 3'b110) && (Z == 1'b0) && (N == 1'b1)) begin
            control_hazard <= 1'b1;
        end
        //BGEU
        else if (branch_type == 3'b111 && ((Z == 1'b1) || (N == 1'b0))) begin
                control_hazard <= 1'b1;
        end
            else control_hazard <= 1'b0;
    end 

endmodule