// `timescale 1ns / 1ps

`include "../modules/pc.v"
`include "../modules/mux.v"
`include "../modules/control_unit.v"
`include "../modules/pc_adder.v"
`include "../modules/PF1_Perez_Mendez_Mariana_rom.v"
`include "../modules/pipeline_registers.v"
`include "../modules/RegisterFile.v"
`include "../modules/pa_mux.v"
`include "../modules/pb_mux.v"
`include "../modules/conc_imm12_s.v"
`include "../modules/PF1_Perez_Mendez_Mariana_ram.v"
`include "../modules/general_mux.v"
`include "../modules/pw_selector.v"
`include "../modules/condition_handler.v"
`include "../modules/logic_box.v"
`include "../modules/if_mux.v"
`include "../modules/hazard_forwarding_unit.v"

module control_unit_ppu_testbench();
/* VARIABLES RELATED TO FILE MANAGEMENT*/

    integer fi, code;
    reg[8:0] address;
    reg[7:0] data;

/* GLOBAL RESET and CLOCK */

    reg clk, reset;
    // integer cycle;

/* MISCELLANEOUS */
    reg finished1;
    reg[39:0] op_keyword;

/* REGISTERS (INPUTS AND OUTPUTS) DECLARATIONS*/

    wire[31:0] adder_out, pc_out, if_instruction_out;
    wire[31:0] id_instruction_out;
    wire[20:0] id_control_signal, id_control_signal_mux;
    wire[20:0] ex_control_signal;
    wire[20:0] mem_control_signal;
    wire[20:0] wb_control_signal;
    reg pc_e, s;  // s = nop_signal

    wire[31:0] id_pa, id_pb, id_pa_mux, id_pb_mux;

//EX Output Wires
    wire[31:0] ex_source_operand, ex_sa_selector, ex_alu;
    // wire[2:0] ex_instruction_condition;
    // wire ex_hazard_signal;

    reg Z, N, C, V;

    wire[31:0] alu_A_input;
    wire[31:0] alu_mux_output;

//Forwarding Unit
    wire[1:0] pa_selector, pb_selector;

 //EX/MEM Output Wires
    wire[31:0] mem_pb, mem_alu;
    wire[4:0] mem_rw;

//MEM Output Wires
    wire[31:0] mem_ram, mem_pw;
    wire[1:0] ex_flags;
    // wire mem_inverter;
    wire[11:0] imm12_s

//MEM/WB Output Wires
    wire[31:0] wb_pw;
    wire[4:0] wb_rw;

    reg if_id_reset, id_ex_reset;
    reg cond_hand_out;
    wire[2:0] decision_output;
    
    wire[31:0] pc_in;
    wire[31:0] id_TA, ex_TA;
    // wire[31:0] id_TA;


/* MODULE INSTANTIATIONS */

    //START IF STAGE

    PC my_pc (pc_out, adder_out, clk, 1'b1, reset);
    PC_ADDER my_pc_adder (adder_out, pc_out);

    IF_MUX my_if_mux (pc_in, ex_TA, ex_alu, id_TA, adder_out, decision_output);

    rom my_rom (if_instruction_out, pc_out[8:0]);
    
    
    //END IF STAGE
    
    PIPELINE_IF_ID my_if_id(id_instruction_out, if_instruction_out, reset, clk);
    
    //START ID STAGE
    
    CONTROL_UNIT my_ctrl_unit (id_control_signal, id_instruction_out);
    CONTROL_UNIT_MUX my_ctrl_mux (id_control_signal_mux, id_control_signal, s);

    RegisterFile my_reg_file(id_pa, id_pb, wb_pw, id_instruction_out[19:15], id_instruction_out[24:20], wb_rw, wb_control_signal[15], clk);

    PA_MUX my_pa_mux (id_pa_mux, pa_selector, ex_alu, mem_pw, wb_pw, id_pa);
    PB_MUX my_pb_mux (id_pb_mux, pb_selector, ex_alu, mem_pw, wb_pw, id_pb);

    //END ID STAGE

    PIPELINE_ID_EX my_id_ex (ex_control_signal, id_control_signal_mux, reset, clk);

    // START EX STAGE

    Concatenate_imm12_s my_imm12_s_conc (imm12_s, id_instruction_out[31:25], id_instruction_out[11:7]);
    // Concatenate_s2_s1_s0 my_si (si, id_instruction_out[14], id_instruction_out[13], id_instruction_out[12]);
    SecondOperandHandler my_second_operand (ex_second_operand, id_pb_mux, {id_instruction_out[14], id_instruction_out[13], id_instruction_out[12]} , id_instruction_out[31:20], imm12_s, id_instruction_out[31:12], ex_pc);
    GEN_MUX my_alu_A_input (alu_A_input, id_pa_mux, pc_out);
    ALU my_alu (id_pa_mux, ex_second_operand, ex_control_signal[20:17], ex_alu, Z, N, C, V);

    // HELP!!! NO ENTINDO :(
    COND_HANDLER my_condition_handler (cond_hand_out, Z, N, C, V, ex_control_signal[11:9]);

    GEN_MUX my_alu_mux (alu_mux_output, ex_alu, pc_out+4, ex_control_signal[3]);

    LOGIC_BOX my_logic_box (decision_output, if_id_reset, id_ex_reset, cond_hand_out, id_control_signal[0], mem_control_signal[1]);
    // AVERVIGUAR COMO RESET LOS PIPELINE IF/ID y ID/EX

    // END EX STAGE
    
    PIPELINE_EX_MEM my_ex_mem (mem_control_signal, ex_control_signal, reset, clk);

    // START MEM STAGE

    ram my_ram (mem_ram, mem_control_signal[6], mem_control_signal[4], mem_control_signal[5], mem_alu[8:0], alu_mux_output, mem_control_signal[8:7]);

    // END MEM STAGE
    HAZARD_FORWARDING_UNIT my_forwarding_unit (pa_selector, pb_selector, load_enable, pc_enable, nop_signal, ex_rw, mem_rw, wb_rw, id_instruction[25:21], id_instruction[20:16], ex_control_signal[11], mem_control_signal[11], wb_control_signal[11], ex_control_signal[12], mem_control_signal[12]);
    PIPELINE_MEM_WB my_mem_wb (wb_control_signal, mem_control_signal, reset, clk);
    PW_SELECTOR my_mem_mux (mem_pw, mem_alu, mem_ram, mem_control_signal[12], mem_control_signal[0]);
    // Yo creo que esto podia haber sido un gen mux

    // START WB STAGE

    // END WB STAGE

/* TESTBENCH */
    
    initial begin
        fi = $fopen("../textFiles/PF3_precharge.txt","r");
        address = 9'b0;
        while (!$feof(fi)) begin
            code = $fscanf(fi,"%b",data);
            my_rom.Mem[address] = data;
            address = address + 1'b1;
        end
        $fclose(fi);
        address = 9'b0;
        finished1 = 1;
    end

    initial begin
        wait(finished1);
        reset = 1;
        clk = 0; // Clock set to 0
        s = 0;
        forever #2 clk = ~clk; // Forever clock
    end

    initial fork
        #3 reset = 0;
        #40 s = 1;
        #48 $finish;    // Originally 48
    join           
    // initial begin

    // end
        
    always @(posedge clk) begin
        
        case (id_instruction_out[6:0])
        // Integer Register-Immediate Instructions:
            7'b0010011: begin
                            //ADDI:
                            if(id_instruction_out[14:12] == 3'b000) begin
                                    op_keyword = "ADDI";
                            end
                            // SLTI:
                            else if(id_instruction_out[14:12] == 3'b010) begin
                                    op_keyword = "SLTI";
                            end
                            // SLTIU:
                            else if(id_instruction_out[14:12] == 3'b011) begin
                                    op_keyword = "SLTIU";
                            end
                            // ANDI:
                            else if(id_instruction_out[14:12] == 3'b111) begin
                                    op_keyword = "ANDI";
                            end
                            // ORI:
                            else if(id_instruction_out[14:12] == 3'b110) begin
                                    op_keyword = "ORI";
                            end
                            // XORI:
                            else if(id_instruction_out[14:12] == 3'b100) begin
                                    op_keyword = "XORI";
                            end
                            // SLLI:
                            else if(id_instruction_out[14:12] == 3'b100) begin
                                    op_keyword = "SLLI";
                            end
                            // SRLI:
                            else if(id_instruction_out[14:12] == 3'b101 && id_instruction_out[31:25] == 7'b0000000) begin
                                    op_keyword = "SRLI";
                            end
                            // SRAI:
                            else if(id_instruction_out[14:12] == 3'b101 && id_instruction_out[31:25] == 7'b0100000) begin
                                    op_keyword = "SRAI";
                            end
                        end
        // -------------------------------------------------------------------------------------------------------------------------------
            // LUI:
            7'b0110111: op_keyword = "LUI";
        // -------------------------------------------------------------------------------------------------------------------------------
            // AUIPC:
            7'b0010111: op_keyword = "AUIPC";
        // -------------------------------------------------------------------------------------------------------------------------------
            // Arithmetic Instructions:
            7'b0110011: begin
                            // ADD:
                            if(id_instruction_out[14:12] == 3'b000 && id_instruction_out[31:25] == 7'b0000000) begin
                                op_keyword = "ADD";
                            end
                            // SUB:
                            else if(id_instruction_out[14:12] == 3'b000 && id_instruction_out[31:25] == 7'b0100000) begin
                                op_keyword = "SUB";
                            end
                            // SLT:
                            else if(id_instruction_out[14:12] == 3'b010) begin
                                op_keyword = "SLT";
                            end
                            // SLTU:
                            else if(id_instruction_out[14:12] == 3'b011) begin
                                op_keyword = "SLTU";
                            end
                            // AND
                            else if(id_instruction_out[14:12] == 3'b111) begin
                                op_keyword = "AND";
                            end
                            // OR
                            else if(id_instruction_out[14:12] == 3'b110) begin
                                op_keyword = "OR";
                            end
                            // XOR
                            else if(id_instruction_out[14:12] == 3'b100) begin
                                op_keyword = "XOR";
                            end
                            // SLL
                            else if(id_instruction_out[14:12] == 3'b001) begin
                                op_keyword = "SLL";
                            end
                            // SRL
                            else if(id_instruction_out[14:12] == 3'b101 && id_instruction_out[31:25] == 7'b0000000) begin
                                op_keyword = "SRL";
                            end
                            // SRA
                            else if(id_instruction_out[14:12] == 3'b101 && id_instruction_out[31:25] == 7'b0100000) begin
                                op_keyword = "SRA";
                            end
                        end
// --------------------------------------------------------------------------------------------------------------------------
        // Load Instructions:
            7'b0000011: begin
                            // LW:
                            if(id_instruction_out[14:12] == 3'b010) begin
                                op_keyword = "LW";
                            end
                            // LH:
                            else if(id_instruction_out[14:12] == 3'b01) begin
                                op_keyword = "LH";
                            end
                            // LHU:
                            else if(id_instruction_out[14:12] == 3'b101) begin
                                op_keyword = "LHU";
                            end
                            // LB:
                            else if(id_instruction_out[14:12] == 3'b000) begin
                                op_keyword = "LB";
                            end
                            // LBU:
                            else if(id_instruction_out[14:12] == 3'b100) begin
                                op_keyword = "LBU";
                            end
                        end
// ------------------------------------------------------------------------------------------------------------------------------
        // Store Instructions:
            7'b0100011: begin
                            // SW:
                            if(id_instruction_out[14:12] == 3'b010) begin
                                op_keyword = "SW";
                            end
                            // SH:
                            else if(id_instruction_out[14:12] == 3'b001) begin
                                op_keyword = "SH";
                            end
                            // SB:
                            else if(id_instruction_out[14:12] == 3'b000) begin
                                op_keyword =  "SB";
                            end
                        end
// -------------------------------------------------------------------------------------------------------------------------
        // Conditional Branch Instructions:
            7'b1100011: begin
                            if(id_instruction_out[14:12] == 3'b000) begin
                                op_keyword = "BEQ";
                            end
                            else if(id_instruction_out[14:12] == 3'b001) begin
                                op_keyword = "BNE";
                            end
                            else if(id_instruction_out[14:12] == 3'b100) begin
                                op_keyword = "BLT";
                            end
                            else if(id_instruction_out[14:12] == 3'b101) begin
                                op_keyword = "BGE";
                            end
                            else if(id_instruction_out[14:12] == 3'b110) begin
                                op_keyword = "BLTU";
                            end
                            else if(id_instruction_out[14:12] == 3'b111) begin
                                op_keyword = "BGEU";
                            end

                        end
// -------------------------------------------------------------------------------------------------------------------------------
        // Uncoditional Jump Instructions
            // JAL:
            7'b1101111: op_keyword = "JAL";
            // JALR:
            7'b1100111: op_keyword = "JALR";

            default: op_keyword = "NOP";

        endcase

        initial begin
        $monitor ("PC: %d, R1: %d, R3: %d, R4: %d, R5: %d, R8: %d, R10: %d, R11: %d, R12: %d", pc_out, my_reg_file.Q1, my_reg_file.Q3, my_reg_file.Q4, my_reg_file.Q5, my_reg_file.Q8, my_reg_file.Q10, my_reg_file.Q11, my_reg_file.Q12);
        end
            // Nuestros:
            // $display("\tControl Unit Signals (ID STAGE):\n\t\tID_ALU_op = %b,\n \t\tID_load_instr = %b,\n \t\tID_RF_enable = %b,\n \t\tID_S2 = %b,\n \t\tID_S1 = %b,\n  \t\tID_S0 = %b,\n  \t\tID_branchType = %b,\n \t\tID_Size = %b,\n \t\tID_E = %b,\n \t\tID_SE = %b,\n \t\tID_R/W = %b,\n \t\tID_dataMemAddressInput = %b,\n \t\tID_AUIPC = %b,\n \t\tID_JALR = %b,\n \t\tID_JAL = %b,\n", id_control_signal_mux[20:17], id_control_signal_mux[16], id_control_signal_mux[15], id_control_signal_mux[14], id_control_signal_mux[13], id_control_signal_mux[12], id_control_signal_mux[11:9], id_control_signal_mux[8:7], id_control_signal_mux[6], id_control_signal_mux[5], id_control_signal_mux[4], id_control_signal_mux[3], id_control_signal_mux[2], id_control_signal_mux[1], id_control_signal_mux[0]);
            // $display("\tControl Unit Signals (EX STAGE):\n\t\tEX_ALU_op = %b,\n \t\tEX_load_instr = %b,\n \t\tEX_RF_enable = %b,\n \t\tEX_S2 = %b,\n \t\tEX_S1 = %b,\n  \t\tEX_S0 = %b,\n  \t\tEX_branchType = %b,\n \t\tEX_Size = %b,\n \t\tID_E = %b,\n \t\tEX_SE = %b,\n \t\tEX_R/W = %b,\n \t\tEX_dataMemAddressInput = %b,\n \t\tEX_AUIPC = %b,\n \t\tEX_JALR = %b,\n \t\tEX_JAL = %b,\n", ex_control_signal[20:17], ex_control_signal[16], ex_control_signal[15], ex_control_signal[14], ex_control_signal[13], ex_control_signal[12], ex_control_signal[11:9], ex_control_signal[8:7], ex_control_signal[6], ex_control_signal[5], ex_control_signal[4], ex_control_signal[3], ex_control_signal[2], ex_control_signal[1], ex_control_signal[0]);
            // $display("\tControl Unit Signals (MEM STAGE)\n\t\tMEM_ALU_op = %b,\n \t\tMEM_load_instr = %b,\n \t\tMEM_RF_enable = %b,\n \t\tMEM_S2 = %b,\n \t\tMEM_S1 = %b,\n  \t\tMEM_S0 = %b,\n  \t\tMEM_branchType = %b,\n \t\tMEM_Size = %b,\n \t\tMEM_E = %b,\n \t\tMEM_SE = %b,\n \t\tMEM_R/W = %b,\n \t\tMEM_dataMemAddressInput = %b,\n \t\tMEM_AUIPC = %b,\n \t\tMEM_JALR = %b,\n \t\tMEM_JAL = %b,\n", mem_control_signal[20:17], mem_control_signal[16], mem_control_signal[15], mem_control_signal[14], mem_control_signal[3], mem_control_signal[12], mem_control_signal[11:9], mem_control_signal[8:7], mem_control_signal[6], mem_control_signal[5], mem_control_signal[4], mem_control_signal[3], mem_control_signal[2], mem_control_signal[1], mem_control_signal[0]);           
            // $display("\tControl Unit Signals (WB STAGE):\n\t\tWB_ALU_op = %b,\n \t\tWB_load_instr = %b,\n \t\tWB_RF_enable = %b,\n \t\tWB_S2 = %b,\n \t\tWB_S1 = %b,\n  \t\tWB_S0 = %b,\n  \t\tWB_branchType = %b,\n \t\tWB_Size = %b,\n \t\tWB_E = %b,\n \t\tWB_SE = %b,\n \t\tWB_R/W = %b,\n \t\tWB_dataMemAddressInput = %b,\n \t\tWB_AUIPC = %b,\n \t\tWB_JALR = %b,\n \t\tWB_JAL = %b,\n", wb_control_signal[20:17], wb_control_signal[16], wb_control_signal[15], wb_control_signal[14], wb_control_signal[13], wb_control_signal[12], wb_control_signal[11:9], wb_control_signal[8:7], wb_control_signal[6], wb_control_signal[5], wb_control_signal[4], wb_control_signal[3], wb_control_signal[2], wb_control_signal[1], wb_control_signal[0]);


            $display("\nKeyword: %s", op_keyword);
            $display("PC: %d", pc_out);
            $display("\n Control signal | ID stage | EX stage | MEM stage | WB stage ");
            $display("----------------|----------|----------|-----------|----------");
            $display("\tALU_op      | %04b     | %04b     | %04b      | %04b     ", id_control_signal_mux[20:17], ex_control_signal[20:17], mem_control_signal[20:17], wb_control_signal[20:17]);
            $display("\tload_instr  | %d        | %d        | %d         | %d        ", id_control_signal_mux[16], ex_control_signal[16], mem_control_signal[16], wb_control_signal[16]);
            $display("\tRF_enable   | %d        | %d        | %d         | %d        ", id_control_signal_mux[15], ex_control_signal[15], mem_control_signal[15], wb_control_signal[15]);
            $display("\tS2          | %d        | %d        | %d         | %d        ", id_control_signal_mux[14], ex_control_signal[14], mem_control_signal[14], wb_control_signal[14]);
            $display("\tS1          | %d        | %d        | %d         | %d        ", id_control_signal_mux[13], ex_control_signal[13], mem_control_signal[13], wb_control_signal[13]);
            $display("\tS0          | %d        | %d        | %d         | %d        ", id_control_signal_mux[12], ex_control_signal[12], mem_control_signal[12], wb_control_signal[12]);
            $display("\tbranchType  | %03b      | %03b      | %03b       | %03b      ", id_control_signal_mux[11:9], ex_control_signal[11:9], mem_control_signal[11:9], wb_control_signal[11:9]);
            $display("\tSize        | %02b       | %02b       | %02b        | %02b       ", id_control_signal_mux[8:7], ex_control_signal[8:7], mem_control_signal[8:7], wb_control_signal[8:7]);
            $display("\tE           | %d        | %d        | %d         | %d        ", id_control_signal_mux[6], ex_control_signal[6], mem_control_signal[6], wb_control_signal[6]);
            $display("\tSE          | %d        | %d        | %d         | %d        ", id_control_signal_mux[5], ex_control_signal[5], mem_control_signal[5], wb_control_signal[5]);
            $display("\tR/W         | %d        | %d        | %d         | %d        ", id_control_signal_mux[4], ex_control_signal[4], mem_control_signal[4], wb_control_signal[4]);
            $display("\tdataMemAddr | %d        | %d        | %d         | %d        ", id_control_signal_mux[3], ex_control_signal[3], mem_control_signal[3], wb_control_signal[3]);
            $display("\tAUIPC       | %d        | %d        | %d         | %d        ", id_control_signal_mux[2], ex_control_signal[2], mem_control_signal[2], wb_control_signal[2]);
            $display("\tJALR        | %d        | %d        | %d         | %d        ", id_control_signal_mux[1], ex_control_signal[1], mem_control_signal[1], wb_control_signal[1]);
            $display("\tJAL         | %d        | %d        | %d         | %d        ", id_control_signal_mux[0], ex_control_signal[0], mem_control_signal[0], wb_control_signal[0]);
    end
endmodule