`timescale 1ns / 1ps

// Includes
`include "../modules/adder.v"
// `include "../modules/address26_four_se.v"
// `include "../modules/alu.v"
`include "../modules/PF1_Rodriguez_Green_Diego_alu.v"
`include "../modules/condition_handler.v"
`include "../modules/mux.v" //Verify
`include "../modules/control_unit.v"   //Verify
`include "../modules/destination_mux.v"  //No se si es neecessary
`include "../modules/general_mux.v"
`include "../modules/hazard_forwarding_unit.v"
// `include "modules/hi.v"
// `include "modules/imm16_four_se.v"
`include "../modules/instruction_condition.v"
// `include "modules/inverter.v"  //No se si es neecessary
// `include "modules/jump_or_branch_mux.v"
// `include "modules/lo.v"
// `include "modules/npc.v"
`include "../modules/pa_mux.v"
`include "../modules/pb_mux.v"
`include "../modules/pc_adder.v"
`include "../modules/pc.v"
`include "../modules/pipeline_registers_new.v"
`include "../modules/pw_selector.v"
`include "../modules/PF1_Perez_Mendez_Mariana_ram.v"
// `include "../modules/ram512x8.v"
`include "../modules/RegisterFile.v"
`include "../modules/PF1_Perez_Mendez_Mariana_rom.v"
// `include "../modules/rom512x8.v"
`include "../modules/sa_selector.v"
`include "../modules/PF1_Rodriguez_Green_Diego_secondoperandhandler.v"
// `include "../modules/sourceoperand2handler.v"
// `include "../modules/ta_or_rs.v" // No se
`include "../modules/xor.v" // No se

module MIPS_TB ();

    /* VARIABLES RELATED TO FILE MANAGEMENT*/
    integer fi, code;
    reg[8:0] address;
    reg[7:0] data;

    // Miscellanous
    reg[39:0] op_keyword;

    /* GLOBAL RESET and CLOCK */
    reg clk, reset;
    reg finished1;

    // Control Unit and Contro Unit Mux Outputs
    wire[20:0] control_signal, id_control_signal, ex_control_signal, mem_control_signal, wb_control_signal;

    //Forwarding Unit
    wire[1:0] pa_selector, pb_selector;
    wire nop_signal, pc_enable, load_enable;

    //IF Output Wires
    wire[31:0] if_pc, if_adder, if_mux, if_instruction;
    wire if_xor;

    //IF/ID Output Wires and Load Enable
    wire[31:0] id_instruction, id_pc;

    //ID Output Wires
    wire[31:0] id_pc_four, id_signed_imm16, id_signed_imm16_adder, id_signed_address26_concat, id_target_address, id_jump_address, id_branch_jump_address, id_pc_eight; // Cambiar!!
    wire[31:0] id_pa, id_pb, id_pa_mux, id_pb_mux, id_hi, id_lo;
    // wire[27:0] id_signed_address26;
    wire[4:0] id_rw;
    
    //ID/EX Output Wires
    wire[31:0] ex_target_address, ex_instruction, ex_pc, ex_pa, ex_pb;
    wire[4:0] ex_rw;

    //EX Output Wires
    wire[31:0] ex_source_operand, ex_sa_selector, ex_alu;
    wire[2:0] ex_instruction_condition;
    wire ex_hazard_signal;

    //EX/MEM Output Wires
    wire[31:0] mem_pb, mem_pc_eight, mem_alu;
    wire[4:0] mem_rw;

    //MEM Output Wires
    wire[31:0] mem_ram, mem_pw;
    wire[1:0] ex_flags;
    wire mem_inverter;

    //MEM/WB Output Wires
    wire[31:0] wb_pw;
    wire[4:0] wb_rw;

    //Control Unit
    CONTROL_UNIT my_control_unit (control_signal, id_instruction);
    CONTROL_UNIT_MUX my_control_mux (id_control_signal, control_signal, nop_signal);

    //Forwarding Unit
    HAZARD_FORWARDING_UNIT my_forwarding_unit (pa_selector, pb_selector, load_enable, pc_enable, nop_signal, ex_rw, mem_rw, wb_rw, id_instruction[24:20], id_instruction[19:15], ex_control_signal[11], mem_control_signal[11], wb_control_signal[11], ex_control_signal[12], mem_control_signal[12]);

    //IF Modules
    PC my_pc (if_pc, if_mux, clk, pc_enable, reset);
    PC_ADDER my_pc_adder(if_adder, if_mux);
    // $display("%d, %b, %b", if_adder, if_pc, if_mux);
    XOR my_xor (if_xor, ex_hazard_signal, id_control_signal[9]);
    GEN_MUX my_if_mux (if_mux, if_pc, id_branch_jump_address, if_xor);
    rom my_rom (if_instruction, if_pc[8:0]);

    //IF - ID Pipeline
    PIPELINE_IF_ID my_if_id (id_instruction, id_pc, if_instruction, if_pc, reset, clk, load_enable, ex_hazard_signal);

    //ID Modules
    ADDER my_pc_four (id_pc_four, id_pc, 32'b100);
    // IMM16_SIGNED my_imm16_signed (id_signed_imm16, id_instruction[15:0]);
    // ADDER my_imm16_adder (id_signed_imm16_adder, id_signed_imm16, id_pc_four);
    // ADDRESS26_SIGNED my_address26_signed (id_signed_address26, id_instruction[25:0]);
    // ADDRESS26_CONCATENATED my_address26_concat (id_signed_address26_concat, id_signed_address26, id_pc[31:28]);
    GEN_MUX my_imm_address_mux (id_target_address, id_signed_imm16_adder, id_signed_address26_concat, id_control_signal[8]);

    // TA_OR_RS my_jump_mux (id_jump_address, id_target_address, id_pa_mux, id_instruction[31:26]);
    // GEN_MUX my_jump_or_branch (id_branch_jump_address, id_jump_address, ex_target_address, ex_control_signal[10]);

    // ADDER my_pc_eight (id_pc_eight, id_pc_four, 32'b100); // Creo que no es necesario

    DEST_MUX my_rw_selector (id_rw, id_instruction[15:11], id_instruction[20:16], id_control_signal[20], id_control_signal[7]);
    RegisterFile my_ref_file (id_pa, id_pb, wb_pw, id_instruction[25:21], id_instruction[20:16], wb_rw, wb_control_signal[11], clk);
   
    PA_MUX my_pa_mux (id_pa_mux, pa_selector, ex_alu, mem_pw, wb_pw, id_pa);
    PB_MUX my_pb_mux (id_pb_mux, pb_selector, ex_alu, mem_pw, wb_pw, id_pb);

    // HI my_hi (id_hi, wb_pw, id_control_signal[6]);
    // LO my_lo (id_lo, wb_pw, id_control_signal[5]);

    //ID - EX Pipeline
    PIPELINE_ID_EX my_id_ex (ex_control_signal, ex_instruction, ex_pa, ex_pb, ex_rw, ex_pc_eight, ex_pc, ex_target_address, ex_hi, ex_lo, id_control_signal, id_instruction, id_pa_mux, id_pb_mux, id_rw, id_pc_eight, id_pc, id_target_address,id_hi, id_lo, reset, clk);

    //EX Modules
    SourceOperand2Handler my_source_operand (ex_source_operand, ex_pb, ex_hi, ex_lo, ex_pc, ex_instruction[15:0], ex_control_signal[19:17]);
    SA_SELECTOR my_sa_selector (ex_sa_selector, ex_instruction, ex_pa);
    ALU my_alu (ex_alu, ex_flags, ex_control_signal[16:13], ex_sa_selector, ex_source_operand);
    INSTR_CONDITION my_instr_condition (ex_instruction_condition, ex_instruction[31:26], ex_instruction[20:16]);
    CONDITION_HANDLER my_condition_handler (ex_hazard_signal, ex_instruction_condition, ex_flags, ex_control_signal[10]);

    //EX - MEM Pipeline
    PIPELINE_EX_MEM my_ex_mem (mem_control_signal, mem_pb, mem_rw, mem_pc_eight, mem_alu, ex_control_signal, ex_pb, ex_rw, ex_pc_eight, ex_alu, reset, clk);

    //MEM Modules
    // INVERTER my_inverter (mem_inverter, mem_control_signal[12]);
    ram my_ram (mem_ram, mem_pb, mem_alu[8:0], mem_control_signal[4:3], mem_control_signal[2], mem_control_signal[1], mem_inverter);
    PW_SELECTOR my_mem_mux (mem_pw, mem_alu, mem_ram, mem_pc_eight, mem_control_signal[12], mem_control_signal[0]);

    //WB Pipeline
    PIPELINE_MEM_WB my_mem_wb(wb_control_signal, wb_rw, wb_pw, mem_control_signal, mem_rw, mem_pw, reset, clk);

    initial begin
        fi = $fopen("../textFiles/PF4_debug_code.txt","r");
        address = 9'b0;
        while (!$feof(fi)) begin
            code = $fscanf(fi,"%b",data);
            my_rom.Mem[address] = data;
            my_ram.Mem[address] = data;
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
        forever #2 clk = ~clk; // Forever clock
    end

    initial fork
        #3 reset = 0
        #300 $finish;    // Originally 48
        
    join

    
    always @(posedge clk) begin
        case (if_instruction[6:0])
        // Integer Register-Immediate Instructions:
            7'b0010011: begin
                            //ADDI:
                            if(if_instruction[14:12] == 3'b000) begin
                                    op_keyword = "ADDI";
                            end
                            // SLTI:
                            else if(if_instruction[14:12] == 3'b010) begin
                                    op_keyword = "SLTI";
                            end
                            // SLTIU:
                            else if(if_instruction[14:12] == 3'b011) begin
                                    op_keyword = "SLTIU";
                            end
                            // ANDI:
                            else if(if_instruction[14:12] == 3'b111) begin
                                    op_keyword = "ANDI";
                            end
                            // ORI:
                            else if(if_instruction[14:12] == 3'b110) begin
                                    op_keyword = "ORI";
                            end
                            // XORI:
                            else if(if_instruction[14:12] == 3'b100) begin
                                    op_keyword = "XORI";
                            end
                            // SLLI:
                            else if(if_instruction[14:12] == 3'b100) begin
                                    op_keyword = "SLLI";
                            end
                            // SRLI:
                            else if(if_instruction[14:12] == 3'b101 && if_instruction[31:25] == 7'b0000000) begin
                                    op_keyword = "SRLI";
                            end
                            // SRAI:
                            else if(if_instruction[14:12] == 3'b101 && if_instruction[31:25] == 7'b0100000) begin
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
                            if(if_instruction[14:12] == 3'b000 && if_instruction[31:25] == 7'b0000000) begin
                                op_keyword = "ADD";
                            end
                            // SUB:
                            else if(if_instruction[14:12] == 3'b000 && if_instruction[31:25] == 7'b0100000) begin
                                op_keyword = "SUB";
                            end
                            // SLT:
                            else if(if_instruction[14:12] == 3'b010) begin
                                op_keyword = "SLT";
                            end
                            // SLTU:
                            else if(if_instruction[14:12] == 3'b011) begin
                                op_keyword = "SLTU";
                            end
                            // AND
                            else if(if_instruction[14:12] == 3'b111) begin
                                op_keyword = "AND";
                            end
                            // OR
                            else if(if_instruction[14:12] == 3'b110) begin
                                op_keyword = "OR";
                            end
                            // XOR
                            else if(if_instruction[14:12] == 3'b100) begin
                                op_keyword = "XOR";
                            end
                            // SLL
                            else if(if_instruction[14:12] == 3'b001) begin
                                op_keyword = "SLL";
                            end
                            // SRL
                            else if(if_instruction[14:12] == 3'b101 && if_instruction[31:25] == 7'b0000000) begin
                                op_keyword = "SRL";
                            end
                            // SRA
                            else if(if_instruction[14:12] == 3'b101 && if_instruction[31:25] == 7'b0100000) begin
                                op_keyword = "SRA";
                            end
                        end
// --------------------------------------------------------------------------------------------------------------------------
        // Load Instructions:
            7'b0000011: begin
                            // LW:
                            if(if_instruction[14:12] == 3'b010) begin
                                op_keyword = "LW";
                            end
                            // LH:
                            else if(if_instruction[14:12] == 3'b01) begin
                                op_keyword = "LH";
                            end
                            // LHU:
                            else if(if_instruction[14:12] == 3'b101) begin
                                op_keyword = "LHU";
                            end
                            // LB:
                            else if(if_instruction[14:12] == 3'b000) begin
                                op_keyword = "LB";
                            end
                            // LBU:
                            else if(if_instruction[14:12] == 3'b100) begin
                                op_keyword = "LBU";
                            end
                        end
// ------------------------------------------------------------------------------------------------------------------------------
        // Store Instructions:
            7'b0100011: begin
                            // SW:
                            if(if_instruction[14:12] == 3'b010) begin
                                op_keyword = "SW";
                            end
                            // SH:
                            else if(if_instruction[14:12] == 3'b001) begin
                                op_keyword = "SH";
                            end
                            // SB:
                            else if(if_instruction[14:12] == 3'b000) begin
                                op_keyword =  "SB";
                            end
                        end
// -------------------------------------------------------------------------------------------------------------------------
        // Conditional Branch Instructions:
            7'b1100011: begin
                            if(if_instruction[14:12] == 3'b000) begin
                                op_keyword = "BEQ";
                            end
                            else if(if_instruction[14:12] == 3'b001) begin
                                op_keyword = "BNE";
                            end
                            else if(if_instruction[14:12] == 3'b100) begin
                                op_keyword = "BLT";
                            end
                            else if(if_instruction[14:12] == 3'b101) begin
                                op_keyword = "BGE";
                            end
                            else if(if_instruction[14:12] == 3'b110) begin
                                op_keyword = "BLTU";
                            end
                            else if(if_instruction[14:12] == 3'b111) begin
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
        $monitor("PC: %d, R1: %d, R3: %d, R4: %d, R5: %d, R8: %d, R10: %d, R11: %d, R12: %d", if_pc, my_ref_file.Q1, my_ref_file.Q3, my_ref_file.Q4, my_ref_file.Q5, my_ref_file.Q8, my_ref_file.Q10, my_ref_file.Q11, my_ref_file.Q12);
    end

endmodule