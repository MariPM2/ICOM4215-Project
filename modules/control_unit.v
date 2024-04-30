module CONTROL_UNIT (
    output reg[22:0] id_signal,
    // output reg[20:0] id_signal,
    input[31:0] instruction
);
    reg[1:0] ID_source_registers; 
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
        ID_source_registers = 0;
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
        // Integer Register-Immediate Instructions:
            7'b0010011: begin
                            //ADDI:
                            if(instruction[14:12] == 3'b000) begin
                                    ID_load_instr = 0;
                                    ID_ALU_op = 4'b0010;    //Selected ADD
                                    ID_RF_enable = 1;       //Activated
                                    ID_S2 = 0;
                                    ID_S1 = 0;
                                    ID_S0 = 1;
                                    ID_source_registers = 2'b01;
                            end
                            // SLTI (WORK!!!)
                            else if(instruction[14:12] == 3'b010) begin
                                    ID_load_instr = 0;
                                    ID_ALU_op = 4'b1000;    //Selected ADD
                                    ID_RF_enable = 1;       //Activated
                                    ID_S2 = 0;
                                    ID_S1 = 0;
                                    ID_S0 = 1;
                                    ID_source_registers = 2'b01;
                            end
                            // SLTIU (WORK!!!)
                            else if(instruction[14:12] == 3'b011) begin
                                    ID_load_instr = 0;
                                    ID_ALU_op = 4'b1001;    //Selected ADD
                                    ID_RF_enable = 1;       //Activated
                                    ID_S2 = 0;
                                    ID_S1 = 0;
                                    ID_S0 = 1;
                                    ID_source_registers = 2'b01;
                            end
                            // ANDI
                            else if(instruction[14:12] == 3'b111) begin
                                    ID_load_instr = 0;
                                    ID_ALU_op = 4'b1010;    //Selected ADD
                                    ID_RF_enable = 1;       //Activated
                                    ID_S2 = 0;
                                    ID_S1 = 0;
                                    ID_S0 = 1;
                                    ID_source_registers = 2'b01;
                            end
                            // ORI
                            else if(instruction[14:12] == 3'b110) begin
                                    ID_load_instr = 0;
                                    ID_ALU_op = 4'b1011;    //Selected ADD
                                    ID_RF_enable = 1;       //Activated
                                    ID_S2 = 0;
                                    ID_S1 = 0;
                                    ID_S0 = 1;
                                    ID_source_registers = 2'b01;
                            end
                            // XORI
                            else if(instruction[14:12] == 3'b100) begin
                                    ID_load_instr = 0;
                                    ID_ALU_op = 4'b1100;    //Selected ADD
                                    ID_RF_enable = 1;       //Activated
                                    ID_S2 = 0;
                                    ID_S1 = 0;
                                    ID_S0 = 1;
                                    ID_source_registers = 2'b01;
                            end
                            // SLLI (WORK le estoy pasando el imm12 porque shamt es parte del imm12)
                            else if(instruction[14:12] == 3'b100) begin
                                    ID_load_instr = 0;
                                    ID_ALU_op = 4'b0101;    //Selected ADD
                                    ID_RF_enable = 1;       //Activated
                                    ID_S2 = 0;
                                    ID_S1 = 0;
                                    ID_S0 = 1;
                                    ID_source_registers = 2'b01;
                            end
                            // SRLI (WORK le estoy pasando el imm12 porque shamt es parte del imm12)
                            else if(instruction[14:12] == 3'b101 && instruction[31:25] == 7'b0000000) begin
                                    ID_load_instr = 0;
                                    ID_ALU_op = 4'b0110;    //Selected ADD
                                    ID_RF_enable = 1;       //Activated
                                    ID_S2 = 0;
                                    ID_S1 = 0;
                                    ID_S0 = 1;
                                    ID_source_registers = 2'b01;
                            end
                            // SRAI (WORK le estoy pasando el imm12 porque shamt es parte del imm12)
                            else if(instruction[14:12] == 3'b101 && instruction[31:25] == 7'b0100000) begin
                                    ID_load_instr = 0;
                                    ID_ALU_op = 4'b0110;    //Selected ADD
                                    ID_RF_enable = 1;       //Activated
                                    ID_S2 = 0;
                                    ID_S1 = 0;
                                    ID_S0 = 1;
                                    ID_source_registers = 2'b01;
                            end
                        end

            
        // -------------------------------------------------------------------------------------------------------------------------------
            // LUI:
            7'b0110111: begin
                            ID_S2 = 0;
                            ID_S1 = 1;
                            ID_S0 = 1;
                            ID_ALU_op = 4'b0000;    
                            ID_RF_enable = 1;       //Activated
                            ID_source_registers = 2'b00;
                        end
        // -------------------------------------------------------------------------------------------------------------------------------
            // AUIPC:
            7'b0010111: begin
                            ID_S2 = 0;
                            ID_S1 = 1;
                            ID_S0 = 1;
                            ID_ALU_op = 4'b0001;    
                            ID_RF_enable = 1;       //Activated
                            ID_source_registers = 2'b00;
                        end
        // -------------------------------------------------------------------------------------------------------------------------------
            // Arithmetic Instructions:
            7'b0110011: begin
                            // ADD:
                            if(instruction[14:12] == 3'b000 && instruction[31:25] == 7'b0000000) begin
                                ID_load_instr = 0;
                                ID_ALU_op = 4'b0010;    //Selected SUB
                                ID_RF_enable = 1;       //Activated
                                ID_S2 = 0;
                                ID_S1 = 0;
                                ID_S0 = 0;
                                ID_source_registers = 2'b10;
                            end
                            // SUB:
                            else if(instruction[14:12] == 3'b000 && instruction[31:25] == 7'b0100000) begin
                                ID_load_instr = 0;
                                ID_ALU_op = 4'b0011;    //Selected SUB
                                ID_RF_enable = 1;       //Activated
                                ID_S2 = 0;
                                ID_S1 = 0;
                                ID_S0 = 0;
                                ID_source_registers = 2'b10;
                            end
                            // SLT (WORK)
                            else if(instruction[14:12] == 3'b010) begin
                                ID_load_instr = 0;
                                ID_ALU_op = 4'b1000;    //Selected SUB
                                ID_RF_enable = 1;       //Activated
                                ID_S2 = 0;
                                ID_S1 = 0;
                                ID_S0 = 0;
                                ID_source_registers = 2'b10;
                            end
                            // SLTU (WORK)
                            else if(instruction[14:12] == 3'b011) begin
                                ID_load_instr = 0;
                                ID_ALU_op = 4'b1001;    //Selected SUB
                                ID_RF_enable = 1;       //Activated
                                ID_S2 = 0;
                                ID_S1 = 0;
                                ID_S0 = 0;
                                ID_source_registers = 2'b10;
                            end
                            // AND
                            else if(instruction[14:12] == 3'b111) begin
                                ID_load_instr = 0;
                                ID_ALU_op = 4'b1010;    //Selected SUB
                                ID_RF_enable = 1;       //Activated
                                ID_S2 = 0;
                                ID_S1 = 0;
                                ID_S0 = 0;
                                ID_source_registers = 2'b10;
                            end
                            // OR
                            else if(instruction[14:12] == 3'b110) begin
                                ID_load_instr = 0;
                                ID_ALU_op = 4'b1011;    //Selected SUB
                                ID_RF_enable = 1;       //Activated
                                ID_S2 = 0;
                                ID_S1 = 0;
                                ID_S0 = 0;
                                ID_source_registers = 2'b10;
                            end
                            // XOR
                            else if(instruction[14:12] == 3'b100) begin
                                ID_load_instr = 0;
                                ID_ALU_op = 4'b1100;    //Selected SUB
                                ID_RF_enable = 1;       //Activated
                                ID_S2 = 0;
                                ID_S1 = 0;
                                ID_S0 = 0;
                                ID_source_registers = 2'b10;
                            end
                            // SLL
                            else if(instruction[14:12] == 3'b001) begin
                                ID_load_instr = 0;
                                ID_ALU_op = 4'b0101;    //Selected SUB
                                ID_RF_enable = 1;       //Activated
                                ID_S2 = 0;
                                ID_S1 = 0;
                                ID_S0 = 0;
                                ID_source_registers = 2'b10;
                            end
                            // SRL
                            else if(instruction[14:12] == 3'b101 && instruction[31:25] == 7'b0000000) begin
                                ID_load_instr = 0;
                                ID_ALU_op = 4'b0110;    //Selected SUB
                                ID_RF_enable = 1;       //Activated
                                ID_S2 = 0;
                                ID_S1 = 0;
                                ID_S0 = 0;
                                ID_source_registers = 2'b10;
                            end
                            // SRA
                            else if(instruction[14:12] == 3'b101 && instruction[31:25] == 7'b0100000) begin
                                ID_load_instr = 0;
                                ID_ALU_op = 4'b0110;    //Selected SUB
                                ID_RF_enable = 1;       //Activated
                                ID_S2 = 0;
                                ID_S1 = 0;
                                ID_S0 = 0;
                                ID_source_registers = 2'b10;
                            end
                        end
// --------------------------------------------------------------------------------------------------------------------------
        // Load Instructions:
            7'b0000011: begin
                            // LW:
                            if(instruction[14:12] == 3'b010) begin
                                ID_load_instr = 1;          //Activated to select what is stored in ram
                                ID_RF_enable = 1;           //Activated
                                ID_Size  = 2'b00;            //Reading byte 
                                ID_SE = 0;         //Dectivated for unsigned
                                ID_E = 1;     //Enable RAM
                                ID_S2 = 0;
                                ID_S1 = 0;
                                ID_S0 = 1;
                                ID_ALU_op = 4'b0010;
                                ID_source_registers = 2'b01;
                            end
                            // LH:
                            else if(instruction[14:12] == 3'b01) begin
                                ID_load_instr = 1;          //Activated to select what is stored in ram
                                ID_RF_enable = 1;           //Activated
                                ID_Size  = 2'b00;            //Reading byte 
                                ID_SE = 1;         //Activated for signed
                                ID_E = 1;     //Enable RAM
                                ID_S2 = 0;
                                ID_S1 = 0;
                                ID_S0 = 1;
                                ID_ALU_op = 4'b0010;
                                ID_source_registers = 2'b01;
                               
                            end
                            // LHU:
                            else if(instruction[14:12] == 3'b101) begin
                                ID_load_instr = 1;          //Activated to select what is stored in ram
                                ID_RF_enable = 1;           //Activated
                                ID_Size  = 2'b00;            //Reading byte 
                                ID_SE = 0;         //Deactivated for unsigned
                                ID_E = 1;     //Enable RAM
                                ID_S2 = 0;
                                ID_S1 = 0;
                                ID_S0 = 1;
                                ID_ALU_op = 4'b0010;
                                ID_source_registers = 2'b01;
                            end
                            // LB:
                            else if(instruction[14:12] == 3'b000) begin
                                ID_load_instr = 1;          //Activated to select what is stored in ram
                                ID_RF_enable = 1;           //Activated
                                ID_Size  = 2'b00;            //Reading byte 
                                ID_SE = 1;         //Activated for signed
                                ID_E = 1;     //Enable RAM
                                ID_S2 = 0;
                                ID_S1 = 0;
                                ID_S0 = 1;
                                ID_ALU_op = 4'b0010;
                                ID_source_registers = 2'b01;
                               
                            end
                            // LBU:
                            else if(instruction[14:12] == 3'b100) begin
                                ID_load_instr = 1;          //Activated to select what is stored in ram
                                ID_RF_enable = 1;           //Activated
                                ID_Size  = 2'b00;            //Reading byte 
                                ID_SE = 0;         //Dectivated for unsigned
                                ID_E = 1;     //Enable RAM
                                ID_S2 = 0;
                                ID_S1 = 0;
                                ID_S0 = 1;
                                ID_ALU_op = 4'b0010;
                                ID_source_registers = 2'b01;
                            end
                        end
// ------------------------------------------------------------------------------------------------------------------------------
        // Store Instructions:
            7'b0100011: begin
                            // SW:
                            if(instruction[14:12] == 3'b010) begin
                                ID_load_instr = 0;                //Deactivated because we are writing
                                ID_Size = 2'b00;            //Reading byte
                                ID_SE = 0;         
                                ID_E = 1;     //Enable RAM
                                ID_RW = 1;
                                ID_S2 = 0;
                                ID_S1 = 1;
                                ID_S0 = 0;
                                ID_ALU_op = 4'b0010;
                                ID_source_registers = 2'b01;
                            end
                            // SH:
                            else if(instruction[14:12] == 3'b001) begin
                                ID_load_instr = 0;                //Deactivated because we are writing
                                ID_Size = 2'b00;            //Reading byte
                                ID_SE = 0;         
                                ID_E = 1;     //Enable RAM
                                ID_RW = 1;
                                ID_S2 = 0;
                                ID_S1 = 1;
                                ID_S0 = 0;
                                ID_ALU_op = 4'b0010;
                                ID_source_registers = 2'b01;
                            end
                            // SB:
                            else if(instruction[14:12] == 3'b000) begin
                                ID_load_instr = 0;                //Deactivated because we are writing
                                ID_Size = 2'b00;            //Reading byte
                                ID_SE = 0;         
                                ID_E = 1;     //Enable RAM
                                ID_RW = 1;
                                ID_S2 = 0;
                                ID_S1 = 1;
                                ID_S0 = 0;
                                ID_ALU_op = 4'b0010;
                                ID_source_registers = 2'b01;
                            end
                        end
// -------------------------------------------------------------------------------------------------------------------------
        // Conditional Branch Instructions:
            7'b1100011: begin
                            if(instruction[14:12] == 3'b000) begin
                                ID_ALU_op = 4'b0011;
                                ID_RF_enable = 0;                   //Activated
                                ID_branchType = 3'b010;               //Branch ID for BEQ
                                ID_source_registers = 2'b10;
                            end
                            else begin
                                    ID_ALU_op = 4'b0011;
                                    ID_RF_enable = 0; 
                                    ID_branchType = instruction[14:12]; //Branch ID for BNE, BLT, BGE, BLTU, and BGEU is funct3
                                    ID_source_registers = 2'b10;
                                end
                        end
// -------------------------------------------------------------------------------------------------------------------------------
        // Uncoditional Jump Instructions
            // JAL:
            7'b1101111: begin
                            ID_load_instr = 0;
                            ID_RF_enable = 1;
                            ID_JAL = 1;
                            ID_dataMemAddressInput = 1;
                            ID_source_registers = 2'b00;
                        end
            // JALR:
            7'b1100111: begin
                            ID_load_instr = 0;
                            ID_RF_enable = 1;
                            ID_JALR = 1;
                            ID_dataMemAddressInput = 1;
                            ID_source_registers = 2'b01;
                        end

        endcase

        id_signal = {
                    ID_source_registers,     // Bit [22:21]
                    ID_ALU_op,                 // Bit [20:17]
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

// module registerX (
//     output reg [31:0] Qs,
//     input clk, Ld, 
//     input [31:0] Ds
// );

//     reg[31:0] PW;
//     always @  (posedge clk)  
//         if(Ld) begin
//             PW <= Ds;       
//             Qs <= Ds;
//         end

// endmodule