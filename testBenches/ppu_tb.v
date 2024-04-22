`timescale 1ns / 1ps

`include "../modules/pc.v"
`include "../modules/mux.v"
`include "../modules/control_unit.v"
`include "../modules/pc_adder.v"
`include "../modules/PF1_Perez_Mendez_Mariana_rom.v"
`include "../modules/PF1_Rodriguez_Green_Diego_alu.v"
`include "../modules/PF1_Rodriguez_Green_Diego_secondoperandhandler.v"
`include "../modules/pipeline_registers_new.v"
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
`include "../modules/imm_handler.v"
`include "../modules/adder.v"

module control_unit_ppu_testbench();
/* VARIABLES RELATED TO FILE MANAGEMENT*/

    integer fi, code;
    reg[8:0] address;
    reg[7:0] data;

/* GLOBAL RESET and CLOCK */

    reg clk, reset;
    // integer cycle;
    reg finished1;

/* MISCELLANEOUS */
    reg[39:0] op_keyword;

/* REGISTERS (INPUTS AND OUTPUTS) DECLARATIONS*/

    wire[31:0] adder_out, pc_out, if_instruction_out;
    wire[31:0] id_instruction_out;
    wire[20:0] id_control_signal, id_control_signal_mux;
    wire[20:0] ex_control_signal;
    wire[20:0] mem_control_signal;
    wire[20:0] wb_control_signal;
    // reg pc_e, s;  // s = nop_signal

    wire[31:0] id_pa, id_pb, id_pa_mux, id_pb_mux;

//EX Output Wires
    wire[31:0] ex_second_operand, ex_alu;
    // wire[2:0] ex_instruction_condition;
    // wire ex_hazard_signal;

    wire Z, N, C, V;

    wire nop_signal, load_enable, pc_enable;

    wire[31:0] alu_A_input;
    wire[31:0] alu_mux_output;

//Forwarding Unit
    wire[1:0] pa_selector, pb_selector;

 //EX/MEM Output Wires
    wire[31:0] mem_pb, mem_alu;
    wire[4:0] mem_rw;

//MEM Output Wires
    wire[31:0] mem_ram, mem_pw;
    // wire[1:0] ex_flags;
    // wire mem_inverter;
    wire[11:0] imm12_s;

//MEM/WB Output Wires
    wire[31:0] wb_pw;
    wire[4:0] wb_rw;

    wire if_id_reset;
    wire id_ex_reset;
    wire cond_hand_out;
    wire [2:0] decision_output;
    
    wire[31:0] pc_in;
    wire[31:0] id_TA, ex_TA;
    // wire[31:0] id_TA;

    wire[31:0] imm_handler_out;

    // wire[31:0] ex_pc;

    wire[31:0] ex_target_address, ex_instruction, ex_pa, ex_pb;
    wire[4:0] ex_rw;

    wire[31:0] if_pc, id_pc, ex_pc;

    wire[31:0] id_target_address;

    wire[4:0] id_rw;


/* MODULE INSTANTIATIONS */

    //START IF STAGE

    PC my_pc (pc_out, adder_out, clk, 1'b1, reset);
    PC_ADDER my_pc_adder (adder_out, pc_out);

    IF_MUX my_if_mux (pc_in, ex_TA, ex_alu, id_TA, adder_out, decision_output);

    rom my_rom (if_instruction_out, pc_out[8:0]);
    
    
    //END IF STAGE
    // Nuevo
    PIPELINE_IF_ID my_if_id (id_instruction_out, id_pc, if_instruction_out, if_pc, reset, clk, load_enable, ex_hazard_signal);
    // Viejo
    // PIPELINE_IF_ID my_if_id(id_instruction_out, if_instruction_out, reset, clk);
    //$display("\nInstruction: %s", id_instruction_out);
    //START ID STAGE
    
    CONTROL_UNIT my_ctrl_unit (id_control_signal, id_instruction_out);
    CONTROL_UNIT_MUX my_ctrl_mux (id_control_signal_mux, id_control_signal, nop_signal);

    RegisterFile my_reg_file(id_pa, id_pb, wb_pw, id_instruction_out[19:15], id_instruction_out[24:20], wb_rw, wb_control_signal[15], clk);

    PA_MUX my_pa_mux (id_pa_mux, pa_selector, ex_alu, mem_pw, wb_pw, id_pa);
    PB_MUX my_pb_mux (id_pb_mux, pb_selector, ex_alu, mem_pw, wb_pw, id_pb);
    // Cambiar a 31:7 porque asi lo tengo en el diagrama
    IMM_HANDLER my_imm_hanlder (imm_handler_out, id_control_signal_mux[0], id_instruction_out[31:0]);
    ADDER my_TA_adder (id_TA, imm_handler_out, pc_out);
    //END ID STAGE

    // Nuevo:
    PIPELINE_ID_EX my_id_ex (ex_control_signal, ex_instruction, ex_pa, ex_pb, ex_rw, ex_pc, ex_target_address, id_control_signal_mux, id_instruction_out, id_pa_mux, id_pb_mux, id_rw, id_pc, id_target_address, reset, clk);
    // Viejo:
    // PIPELINE_ID_EX my_id_ex (ex_control_signal, id_control_signal_mux, reset, clk);

    // START EX STAGE

    Concatenate_imm12_s my_imm12_s_conc (imm12_s, id_instruction_out[31:25], id_instruction_out[11:7]);
    // Concatenate_s2_s1_s0 my_si (si, id_instruction_out[14], id_instruction_out[13], id_instruction_out[12]);
    SecondOperandHandler my_second_operand (ex_second_operand, id_pb_mux, {id_instruction_out[14], id_instruction_out[13], id_instruction_out[12]} , id_instruction_out[31:20], imm12_s, id_instruction_out[31:12], ex_pc);
    GEN_MUX my_alu_A_input (alu_A_input, id_pa_mux, pc_out, ex_control_signal[2]);
    // ALU my_alu (id_pa_mux, ex_second_operand, ex_control_signal[20:17], ex_alu, Z, N, C, V);
    ALU my_alu (ex_alu, Z, N, C, V, alu_A_input, ex_second_operand, ex_control_signal[20:17]);


    HAZARD_FORWARDING_UNIT my_forwarding_unit (pa_selector, pb_selector, load_enable, pc_enable, nop_signal, ex_rw, mem_rw, wb_rw, id_instruction_out[24:20], id_instruction_out[19:15], ex_control_signal[15], mem_control_signal[15], wb_control_signal[15], ex_control_signal[16], mem_control_signal[16]);

    CONDITION_HANDLER my_condition_handler (cond_hand_out, Z, N, C, V, ex_control_signal[11:9]);

    GEN_MUX my_alu_mux (alu_mux_output, ex_alu, pc_out+4, ex_control_signal[3]);

    LOGIC_BOX my_logic_box (decision_output, if_id_reset, id_ex_reset, cond_hand_out, id_control_signal_mux[0], ex_control_signal[1]);
    // AVERVIGUAR COMO RESET LOS PIPELINE IF/ID y ID/EX

    // END EX STAGE

    // Nuevo:
    PIPELINE_EX_MEM my_ex_mem (mem_control_signal, ex_pb, mem_rw, mem_alu, ex_control_signal, ex_pb, ex_rw, alu_mux_output, reset, clk);
    // Viejo:
    // PIPELINE_EX_MEM my_ex_mem (mem_control_signal, ex_control_signal, reset, clk);

    // START MEM STAGE

    ram my_ram (mem_ram, mem_control_signal[6], mem_control_signal[4], mem_control_signal[5], mem_alu[8:0], alu_mux_output, mem_control_signal[8:7]);

    // END MEM STAGE
    //Nuevo
    PIPELINE_MEM_WB my_mem_wb(wb_control_signal, wb_rw, wb_pw, mem_control_signal, mem_rw, mem_pw, reset, clk);
    //Viejo
    // PIPELINE_MEM_WB my_mem_wb (wb_control_signal, mem_control_signal, reset, clk);

    PW_SELECTOR my_mem_mux (mem_pw, mem_alu, mem_ram, mem_control_signal[16]);
    // Yo creo que esto podia haber sido un gen mux

    // START WB STAGE

    // END WB STAGE

/* TESTBENCH */
    
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
        #3 reset = 0;
        #300 $finish;
        // #40 s = 1;
        // #48 $finish;    // Originally 48
    join           

        
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
    end

    initial begin
        $monitor("PC: %d, R1: %d, R2: %d, R3: %d, R5: %d, R6: %d", pc_out, my_reg_file.Qs1, my_reg_file.Qs2, my_reg_file.Qs3, my_reg_file.Qs5, my_reg_file.Qs6);
    end
            
endmodule