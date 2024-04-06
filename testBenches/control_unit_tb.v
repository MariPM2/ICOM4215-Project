// `timescale 1ns / 1ps

`include "../modules/pc.v"
`include "../modules/mux.v"
`include "../modules/control_unit.v"
`include "../modules/pc_adder.v"
`include "../modules/PF1_Perez_Mendez_Mariana_rom.v"
`include "../modules/pipeline_registers.v"

module control_unit_ppu_testbench();
/* VARIABLES RELATED TO FILE MANAGEMENT*/

    integer fi, code;
    reg[8:0] address;
    reg[7:0] data;

/* GLOBAL RESET and CLOCK */

    reg clk, reset;
    integer cycle;

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

/* MODULE INSTANTIATIONS */

    //START IF STAGE

    PC my_pc (pc_out, adder_out, clk, 1'b1, reset);
    // NPC my_npc (npc_out, adder_out, clk, 1'b1, reset);
    PC_ADDER my_pc_adder (adder_out, pc_out);
    
    
    //END IF STAGE
    
    PIPELINE_IF_ID my_if_id(id_instruction_out, if_instruction_out, reset, clk);
    
    //START ID STAGE
    
    CONTROL_UNIT my_ctrl_unit (id_control_signal, id_instruction_out);
    CONTROL_UNIT_MUX my_ctrl_mux (id_control_signal_mux, id_control_signal, s);

    //END ID STAGE

    PIPELINE_ID_EX my_id_ex (ex_control_signal, id_control_signal_mux, reset, clk);

    // START EX STAGE
    
    // END EX STAGE
    
    PIPELINE_EX_MEM my_ex_mem (mem_control_signal, ex_control_signal, reset, clk);

    // START MEM STAGE

    rom my_rom (if_instruction_out, pc_out[8:0]);

    // END MEM STAGE

    PIPELINE_MEM_WB my_mem_wb (wb_control_signal, mem_control_signal, reset, clk);

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
        
        case (id_instruction_out[31:26])
            6'b001001: op_keyword = "ADDIU";
            6'b100100: op_keyword = "LBU";
            6'b101000: op_keyword = "SB";
            6'b000111: op_keyword = "BGTZ";
            6'b001111: op_keyword = "LUI";
            6'b000011: op_keyword = "JAL";
            default: op_keyword = "NOP";
        endcase
        //if(id_control_signal_mux == 0) op_keyword = "NOP"; // Identify nop
        if(id_instruction_out[31:26] == 6'b000000 && id_instruction_out[5:0] == 6'b100011) op_keyword = "SUBU";
        if(id_instruction_out[31:26] == 6'b000000 && id_instruction_out[5:0] == 6'b001000) op_keyword = "JR";
            $display("Keyword: %s, PC: %d", op_keyword, pc_out); // Instruction, PC, nPC
            //$display("%b\n", if_instruction_out);
            $display("\tControl Unit Signals (ID STAGE):\n\t\tID_RT_DEST = %b,\n \t\tID_Shift_IMM = %b,\n \t\tID_ALU_OP = %b,\n \t\tID_LOAD_INSTR = %b,\n \t\tID_RF_ENABLE = %b,\n \t\tID_BRANCH_ENABLE = %b,\n \t\tID_JUMP_ENABLE = %b,\n \t\tID_R31_DEST = %b,\n \t\tID_HI_ENABLE = %b,\n \t\tID_LO_ENABLE = %b,\n \t\tID_SIZE = %b,\n \t\tID_MEM_DATA_SE = %b,\n \t\tID_MEM_DATA_ENABLE = %b,\n \t\tID_PC_PLUS_EIGHT_ENABLE = %b,\n", id_control_signal_mux[19], id_control_signal_mux[18:16], id_control_signal_mux[15:12], id_control_signal_mux[11], id_control_signal_mux[10], id_control_signal_mux[9], id_control_signal_mux[8], id_control_signal_mux[7], id_control_signal_mux[6], id_control_signal_mux[5], id_control_signal_mux[4:3], id_control_signal_mux[2], id_control_signal_mux[1], id_control_signal_mux[0]);
            $display("\tControl Unit Signals (EX STAGE):\n\t\tEX_Shift_IMM = %b,\n \t\tEX_ALU_OP = %b,\n \t\tEX_LOAD_INSTR = %b,\n \t\tEX_RF_ENABLE = %b,\n \t\tEX_BRANCH_ENABLE = %b,\n\t\tID_HI_ENABLE = %b,\n \t\tEX_LO_ENABLE = %b,\n \t\tEX_SIZE = %b,\n \t\tEX_MEM_DATA_SE = %b,\n \t\tEX_MEM_DATA_ENABLE = %b,\n \t\tEX_PC_PLUS_EIGHT_ENABLE = %b,\n", ex_control_signal[18:16], ex_control_signal[15:12], ex_control_signal[11], ex_control_signal[10], ex_control_signal[9], ex_control_signal[6], ex_control_signal[5], ex_control_signal[4:3], ex_control_signal[2], ex_control_signal[1], ex_control_signal[0]);
            $display("\tControl Unit Signals (MEM STAGE):\n\t\tMEM_LOAD_INSTR = %b,\n \t\tMEM_RF_ENABLE = %b,\n \t\tMEM_HI_ENABLE = %b,\n \t\tID_LO_ENABLE = %b,\n \t\tID_SIZE = %b,\n \t\tID_MEM_DATA_SE = %b,\n \t\tID_MEM_DATA_ENABLE = %b,\n \t\tID_PC_PLUS_EIGHT_ENABLE = %b,\n", mem_control_signal[11], mem_control_signal[10],mem_control_signal[6],mem_control_signal[5], mem_control_signal[4:3], mem_control_signal[2], mem_control_signal[1], mem_control_signal[0]);           
            $display("\tControl Unit Signals (WB STAGE):\n\t\tWB_RF_ENABLE = %b,\n\t\tWB_HI_ENABLE = %b,\n \t\tWB_LO_ENABLE = %b\n",wb_control_signal[10], wb_control_signal[6], wb_control_signal[5]);
    end
endmodule