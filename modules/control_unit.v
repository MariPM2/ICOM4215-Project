module CONTROL_UNIT (
    output reg[20:0] id_signal,
    input[31:0] instruction
);

    reg[3:0] ID_ALU_op;
    reg ID_load_instr;
    reg ID_RF_enable;
    reg ID_S2;
    reg ID_S1;
    reg ID_S0;
    reg[2:0] ID_branchType;
    reg[1:0] ID_Size;
    reg ID_E;
    reg ID_SE;
    reg ID_RW;
    reg ID_dataMemAddressInput;
    reg ID_AUIPC;
    reg ID_JALR;
    reg ID_JAL;


    always@(instruction) begin

        ID_ALU_op = 0;
        ID_load_instr = 0;
        ID_RF_enable = 0;
        ID_S2 = 0;
        ID_S1 = 0;
        ID_S0 = 0;
        ID_branchType = 0;
        ID_Size = 0;
        ID_E = 0;
        ID_SE = 0;
        ID_RW = 0;
        ID_dataMemAddressInput = 0;
        ID_AUIPC = 0;
        ID_JALR = 0;
        ID_JAL = 0;

        case (instruction[6:0])
            //ADD:
            7'b0010011: begin
                            ID_load_instr = 0;
                            ID_ALU_op = 4'b0010;    //Selected ADD
                            ID_RF_enable = 1;       //Activated
                        end
            // SUB:
            7'b0110011: begin
                            ID_load_instr = 0;
                            ID_ALU_op = 4'b0011;    //Selected SUB
                            ID_RF_enable = 1;       //Activated
                        end
            // SB:
            7'b0100011: begin
                            ID_load_instr = 0;                //Deactivated because we are writing
                            ID_Size = 2'b00;            //Reading SOMETHING NOT DISCLOSED
                            ID_SE = 0;         //Irrelevant
                            ID_E = 1;     //Enable RAM
                        end
            // BGE:
            7'b1100011: begin
                            ID_RF_enable = 1;                   //Activated
                            ID_branchType = 3'b101;               //Activated  
                        end
            // LUI:
            7'b0110111: begin
                            ID_S2 = 0;
                            ID_S1 = 1;
                            ID_S0 = 1;
                            ID_ALU_op = 4'b0001;    
                            ID_RF_enable = 1;       //Activated
                        end
            // JAL:
            7'b1101111: begin
                            ID_load_instr = 0;
                            ID_RF_enable = 1;
                            ID_JAL = 1;
                        end
            // JALR:
            7'b1100111: begin
                            ID_load_instr = 0;
                            ID_RF_enable = 1;
                            ID_JALR = 1;
                        end
            // LB or LBU:
            7'b0000011: begin
                            // LB:
                            if(instruction[14:12] == 3'b000) begin
                                ID_load_instr = 1;          //Activated to select what is stored in ram
                                ID_RF_enable = 1;           //Activated
                                ID_Size  = 2'b00;            //Reading byte 
                                ID_SE = 0;         //Deactivated for unsigned
                                ID_E = 1;     //Enable RAM
                               
                            end
                            // LBU:
                            else if(instruction[14:12] == 3'b100) begin
                                ID_load_instr  = 1;          //Activated to select what is stored in ram
                                ID_RF_enable  = 1;           //Activated
                                ID_Size = 2'b00;            //Reading byte
                                ID_SE = 0;         //Deactivated for unsigned
                                ID_E = 1;     //Enable RAM
                            end
                        end
        endcase

        // // Identify J
        // // if (instruction[6:0] == 6'b000010) begin
        // //     ID_JUMP_ENABLE_value = 1;     //Activated

        // // end
        // // Identify JAL
        // if (instruction[6:0] == 7'b1101111) begin
        //     ID_LOAD_INSTR_value = 0;
        //     ID_RF_ENABLE_value = 1;               //Activated
        //     ID_BRANCH_ENABLE_value = 0;           //Deactivated because we want address26 for PC = TA
        //     ID_JUMP_ENABLE_value = 1;             //Activated
        //     ID_R31_DEST_value = 1;                //Activated since r31 is the destination
        //     ID_PC_PLUS_EIGHT_ENABLE_value = 1;    //Activated because PC+8 will be stored there

        //     ID_RF_enable = 1;
        //     ID_JAL = 1;

        // end

        // // Identify JALR, JR, ADD, ADUU, SUB, SUBU
        // else if (instruction[31:26] == 6'b000000) begin
        //     // Identify JR (opcode in IF/ID register determines PC=rs in separate mux)
        //     if (instruction[5:0] == 6'b001000) begin
        //         ID_JUMP_ENABLE_value = 1;             //Activated
        //     end
        //     // Identify JALR (opcode in IF/ID register determines PC=rs in separate mux)
        //     else if (instruction[5:0] == 6'b001001) begin
        //         ID_JUMP_ENABLE_value = 1;             //Activated
        //         ID_PC_PLUS_EIGHT_ENABLE_value = 1;    //Activated because PC+8 will be stored there
        //     end
        //     // Identify ADD
        //     else if (instruction[5:0] == 6'b100000) begin
        //         ID_ALU_OP_value = 4'b0000;    //Selected ADD
        //         ID_RF_ENABLE_value = 1;       //Activated
        //     end
        //     // Identify ADDU
        //     else if (instruction[5:0] == 6'b100001) begin
        //         ID_ALU_OP_value = 4'b0000;    //Selected ADD
        //         ID_RF_ENABLE_value = 1;       //Activated
        //     end
        //     // Identify SUB
        //     else if (instruction[5:0] == 6'b100010) begin
        //         ID_ALU_OP_value = 4'b0001;    //Selected SUB
        //         ID_RF_ENABLE_value = 1;       //Activated
        //     end
        //     // Identify SUBU
        //     else if (instruction[5:0] == 6'b100011) begin
        //         ID_ALU_OP_value = 4'b0001;    //Selected SUB
        //         ID_RF_ENABLE_value = 1;       //Activated
        //     end
        // end
        // //Identify BAL, BGEZAL, BLTZEL
        // else if (instruction[31:26] == 6'b000001 && (instruction[20:16] == 6'b10001 || instruction[20:16] == 6'b10000)) begin
        //     ID_RF_ENABLE_value = 1;                   //Activated
        //     ID_BRANCH_ENABLE_value = 1;               //Activated
        //     ID_R31_DEST_value = 1;                    //Activated
        //     ID_PC_PLUS_EIGHT_ENABLE_value = 1;        //Activated
        // end
        // // Identifies other branches
        // else if (instruction[31:26] == 6'b000100 || instruction[31:26] == 6'b000001 || instruction[31:26] == 6'b000111 || instruction[31:26] == 6'b000110 || instruction[31:26] == 6'b000101) begin
        //     ID_ALU_OP_value = 4'b1010;                //Selected A
        //     ID_BRANCH_ENABLE_value = 1;               //Activated
        // end
        // // Identifies move instructions
        // // else if (instruction[31:26] == 6'b000000) begin
        // //     if (instruction[5:0] == 6'010000) begin
                
        // //     end
        // //     else if (instruction[5:0] == 6'010010) begin
                
        // //     end
        // //     else if (instruction[5:0] == 6'001011) begin
                
        // //     end
        // //     else if (instruction[5:0] == 6'001010) begin
                
        // //     end
        // //     else if (instruction[5:0] == 6'010001) begin
                
        // //     end
        // //     else if (instruction[5:0] == 6'010011) begin
                
        // //     end
        // // end
        // // Identifies LW
        // else if (instruction[31:26] == 6'b100011) begin
        //     ID_LOAD_INSTR_value = 1;          //Activated to select what is stored in ram
        //     ID_RT_DEST_value = 1;             //Activated to store in rt
        //     ID_RF_ENABLE_value = 1;           //Activated
        //     ID_SIZE_value = 2'b10;            //Reading word
        //     ID_MEM_DATA_SE_value = 0;         //Deactivated for unsigned
        //     ID_MEM_DATA_ENABLE_value = 1;     //Enable RAM
        // end
        // // Identifies LH
        // else if (instruction[31:26] == 6'b100001) begin
        //     ID_LOAD_INSTR_value = 1;          //Activated to select what is stored in ram
        //     ID_RT_DEST_value = 1;             //Activated to store in rt
        //     ID_RF_ENABLE_value = 1;           //Activated
        //     ID_SIZE_value = 2'b01;            //Reading halfword
        //     ID_MEM_DATA_SE_value = 0;         //Deactivated for unsigned
        //     ID_MEM_DATA_ENABLE_value = 1;     //Enable RAM
        // end
        // // Identifies LHU
        // else if (instruction[31:26] == 6'b100101) begin
        //     ID_LOAD_INSTR_value = 1;          //Activated to select what is stored in ram
        //     ID_RT_DEST_value = 1;             //Activated to store in rt
        //     ID_RF_ENABLE_value = 1;           //Activated
        //     ID_SIZE_value = 2'b01;            //Reading halfword
        //     ID_MEM_DATA_SE_value = 1;         //Activated for signs
        //     ID_MEM_DATA_ENABLE_value = 1;     //Enable RAM
        // end
        // // Identifies LB
        // else if (instruction[31:26] == 6'b100000) begin
        //     ID_LOAD_INSTR_value = 1;          //Activated to select what is stored in ram
        //     ID_RT_DEST_value = 1;             //Activated to store in rt
        //     ID_RF_ENABLE_value = 1;           //Activated
        //     ID_SIZE_value = 2'b00;            //Reading byte
        //     ID_MEM_DATA_SE_value = 0;         //Deactivated for unsigned
        //     ID_MEM_DATA_ENABLE_value = 1;     //Enable RAM
        //     ID_PC_PLUS_EIGHT_ENABLE_value = 0;
        // end
        // // Identifies LBU
        // else if (instruction[31:26] == 6'b100100) begin
        //     ID_LOAD_INSTR_value = 1;          //Activated to select what is stored in ram
        //     ID_RT_DEST_value = 1;             //Activated to store in rt
        //     ID_RF_ENABLE_value = 1;           //Activated
        //     ID_SIZE_value = 2'b00;            //Reading byte
        //     //ID_MEM_DATA_SE_value = 1;         //Activated for signs
        //     ID_MEM_DATA_ENABLE_value = 1;     //Enable RAM
        //     ID_PC_PLUS_EIGHT_ENABLE_value = 0;
        // end
        // // Identifies SD
        // else if (instruction[31:26] == 6'b111111) begin
        //     ID_LOAD_INSTR_value = 0;                //Deactivated because we are writing
        //     ID_SIZE_value = 2'b11;            //Reading SOMETHING NOT DISCLOSED
        //     ID_MEM_DATA_SE_value = 0;         //Irrelevant
        //     ID_MEM_DATA_ENABLE_value = 1;     //Enable RAM
        // end
        // // Identifies SW
        // else if (instruction[31:26] == 6'b101011) begin
        //     ID_LOAD_INSTR_value = 0;                //Deactivated because we are writing
        //     ID_SIZE_value = 2'b10;            //Reading word
        //     ID_MEM_DATA_SE_value = 0;         //Irrelevant
        //     ID_MEM_DATA_ENABLE_value = 1;     //Enable RAM
        // end
        // // Identifies SH
        // else if (instruction[31:26] == 6'b101001) begin
        //     ID_LOAD_INSTR_value = 0;                //Deactivated because we are writing
        //     ID_SIZE_value = 2'b01;            //Reading halfword
        //     ID_MEM_DATA_SE_value = 0;         //Irrelevant
        //     ID_MEM_DATA_ENABLE_value = 1;     //Enable RAM
        // end
        // // Identifies SB
        // else if (instruction[31:26] == 6'b101000) begin
        //     ID_LOAD_INSTR_value = 0;                //Deactivated because we are writing
        //     ID_SIZE_value = 2'b00;            //Reading byte
        //     ID_MEM_DATA_SE_value = 0;         //Irrelevant
        //     ID_MEM_DATA_ENABLE_value = 1;     //Enable RAM
        // end
        // //Identifies bitwise
        // /*






        // */
        // //Arithmetic Instructions
        // // Identify ADDI
        // else if (instruction[31:26] == 6'b001000) begin
        //         ID_RT_DEST_value = 1;         //Activated
        //         ID_Shift_IMM_value = 3'b100;  //IMM16 SIGNED (READ SECOND SOURCE INSTR FROM PHASE 1)
        //         ID_ALU_OP_value = 4'b0000;    //Selected ADD
        //         ID_RF_ENABLE_value = 1;       //Activated
        // end
        // // Identify ADDIU
        // else if (instruction[31:26] == 6'b001001) begin
        //         ID_RT_DEST_value = 1;         //Activated
        //         ID_Shift_IMM_value = 3'b100;  //IMM16 SIGNED
        //         ID_ALU_OP_value = 4'b0000;    //Selected ADD
        //         ID_RF_ENABLE_value = 1;       //Activated
        // end
        // //OTHER ARITHMETIC INSTRUCTIONS GO HERE
        // /*



        // */
        // //Logic Instructions
        // else if (instruction[31:26] == 6'b000000) begin
        //     //AND
        //     if (instruction[5:0] == 100100) begin
        //         ID_ALU_OP_value = 4'b0010;    //Selected AND
        //         ID_RF_ENABLE_value = 1;       //Activated
        //     end
        //     //OR    
        //     else if (instruction[5:0] == 100101) begin
        //         ID_ALU_OP_value = 4'b0011;    //Selected OR
        //         ID_RF_ENABLE_value = 1;       //Activated
        //     end
        //     //XOR
        //     else if (instruction[5:0] == 100110) begin
        //         ID_ALU_OP_value = 4'b0100;    //Selected XOR
        //         ID_RF_ENABLE_value = 1;       //Activated
        //     end
        //     //NOR
        //     else if (instruction[5:0] == 100111) begin
        //         ID_ALU_OP_value = 4'b0101;    //Selected NOR
        //         ID_RF_ENABLE_value = 1;       //Activated
        //     end
        // end
        // // Identify ANDI
        // else if (instruction[31:26] == 6'b001100) begin
        //     ID_RT_DEST_value = 1;         //Storing in Rt
        //     ID_Shift_IMM_value = 3'b100;  //Sending signed imm16
        //     ID_ALU_OP_value = 4'b0010;    //Selected AND
        //     ID_RF_ENABLE_value = 1;       //Activated
        // end
        // // Identify ORI
        // else if (instruction[31:26] == 6'b001101) begin
        //     ID_RT_DEST_value = 1;         //Storing in Rt
        //     ID_Shift_IMM_value = 3'b100;  //Sending signed imm16
        //     ID_ALU_OP_value = 4'b0011;    //Selected AND
        //     ID_RF_ENABLE_value = 1;       //Activated
        // end
        // // Identify XORI
        // else if (instruction[31:26] == 6'b001110) begin
        //     ID_RT_DEST_value = 1;         //Storing in Rt
        //     ID_Shift_IMM_value = 3'b100;  //Sending signed imm16
        //     ID_ALU_OP_value = 4'b0100;    //Selected XORI
        //     ID_RF_ENABLE_value = 1;       //Activated
        // end
        // // Identify LUI
        // else if (instruction[31:26] == 6'b001111) begin
        //     ID_RT_DEST_value = 1;         //Storing in Rt
        //     ID_Shift_IMM_value = 3'b101;  //Sending imm16x00
        //     ID_ALU_OP_value = 4'b1100;    //Selected Selected B
        //     ID_RF_ENABLE_value = 1;       //Activated
        // end

        // // ID_RT_DEST = ID_RT_DEST_value;
        // // ID_Shift_IMM = ID_Shift_IMM_value;
        // // ID_ALU_OP = ID_ALU_OP_value;
        // // ID_LOAD_INSTR = ID_LOAD_INSTR_value;
        // // ID_RF_ENABLE = ID_RF_ENABLE_value;
        // // ID_BRANCH_ENABLE = ID_BRANCH_ENABLE_value;
        // // ID_JUMP_ENABLE = ID_JUMP_ENABLE_value;
        // // ID_R31_DEST = ID_R31_DEST_value;
        // // ID_HI_ENABLE = ID_HI_ENABLE_value;
        // // ID_LO_ENABLE = ID_LO_ENABLE_value;
        // // ID_SIZE = ID_SIZE_value;
        // // ID_MEM_DATA_SE = ID_MEM_DATA_SE_value;
        // // ID_MEM_DATA_RW = ID_MEM_DATA_RW_value;
        // // ID_MEM_DATA_ENABLE = ID_MEM_DATA_ENABLE_value;
        // // ID_PC_PLUS_EIGHT_ENABLE =  ID_PC_PLUS_EIGHT_ENABLE_value;

        // // id_signal = {ID_RT_DEST_value,                  // Bit 19
        // //             ID_Shift_IMM_value,                 // Bits [18:16]
        // //             ID_ALU_OP_value,                    // Bits [15:12]
        // //             ID_LOAD_INSTR_value,                // Bit 11
        // //             ID_RF_ENABLE_value,                 // Bit 10
        // //             ID_BRANCH_ENABLE_value,             // Bit 9
        // //             ID_JUMP_ENABLE_value,               // Bit 8
        // //             ID_R31_DEST_value,                  // Bit 7
        // //             ID_HI_ENABLE_value,                 // Bit 6
        // //             ID_LO_ENABLE_value,                 // Bit 5
        // //             ID_SIZE_value,                      // Bit [4:3]
        // //             ID_MEM_DATA_SE_value,               // Bit 2
        // //             ID_MEM_DATA_ENABLE_value,           // Bit 1
        // //             ID_PC_PLUS_EIGHT_ENABLE_value};     // Bit 0

        id_signal = { ID_ALU_op,                 // Bit [20:17]
                    ID_load_instr,               // Bit 16
                    ID_RF_enable,                // Bit 15              
                    ID_S2,                       // Bit 14
                    ID_S1,                       // Bit 13
                    ID_S0,                       // Bit 12
                    ID_branchType,               // Bit [11:9]
                    ID_Size,                     // Bit [8:7]
                    ID_E,                        // Bit 6
                    ID_SE,                       // Bit 5
                    ID_RW,                      // Bit 4
                    ID_dataMemAddressInput,      // Bit 3
                    ID_AUIPC,                    // Bit 2
                    ID_JALR,                     // Bit 1
                    ID_JAL };                    // Bit 0
    end
endmodule