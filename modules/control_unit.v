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
            //ADDI:
            7'b0010011: begin
                            ID_load_instr = 0;
                            ID_ALU_op = 4'b0010;    //Selected ADD
                            ID_RF_enable = 1;       //Activated
                            ID_S2 = 0;
                            ID_S1 = 0;
                            ID_S0 = 1;
                        end
            // SUB:
            7'b0110011: begin
                            ID_load_instr = 0;
                            ID_ALU_op = 4'b0011;    //Selected SUB
                            ID_RF_enable = 1;       //Activated
                            ID_S2 = 0;
                            ID_S1 = 0;
                            ID_S0 = 0;
                        end
            // SB:
            7'b0100011: begin
                            ID_load_instr = 0;                //Deactivated because we are writing
                            ID_Size = 2'b00;            //Reading byte
                            ID_SE = 0;         
                            ID_E = 1;     //Enable RAM
                            ID_RW = 1;
                            ID_S2 = 0;
                            ID_S1 = 1;
                            ID_S0 = 0;
                            ID_ALU_op = 4'b0010;
                        end
            // BGE:
            7'b1100011: begin
                        if(instruction[14:12] == 3'b000) begin
                                ID_RF_enable = 1;                   //Activated
                                ID_branchType = 3'b010;               //Activated 
                            end
                        else ID_branchType = instruction[14:12];
                        end
            // LUI:
            7'b0110111: begin
                            ID_S2 = 0;
                            ID_S1 = 1;
                            ID_S0 = 1;
                            ID_ALU_op = 4'b0000;    
                            ID_RF_enable = 1;       //Activated
                        end
            // JAL:
            7'b1101111: begin
                            ID_load_instr = 0;
                            ID_RF_enable = 1;
                            ID_JAL = 1;
                            ID_dataMemAddressInput = 1;
                        end
            // JALR:
            7'b1100111: begin
                            ID_load_instr = 0;
                            ID_RF_enable = 1;
                            ID_JALR = 1;
                            ID_dataMemAddressInput = 1;
                        end
            // LB or LBU:
            7'b0000011: begin
                            // LB:
                            if(instruction[14:12] == 3'b000) begin
                                ID_load_instr = 1;          //Activated to select what is stored in ram
                                ID_RF_enable = 1;           //Activated
                                ID_Size  = 2'b00;            //Reading byte 
                                ID_SE = 1;         //Deactivated for unsigned
                                ID_E = 1;     //Enable RAM
                                ID_S2 = 0;
                                ID_S1 = 0;
                                ID_S0 = 1;
                                ID_ALU_op = 4'b0010;
                               
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