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
`include "../modules/conc_si.v"
// `include "../modules/Register.v"

module control_unit_ppu_testbench();
/* VARIABLES RELATED TO FILE MANAGEMENT*/

    integer fi, code;
    reg[8:0] address;
    reg[8:0] address2;
    reg[7:0] data;

/* GLOBAL RESET and CLOCK */

    reg clk, reset;
    // integer cycle;
    reg finished1;

/* MISCELLANEOUS */
    reg[39:0] op_keyword;

    reg[8:0] Loc;

/* REGISTERS (INPUTS AND OUTPUTS) DECLARATIONS*/

    wire[31:0] adder_out, pc_out, if_instruction_out;
    wire[31:0] id_instruction_out;
    //wire[20:0] id_control_signal, id_control_signal_mux;
    wire[22:0] id_control_signal, id_control_signal_mux;
    //wire[20:0] ex_control_signal;
    wire[22:0] ex_control_signal;
    //wire[20:0] mem_control_signal;
    wire[22:0] mem_control_signal;
    // wire[20:0] wb_control_signal;
    wire[22:0] wb_control_signal;
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

    wire if_id_reset_hazard;
    wire id_ex_reset_hazard;
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

    wire[2:0] si;

    // wire[31:0] dummy;

    wire[31:0] id_pc_plus4, ex_pc_plus4;



// registerX dummy2 (dummy, clk, 1'b1, pc_out);


/* MODULE INSTANTIATIONS */
    CONTROL_UNIT my_ctrl_unit (id_control_signal, id_instruction_out);
    CONTROL_UNIT_MUX my_ctrl_mux (id_control_signal_mux, id_control_signal, nop_signal);

    HAZARD_FORWARDING_UNIT my_forwarding_unit (pa_selector, pb_selector, load_enable, pc_enable, nop_signal, ex_rw, mem_rw, wb_rw, id_instruction_out[19:15], id_instruction_out[24:20], ex_control_signal[15], mem_control_signal[15], wb_control_signal[15], ex_control_signal[16],id_control_signal_mux[22:21]);
    //START IF STAGE ---------------------------------------------------------------------------------

    IF_MUX my_if_mux (pc_in, ex_TA, ex_alu, id_TA, adder_out, decision_output);
    PC my_pc (pc_out, pc_in, clk, load_enable, reset);
    PC_ADDER my_pc_adder (adder_out, pc_out);


    rom my_rom (if_instruction_out, pc_out[8:0]);
    
    
    //END IF STAGE ---------------------------------------------------------------------------------

    PIPELINE_IF_ID my_if_id (id_instruction_out, id_pc, id_pc_plus4, if_instruction_out, pc_out, adder_out, reset, clk, load_enable, if_id_reset_hazard);

    //START ID STAGE ---------------------------------------------------------------------------------
    

    RegisterFile my_reg_file(id_pa, id_pb, wb_pw, id_instruction_out[19:15], id_instruction_out[24:20], wb_rw, clk, wb_control_signal[15]);
    
    
    PA_MUX my_pa_mux (id_pa_mux, pa_selector, ex_alu, mem_pw, wb_pw, id_pa);
    PB_MUX my_pb_mux (id_pb_mux, pb_selector, ex_alu, mem_pw, wb_pw, id_pb);
    //     // Cambiar a 31:7 porque asi lo tengo en el diagrama
    IMM_HANDLER my_imm_hanlder (imm_handler_out, id_control_signal_mux[0], id_instruction_out[31:0]);
    ADDER my_TA_adder (id_TA, imm_handler_out, id_pc);

    //END ID STAGE ---------------------------------------------------------------------------------

    PIPELINE_ID_EX my_id_ex (ex_control_signal, ex_instruction, ex_pa, ex_pb, ex_rw, ex_pc, ex_pc_plus4, ex_TA, id_control_signal_mux, id_instruction_out, id_pa_mux, id_pb_mux, id_instruction_out[11:7], id_pc, id_pc_plus4, id_TA, reset, clk, id_ex_reset_hazard);
    
    // START EX STAGE ---------------------------------------------------------------------------------

    Concatenate_imm12_s my_imm12_s_conc (imm12_s, ex_instruction[31:25], ex_instruction[11:7]);
    Concatenate_si my_si (si, ex_control_signal[14], ex_control_signal[13], ex_control_signal[12]);
    SecondOperandHandler my_second_operand (ex_second_operand, ex_pb, si, ex_instruction[31:20], imm12_s, ex_instruction[31:12], ex_pc);
    GEN_MUX my_alu_A_input (alu_A_input, ex_pa, ex_pc, ex_control_signal[2]);
    
    ALU my_alu (ex_alu, Z, N, C, V, alu_A_input, ex_second_operand, ex_control_signal[20:17]);



    CONDITION_HANDLER my_condition_handler (cond_hand_out, Z, N, C, V, ex_control_signal[11:9]);

    GEN_MUX my_alu_mux (alu_mux_output, ex_alu, ex_pc_plus4, ex_control_signal[3]);

    LOGIC_BOX my_logic_box (decision_output, if_id_reset_hazard, id_ex_reset_hazard, cond_hand_out, id_control_signal_mux[0], ex_control_signal[1]);
    // AVERVIGUAR COMO RESET LOS PIPELINE IF/ID y ID/EX

    // END EX STAGE ---------------------------------------------------------------------------------

    PIPELINE_EX_MEM my_ex_mem (mem_control_signal, mem_pb, mem_rw, mem_alu, ex_control_signal, ex_pb, ex_rw, alu_mux_output, reset, clk);

    
    // START MEM STAGE ---------------------------------------------------------------------------------

    ram my_ram (mem_ram, mem_control_signal[6], mem_control_signal[4], mem_control_signal[5], mem_alu[8:0], mem_pb, mem_control_signal[8:7]);
    PW_SELECTOR my_mem_mux (mem_pw, mem_alu, mem_ram, mem_control_signal[16]);

    // END MEM STAGE ---------------------------------------------------------------------------------
    
    PIPELINE_MEM_WB my_mem_wb(wb_control_signal, wb_rw, wb_pw, mem_control_signal, mem_rw, mem_pw, reset, clk);

    // initial begin
    //     // $monitor("PC:%d, A:%d, B:%d, Out:%d \n Mux_Out: %d, Ex_rd: %d, Mem_rd:%d, Wb_rd:%d, Pa:%d\n ra:%d, rb:%d,\ninstrcution:%b", pc_out, alu_A_input, ex_second_operand, ex_alu, id_pa_mux, pa_selector, ex_alu, mem_pw, wb_pw, id_pa, id_instruction_out[19:15], id_instruction_out[24:20], if_instruction_out);
    //     $monitor("PC:%d, id_instr:%b, ex_instr:%b, rs1:%d, rs2:%d, ALU_A:%d, ALU_B:%d, ALU_Out:%d, id_pa_mux:%d, AUIPC_mux_signal:%d, ex_pa:%d, si:%b, imm12_i:%d, alu_mux_out:%d, mem_alu:%d, mem_pw:%d, wb_pw:%d, time: %d", pc_out, id_instruction_out, ex_instruction, id_instruction_out[19:15], id_instruction_out[24:20], alu_A_input, ex_second_operand, ex_alu, id_pa_mux, ex_control_signal[2], ex_pa, si, ex_instruction[31:20], alu_mux_output, mem_alu[8:0], mem_pw, wb_pw, $time);

    // end
    // Yo creo que esto podia haber sido un gen mux

    // START WB STAGE ---------------------------------------------------------------------------------

    // END WB STAGE ---------------------------------------------------------------------------------

/* TESTBENCH */
    
    initial begin
        //fi = $fopen("../textFiles/PF4_debug_code.txt","r");
        // fi = $fopen("../textFiles/testcode1_RISC-V.txt","r");
        fi = $fopen("../textFiles/testcode2_RISC-V.txt","r");
        address = 9'b0;
        while (!$feof(fi)) begin
            code = $fscanf(fi,"%b",data);
            my_rom.Mem[address] = data;
            // my_ram.Mem[address] = data;
            address = address + 1'b1;
        end
        $fclose(fi);
        address = 9'b0;
        finished1 = 1;
    end

    initial begin
        // fi = $fopen("../textFiles/PF4_debug_code.txt","r");
        // fi = $fopen("../textFiles/testcode1_RISC-V.txt","r");
        fi = $fopen("../textFiles/testcode2_RISC-V.txt","r");
        address2 = 9'b0;
        while (!$feof(fi)) begin
            code = $fscanf(fi,"%b",data);
            my_ram.Mem[address2] = data;
            address2 = address2 + 1'b1;
        end
        $fclose(fi);
        address2 = 9'b0;
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

    // El que hice con el profe:
    // initial begin
    //     $monitor("ID_Instr: %b, ID_PC: %d, IF_Instr: %b, IF_PC: %d, Reset: %d, LE: %d, clk: %d", id_instruction_out, id_pc, if_instruction_out, pc_out, reset, load_enable, clk);
    // end
        

    // El que tiene que funcionar
    // initial begin
    //     $monitor("PC: %d, R1: %d, R2: %d, R3: %d, R5: %d, R6: %d, if_id_reset_hazard:%d, id_ex_reset_hazard:%d", pc_out, my_reg_file.Qs1, my_reg_file.Qs2, my_reg_file.Qs3, my_reg_file.Qs5, my_reg_file.Qs6, if_id_reset_hazard, id_ex_reset_hazard);
    // end

    //testcode1
    // initial begin
    //     $monitor("PC: %d, R1: %d, R2: %d, R3: %d, R5: %d, if_id_reset_hazard:%d, id_ex_reset_hazard:%d, Time:%d ", pc_out, my_reg_file.Qs1, my_reg_file.Qs2, my_reg_file.Qs3, my_reg_file.Qs5, if_id_reset_hazard, id_ex_reset_hazard, $time);
    // end

    // initial begin
    //     #206
    //     $display("Word 40: %b", {my_ram.Mem[43], my_ram.Mem[42], my_ram.Mem[41], my_ram.Mem[40]});
    // end

    //testcode2
    initial begin
        $monitor("PC: %d, R1: %d, R2: %d, R3: %b, R4: %d, R5: %d, R7: %d, R10: %d, R14: %b, R31: %d, if_id_reset_hazard:%d, id_ex_reset_hazard:%d, Time: %d ", pc_out, my_reg_file.Qs1, my_reg_file.Qs2, my_reg_file.Qs3, my_reg_file.Qs4, my_reg_file.Qs5, my_reg_file.Qs7, my_reg_file.Qs10, my_reg_file.Qs14, my_reg_file.Qs31, if_id_reset_hazard, id_ex_reset_hazard, $time);
    end

    // initial begin
    // #190
    //     for (address = 9'b10110100; address <= 9'b11011100; address = address + 1'b1) begin
    //         $display("Word %d: %b", address, {my_ram.Mem[address + 3], my_ram.Mem[address + 2], my_ram.Mem[address + 1], my_ram.Mem[address]});
    //     end
    // end

    initial begin
        #190
        Loc = 9'd180;
        repeat (11)
        begin
            $display("Word %d: %b", Loc, {my_ram.Mem[Loc+3], my_ram.Mem[Loc+2], my_ram.Mem[Loc+1], my_ram.Mem[Loc]});
            Loc = Loc +4;
        end
    end


    // initial begin
    //     #190
    //     for (address = 9'b10110100; address <= 9'b11100000; address = address + 1'b1) begin
    //         $display("Memory[%d]: %b", address, {my_ram.Mem[address + 2'b11], my_ram.Mem[address+2'b10], my_ram.Mem[address+1'b1], my_ram.Mem[address]});
    //     end
    // end


    // RegisterFile
    // initial begin
    //    $monitor("PC: %d, id_pa:%d, id_pb=%d, wb_pw:%d, rs1:%d, rs2:%d, wb_rw:%d, LE:%d", pc_out, id_pa, id_pb, wb_pw, id_instruction_out[19:15], id_instruction_out[24:20], wb_rw, wb_control_signal[15]);
    // end

    // pw_selector
    // initial begin
    //    $monitor("PC: %d, mem_pw=%d, mem_alu_address:%d, mem_ram_out:%d, LoadInstr:%d ", pc_out, mem_pw, mem_alu, mem_ram, mem_control_signal[16]);
    // end

    //RAM
    // initial begin
    //     $monitor("PC: %d, mem_ram_OUT:%d, E:%d, R/W:%d, SE:%d, Address:%d, mem_pb_datain:%d, Size:%b", pc_out, mem_ram, mem_control_signal[6], mem_control_signal[4], mem_control_signal[5], mem_alu[8:0], mem_pb, mem_control_signal[8:7]);
    // end

    // ALU input A
    // initial begin
    //     $monitor("PC:%d, ALU_A_inout:%d, PA:%d, EX_PC:%d, AUIPC:%d",pc_out, alu_A_input, ex_pa, ex_pc, ex_control_signal[2]);
    // end

    // initial begin
    //     $monitor("PC:%d, id_pa_mux:%d, pa_selector:%b, ex_alu:%d, mem_pw:%d, wb_pw:%d, id_pa:%d", pc_out, id_pa_mux, pa_selector, ex_alu, mem_pw, wb_pw, id_pa);
    // end
    
    //Hazard Forwarding Unit
    // initial begin
    //     $monitor("PC:%d, SR:%b, pa_s:%b, pb_s:%b, lE:%d, pc_E:%d, nop:%d, ex_rw:%d, mem_rw:%d, wb_rw:%d, rs1:%d, rs2:%d, ex_rf:%d, mem_rf:%d, wb_rf:%d, ex_li:%d", pc_out, ex_control_signal[22:21], pa_selector, pb_selector, load_enable, pc_enable, nop_signal, ex_rw, mem_rw, wb_rw, id_instruction_out[19:15], id_instruction_out[24:20], ex_control_signal[15], mem_control_signal[15], wb_control_signal[15], ex_control_signal[16]);
    // end

    // Condition Handler
    // initial begin
    //     $monitor("PC:%d, cond_hand_out:%d, Z:%d, N:%d, C:%d, V:%d, branch_Type:%b", pc_out, cond_hand_out, Z, N, C, V, ex_control_signal[11:9]);
    // end

    // Logic Box
    // initial begin
    //     $monitor("PC:%d, decision_output: %b, if_id_reset_hazard: %d, id_ex_reset_hazard: %d, cond_hand_out:%d, Jal:%d, Jalr:%d", pc_out, decision_output, if_id_reset_hazard, id_ex_reset_hazard, cond_hand_out, id_control_signal_mux[0], ex_control_signal[1]);
    // end

    // ALU
    // initial begin
    //     $monitor("PC:%d, ex_alu:%d, ex_alu:%b, Z:%d, N:%d, C:%d, V:%d, alu_A_input:%d, ex_second_operand:%d, Alu_op:%b", pc_out, ex_alu, ex_alu, Z, N, C, V, alu_A_input, ex_second_operand, ex_control_signal[20:17]);
    // end

    // IF_Mux
    // initial begin
    //     $monitor("PC:%d, pc_in:%d, ex_TA:%d, ex_alu:%d, id_TA:%d, adder_out:%d, decision_output:%b", pc_out, pc_in, ex_TA, ex_alu, id_TA, adder_out, decision_output);
    // end

    // imm handler
    // initial begin
    //     $monitor("PC:%d, imm_handler_out:%d, imm_handler_out:%b, id_JAL:%d, id_INStr:%b, ex_Ta:%d", pc_out, imm_handler_out, imm_handler_out, id_control_signal_mux[0], id_instruction_out[31:0], ex_TA);
    // end
     
    //  adder TA
    // initial begin
    //     $monitor("PC:%d, ex_TA:%d, id_TA:%d, imm_handler_out:%d, id_pct:%d, LE:%d, reset:%d, hazard_reset:%d", pc_out, ex_TA,id_TA, imm_handler_out, id_pc, load_enable, reset, if_id_reset_hazard);
    // end
endmodule