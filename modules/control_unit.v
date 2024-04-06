module CONTROL_UNIT (
    // output reg ID_RT_DEST,
    // output reg[2:0] ID_Shift_IMM,
    // output reg[3:0] ID_ALU_OP,
    // output reg ID_LOAD_INSTR,
    // output reg ID_RF_ENABLE,
    // output reg ID_BRANCH_ENABLE,
    // output reg ID_JUMP_ENABLE,
    // output reg ID_R31_DEST,
    // output reg ID_HI_ENABLE,
    // output reg ID_LO_ENABLE,
    // output reg[1:0] ID_SIZE,
    // output reg ID_MEM_DATA_SE,
    // output reg ID_MEM_DATA_RW,
    // output reg ID_MEM_DATA_ENABLE,
    // output reg ID_PC_PLUS_EIGHT_ENABLE,
    output reg[20:0] id_signal,
    input[31:0] instruction
);

    // Base values
    reg ID_RT_DEST_value;
    reg[2:0] ID_Shift_IMM_value;
    reg[3:0] ID_ALU_OP_value;
    reg ID_LOAD_INSTR_value;
    reg ID_RF_ENABLE_value;
    reg ID_BRANCH_ENABLE_value;
    reg ID_JUMP_ENABLE_value;
    reg ID_ADDRESS_26_value;      //Added for phase 4
    reg ID_R31_DEST_value;
    reg ID_HI_ENABLE_value;
    reg ID_LO_ENABLE_value;
    reg[1:0] ID_SIZE_value;
    reg ID_MEM_DATA_SE_value;
    reg ID_MEM_DATA_RW_value;
    reg ID_MEM_DATA_ENABLE_value;
    reg ID_PC_PLUS_EIGHT_ENABLE_value;

    always@(instruction) begin

        ID_RT_DEST_value = 0;
        ID_Shift_IMM_value = 0;
        ID_ALU_OP_value = 0;
        ID_LOAD_INSTR_value = 0;
        ID_RF_ENABLE_value = 0;
        ID_BRANCH_ENABLE_value = 0;
        ID_JUMP_ENABLE_value = 0;
        ID_ADDRESS_26_value = 0;
        ID_R31_DEST_value = 0;
        ID_HI_ENABLE_value = 0;
        ID_LO_ENABLE_value = 0;
        ID_SIZE_value = 0;
        ID_MEM_DATA_SE_value = 0;
        ID_MEM_DATA_RW_value = 0;
        ID_MEM_DATA_ENABLE_value = 0;
        ID_PC_PLUS_EIGHT_ENABLE_value = 0;

        // Identify J
        if (instruction[31:26] == 6'b000010) begin
            ID_JUMP_ENABLE_value = 1;     //Activated
            ID_ADDRESS_26_value = 1;

        end
        // Identify JAL
        else if (instruction[31:26] == 6'b000011) begin
            ID_LOAD_INSTR_value = 0;
            ID_RF_ENABLE_value = 1;               //Activated
            ID_BRANCH_ENABLE_value = 0;           //Deactivated because we want address26 for PC = TA
            ID_JUMP_ENABLE_value = 1;             //Activated
            ID_R31_DEST_value = 1;                //Activated since r31 is the destination
            ID_PC_PLUS_EIGHT_ENABLE_value = 1;    //Activated because PC+8 will be stored there
            ID_ADDRESS_26_value = 1;
        end
        // Identify JALR, JR, ADD, ADUU, SUB, SUBU
        else if (instruction[31:26] == 6'b000000) begin
            // Identify JR (opcode in IF/ID register determines PC=rs in separate mux)
            if (instruction[5:0] == 6'b001000) begin
                ID_JUMP_ENABLE_value = 1;             //Activated
            end
            // Identify JALR (opcode in IF/ID register determines PC=rs in separate mux)
            else if (instruction[5:0] == 6'b001001) begin
                ID_JUMP_ENABLE_value = 1;             //Activated
                ID_PC_PLUS_EIGHT_ENABLE_value = 1;    //Activated because PC+8 will be stored there
            end
            // Identify ADD
            else if (instruction[5:0] == 6'b100000) begin
                ID_ALU_OP_value = 4'b0000;    //Selected ADD
                ID_RF_ENABLE_value = 1;       //Activated
            end
            // Identify ADDU
            else if (instruction[5:0] == 6'b100001) begin
                ID_ALU_OP_value = 4'b0000;    //Selected ADD
                ID_RF_ENABLE_value = 1;       //Activated
            end
            // Identify SUB
            else if (instruction[5:0] == 6'b100010) begin
                ID_ALU_OP_value = 4'b0001;    //Selected SUB
                ID_RF_ENABLE_value = 1;       //Activated
            end
            // Identify SUBU
            else if (instruction[5:0] == 6'b100011) begin
                ID_ALU_OP_value = 4'b0001;    //Selected SUB
                ID_RF_ENABLE_value = 1;       //Activated
            end
        end
        //Identify BGEZAL, BLTZAL
        else if (instruction[31:26] == 6'b000001 && (instruction[20:16 == 5'b10001] || instruction[20:16] == 5'b10000)) begin
            ID_ALU_OP_value = 4'b1010;                //Selected A
            ID_RF_ENABLE_value = 1;                   //Activated
            ID_BRANCH_ENABLE_value = 1;               //Activated
            ID_R31_DEST_value = 1;                    //Activated
            ID_PC_PLUS_EIGHT_ENABLE_value = 1;        //Activated
        end
        else if (instruction[31:26] == 6'b000001 && (instruction[20:16] == 5'b00001 || instruction[20:16] == 5'b10001 || instruction[20:16] == 5'b00000)) begin
            ID_ALU_OP_value = 4'b1010;                //Selected A
            ID_RF_ENABLE_value = 1;                   //Activated
            ID_BRANCH_ENABLE_value = 1;               //Activated
            ID_PC_PLUS_EIGHT_ENABLE_value = 1;        //Activated
        end
        // Identifies other branches
        else if ((instruction[31:26] == 6'b000100) || (instruction[31:26] == 6'b000001) || (instruction[31:26] == 6'b000111) || (instruction[31:26] == 6'b000110)) begin
            ID_ALU_OP_value = 4'b1010;                //Selected A
            ID_BRANCH_ENABLE_value = 1;               //Activated
        end
        // BNE
        else if (instruction[31:26] == 6'b000101) begin
            ID_ALU_OP_value = 4'b1011;                //Selected A
            ID_BRANCH_ENABLE_value = 1;               //Activated
        end
        // Identifies move instructions
        // else if (instruction[31:26] == 6'b000000) begin
        //     //Identifies MFHI
        //     if (instruction[5:0] == 6'010000) begin
        //         ID_ALU_OP_value = 4'b1011;
        //         ID_Shift_IMM_value = 3'b001;
        //     end
        //     //Identifies MFLO
        //     else if (instruction[5:0] == 6'010010) begin
        //         ID_ALU_OP_value = 4'b1011;
        //         ID_Shift_IMM_value = 3'b010;
        //     end
        //     else if (instruction[5:0] == 6'001011) begin
                
        //     end
        //     else if (instruction[5:0] == 6'001010) begin
                
        //     end
        //     else if (instruction[5:0] == 6'010001) begin
                
        //     end
        //     else if (instruction[5:0] == 6'010011) begin
                
        //     end
        // end
        // Identifies LW
        else if (instruction[31:26] == 6'b100011) begin
            ID_Shift_IMM_value = 3'b100;      //Both are for the address
            ID_ALU_OP_value = 4'b0000;        //Shift sends imm16 and alu adds it to rs

            ID_LOAD_INSTR_value = 1'b1;          //Activated to select what is stored in ram
            ID_RT_DEST_value = 1'b1;             //Activated to store in rt
            ID_RF_ENABLE_value = 1'b1;           //Activated
            ID_SIZE_value = 2'b10;            //Reading word
            ID_MEM_DATA_SE_value = 1'b0;         //Deactivated for unsigned
            ID_MEM_DATA_ENABLE_value = 1'b1;     //Enable RAM
        end
        // Identifies LH
        else if (instruction[31:26] == 6'b100001) begin
            ID_Shift_IMM_value = 3'b100;      //Both are for the address
            ID_ALU_OP_value = 4'b0000;        //Shift sends imm16 and alu adds it to rs

            ID_LOAD_INSTR_value = 1'b1;          //Activated to select what is stored in ram
            ID_RT_DEST_value = 1'b1;             //Activated to store in rt
            ID_RF_ENABLE_value = 1'b1;           //Activated
            ID_SIZE_value = 2'b01;            //Reading halfword
            ID_MEM_DATA_SE_value = 1'b0;         //Deactivated for unsigned
            ID_MEM_DATA_ENABLE_value = 1'b1;     //Enable RAM
        end
        // Identifies LHU
        else if (instruction[31:26] == 6'b100101) begin
            ID_Shift_IMM_value = 3'b100;      //Both are for the address
            ID_ALU_OP_value = 4'b0000;        //Shift sends imm16 and alu adds it to rs

            ID_LOAD_INSTR_value = 1'b1;          //Activated to select what is stored in ram
            ID_RT_DEST_value = 1'b1;             //Activated to store in rt
            ID_RF_ENABLE_value = 1'b1;           //Activated
            ID_SIZE_value = 2'b01;            //Reading halfword
            //ID_MEM_DATA_SE_value = 1;       //Activated for signs
            ID_MEM_DATA_ENABLE_value = 1'b1;     //Enable RAM
        end
        // Identifies LB
        else if (instruction[31:26] == 6'b100000) begin
            ID_Shift_IMM_value = 3'b100;      //Both are for the address
            ID_ALU_OP_value = 4'b0000;        //Shift sends imm16 and alu adds it to rs

            ID_LOAD_INSTR_value = 1'b1;          //Activated to select what is stored in ram
            ID_RT_DEST_value = 1'b1;             //Activated to store in rt
            ID_RF_ENABLE_value = 1'b1;           //Activated
            ID_SIZE_value = 2'b00;            //Reading byte
            ID_MEM_DATA_SE_value = 1'b0;         //Deactivated for unsigned
            ID_MEM_DATA_ENABLE_value = 1'b1;     //Enable RAM
            ID_PC_PLUS_EIGHT_ENABLE_value = 1'b0;
        end
        // Identifies LBU
        else if (instruction[31:26] == 6'b100100) begin
            ID_Shift_IMM_value = 3'b100;      //Both are for the address
            ID_ALU_OP_value = 4'b0000;        //Shift sends imm16 and alu adds it to rs

            ID_LOAD_INSTR_value = 1'b1;          //Activated to select what is stored in ram
            ID_RT_DEST_value = 1'b1;             //Activated to store in rt
            ID_RF_ENABLE_value = 1'b1;           //Activated
            ID_SIZE_value = 2'b00;            //Reading byte
            //ID_MEM_DATA_SE_value = 1;         //Activated for signs
            ID_MEM_DATA_ENABLE_value = 1'b1;     //Enable RAM
            ID_PC_PLUS_EIGHT_ENABLE_value = 1'b0;
        end
        // Identifies SD
        else if (instruction[31:26] == 6'b111111) begin
            ID_Shift_IMM_value = 3'b100;      //Both are for the address
            ID_ALU_OP_value = 4'b0000;        //Shift sends imm16 and alu adds it to rs

            ID_LOAD_INSTR_value = 0;          //Deactivated because we are writing
            ID_SIZE_value = 2'b11;            //Reading SOMETHING NOT DISCLOSED
            ID_MEM_DATA_SE_value = 0;         //Irrelevant
            ID_MEM_DATA_ENABLE_value = 1'b1;     //Enable RAM
        end
        // Identifies SW
        else if (instruction[31:26] == 6'b101011) begin
            ID_Shift_IMM_value = 3'b100;      //Both are for the address
            ID_ALU_OP_value = 4'b0000;        //Shift sends imm16 and alu adds it to rs

            ID_LOAD_INSTR_value = 1'b0;          //Deactivated because we are writing
            ID_SIZE_value = 2'b10;            //Reading word
            ID_MEM_DATA_SE_value = 1'b0;         //Irrelevant
            ID_MEM_DATA_ENABLE_value = 1'b1;     //Enable RAM
        end
        // Identifies SH
        else if (instruction[31:26] == 6'b101001) begin
            ID_Shift_IMM_value = 3'b100;      //Both are for the address
            ID_ALU_OP_value = 4'b0000;        //Shift sends imm16 and alu adds it to rs

            ID_LOAD_INSTR_value = 1'b0;          //Deactivated because we are writing
            ID_SIZE_value = 2'b01;            //Reading halfword
            ID_MEM_DATA_SE_value = 1'b0;         //Irrelevant
            ID_MEM_DATA_ENABLE_value = 1'b1;     //Enable RAM
        end
        // Identifies SB
        else if (instruction[31:26] == 6'b101000) begin
            ID_Shift_IMM_value = 3'b100;      //Both are for the address
            ID_ALU_OP_value = 4'b0000;        //Shift sends imm16 and alu adds it to rs

            ID_LOAD_INSTR_value = 1'b0;          //Deactivated because we are writing
            ID_SIZE_value = 2'b00;            //Reading byte
            ID_MEM_DATA_SE_value = 1'b0;         //Irrelevant
            ID_MEM_DATA_ENABLE_value = 1'b1;     //Enable RAM
        end
        //Identifies bitwise
        /*






        */
        //Arithmetic Instructions
        // Identify ADDI
        else if (instruction[31:26] == 6'b001000) begin
                ID_RT_DEST_value = 1'b1;         //Activated
                ID_Shift_IMM_value = 3'b100;  //IMM16 SIGNED (READ SECOND SOURCE INSTR FROM PHASE 1)
                ID_ALU_OP_value = 4'b0000;    //Selected ADD
                ID_RF_ENABLE_value = 1'b1;       //Activated
        end
        // Identify ADDIU
        else if (instruction[31:26] == 6'b001001) begin
                ID_RT_DEST_value = 1'b1;         //Activated
                ID_Shift_IMM_value = 3'b100;  //IMM16 SIGNED
                ID_ALU_OP_value = 4'b0000;    //Selected ADD
                ID_RF_ENABLE_value = 1'b1;       //Activated
        end
        //OTHER ARITHMETIC INSTRUCTIONS GO HERE
        // else if (instruction[31:26] == 6'b000000) begin
        //     //SLL
        //     if (instruction[5:0] == 6'b000000) begin
        //         ID_ALU_OP_value = 4'b0110;    //Selected shift left logical
                
        //     end
        //     //SLLV    
        //     else if (instruction[5:0] == 6'b000100) begin
        //         ID_ALU_OP_value = 4'b0110;    //Selected shift left logical
                
        //     end
        //     //SRA
        //     else if (instruction[5:0] == 6'b000011) begin
        //         ID_ALU_OP_value = 4'b0111;    //Selected shift right logical
                
        //     end
        //     //SRAV
        //     else if (instruction[5:0] == 6'b000111) begin
        //         ID_ALU_OP_value = 4'b0111;    //Selected 
                
        //     end
        //     //SRL
        //     else if (instruction[5:0] == 6'b000010) begin
        //         ID_ALU_OP_value = 4'b0000;    //Selected 
                
        //     end
        //     //SRLV
        //     else if (instruction[5:0] == 6'b000110) begin
        //         ID_ALU_OP_value = 4'b0000;    //Selected
                
        //     end
        // end
        //Logic Instructions
        else if (instruction[31:26] == 6'b000000) begin
            //AND
            if (instruction[5:0] == 100100) begin
                ID_ALU_OP_value = 4'b0010;    //Selected AND
                ID_RF_ENABLE_value = 1'b1;       //Activated
            end
            //OR    
            else if (instruction[5:0] == 100101) begin
                ID_ALU_OP_value = 4'b0011;    //Selected OR
                ID_RF_ENABLE_value = 1'b1;       //Activated
            end
            //XOR
            else if (instruction[5:0] == 100110) begin
                ID_ALU_OP_value = 4'b0100;    //Selected XOR
                ID_RF_ENABLE_value = 1'b1;       //Activated
            end
            //NOR
            else if (instruction[5:0] == 100111) begin
                ID_ALU_OP_value = 4'b0101;    //Selected NOR
                ID_RF_ENABLE_value = 1'b1;       //Activated
            end
        end
        // Identify ANDI
        else if (instruction[31:26] == 6'b001100) begin
            ID_RT_DEST_value = 1'b1;         //Storing in Rt
            ID_Shift_IMM_value = 3'b100;  //Sending signed imm16
            ID_ALU_OP_value = 4'b0010;    //Selected AND
            ID_RF_ENABLE_value = 1'b1;       //Activated
        end
        // Identify ORI
        else if (instruction[31:26] == 6'b001101) begin
            ID_RT_DEST_value = 1'b1;         //Storing in Rt
            ID_Shift_IMM_value = 3'b100;  //Sending signed imm16
            ID_ALU_OP_value = 4'b0011;    //Selected AND
            ID_RF_ENABLE_value = 1'b1;       //Activated
        end
        // Identify XORI
        else if (instruction[31:26] == 6'b001110) begin
            ID_RT_DEST_value = 1'b1;         //Storing in Rt
            ID_Shift_IMM_value = 3'b100;  //Sending signed imm16
            ID_ALU_OP_value = 4'b0100;    //Selected XORI
            ID_RF_ENABLE_value = 1'b1;       //Activated
        end
        // Identify LUI
        else if (instruction[31:26] == 6'b001111) begin
            ID_RT_DEST_value = 1'b1;         //Storing in Rt
            ID_Shift_IMM_value = 3'b101;  //Sending imm16x00
            ID_ALU_OP_value = 4'b1100;    //Selected Selected B
            ID_RF_ENABLE_value = 1'b1;       //Activated
        end

        // ID_RT_DEST = ID_RT_DEST_value;
        // ID_Shift_IMM = ID_Shift_IMM_value;
        // ID_ALU_OP = ID_ALU_OP_value;
        // ID_LOAD_INSTR = ID_LOAD_INSTR_value;
        // ID_RF_ENABLE = ID_RF_ENABLE_value;
        // ID_BRANCH_ENABLE = ID_BRANCH_ENABLE_value;
        // ID_JUMP_ENABLE = ID_JUMP_ENABLE_value;
        // ID_R31_DEST = ID_R31_DEST_value;
        // ID_HI_ENABLE = ID_HI_ENABLE_value;
        // ID_LO_ENABLE = ID_LO_ENABLE_value;
        // ID_SIZE = ID_SIZE_value;
        // ID_MEM_DATA_SE = ID_MEM_DATA_SE_value;
        // ID_MEM_DATA_RW = ID_MEM_DATA_RW_value;
        // ID_MEM_DATA_ENABLE = ID_MEM_DATA_ENABLE_value;
        // ID_PC_PLUS_EIGHT_ENABLE =  ID_PC_PLUS_EIGHT_ENABLE_value;

        id_signal <= {ID_RT_DEST_value,                  // Bit 20
                    ID_Shift_IMM_value,                 // Bits [19:17]
                    ID_ALU_OP_value,                    // Bits [16:13]
                    ID_LOAD_INSTR_value,                // Bit 12
                    ID_RF_ENABLE_value,                 // Bit 11
                    ID_BRANCH_ENABLE_value,             // Bit 10
                    ID_JUMP_ENABLE_value,               // Bit 9
                    ID_ADDRESS_26_value,                // Bit 8
                    ID_R31_DEST_value,                  // Bit 7
                    ID_HI_ENABLE_value,                 // Bit 6
                    ID_LO_ENABLE_value,                 // Bit 5
                    ID_SIZE_value,                      // Bit [4:3]
                    ID_MEM_DATA_SE_value,               // Bit 2
                    ID_MEM_DATA_ENABLE_value,           // Bit 1
                    ID_PC_PLUS_EIGHT_ENABLE_value};     // Bit 0
    end
endmodule