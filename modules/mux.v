// ???

module CONTROL_UNIT_MUX (
    // output reg ID_RT_DEST_OUT,
    // output reg[2:0] ID_Shift_IMM_OUT,
    // output reg[3:0] ID_ALU_OP_OUT,
    // output reg ID_LOAD_INSTR_OUT,
    // output reg ID_RF_ENABLE_OUT,
    // output reg ID_BRANCH_ENABLE_OUT,
    // output reg ID_JUMP_ENABLE_OUT,
    // output reg ID_R31_DEST_OUT,
    // output reg ID_HI_ENABLE_OUT,
    // output reg ID_LO_ENABLE_OUT,
    // output reg[1:0] ID_SIZE_OUT,
    // output reg ID_MEM_DATA_SE_OUT,
    // output reg ID_MEM_DATA_RW_OUT,
    // output reg ID_MEM_DATA_ENABLE_OUT,
    // output reg ID_PC_PLUS_EIGHT_ENABLE_OUT,
    // input ID_RT_DEST_IN,
    // input ID_Shift_IMM_IN,
    // input ID_ALU_OP_IN,
    // input ID_LOAD_INSTR_IN,
    // input ID_RF_ENABLE_IN,
    // input ID_BRANCH_ENABLE_IN,
    // input ID_JUMP_ENABLE_IN,
    // input ID_R31_DEST_IN,
    // input ID_HI_ENABLE_IN,
    // input ID_LO_ENABLE_IN,
    // input ID_SIZE_IN,
    // input ID_MEM_DATA_SE_IN,
    // input ID_MEM_DATA_RW_IN,
    // input ID_MEM_DATA_ENABLE_IN,
    // input ID_PC_PLUS_EIGHT_ENABLE_IN,
    output reg[20:0] out_id_signal,
    input[20:0] in_id_signal,
    input wire nop_signal
);

    always @(*) begin
        // if(!nop_signal) begin
        //     ID_RT_DEST_OUT = 0;
        //     ID_Shift_IMM_OUT = 0;
        //     ID_ALU_OP_OUT = 0;
        //     ID_LOAD_INSTR_OUT = 0;
        //     ID_RF_ENABLE_OUT = 0;
        //     ID_BRANCH_ENABLE_OUT = 0;
        //     ID_JUMP_ENABLE_OUT = 0;
        //     ID_R31_DEST_OUT = 0;
        //     ID_HI_ENABLE_OUT = 0;
        //     ID_LO_ENABLE_OUT = 0;
        //     ID_SIZE_OUT = 0;
        //     ID_MEM_DATA_SE_OUT = 0;
        //     ID_MEM_DATA_RW_OUT = 0;
        //     ID_MEM_DATA_ENABLE_OUT = 0;
        //     ID_PC_PLUS_EIGHT_ENABLE_OUT = 0;
        // end
        // else begin
        //     ID_RT_DEST_OUT = ID_RT_DEST_IN;
        //     ID_Shift_IMM_OUT = ID_Shift_IMM_IN;
        //     ID_ALU_OP_OUT = ID_ALU_OP_IN;
        //     ID_LOAD_INSTR_OUT = ID_LOAD_INSTR_IN;
        //     ID_RF_ENABLE_OUT = ID_RF_ENABLE_IN;
        //     ID_BRANCH_ENABLE_OUT = ID_BRANCH_ENABLE_IN;
        //     ID_JUMP_ENABLE_OUT = ID_JUMP_ENABLE_IN;
        //     ID_R31_DEST_OUT = ID_R31_DEST_IN;
        //     ID_HI_ENABLE_OUT = ID_HI_ENABLE_IN;
        //     ID_LO_ENABLE_OUT = ID_LO_ENABLE_IN;
        //     ID_SIZE_OUT = ID_SIZE_IN;
        //     ID_MEM_DATA_SE_OUT = ID_MEM_DATA_SE_IN;
        //     ID_MEM_DATA_RW_OUT = ID_MEM_DATA_RW_IN;
        //     ID_MEM_DATA_ENABLE_OUT = ID_MEM_DATA_ENABLE_IN;
        //     ID_PC_PLUS_EIGHT_ENABLE_OUT = ID_PC_PLUS_EIGHT_ENABLE_IN;
        // end

        if (nop_signal) begin
            out_id_signal = 21'b0;
        end
        else begin
            out_id_signal = in_id_signal;
        end
    end
endmodule