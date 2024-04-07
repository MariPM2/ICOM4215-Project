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
        
        case (id_instruction_out[6:0])
            7'b0010011: op_keyword = "ADDI";
            7'b0110011: op_keyword = "SUB";
            7'b0100011: op_keyword = "SB"; 
            7'b1100011: op_keyword = "BGE";
            7'b0110111: op_keyword = "LUI";
            7'b1101111: op_keyword = "JAL";
            7'b1100111: op_keyword = "JALR";
            7'b0000011: begin
                            if(id_instruction_out[14:12] == 3'b000) begin
                                    op_keyword = "LB";
                                end
                            else if(id_instruction_out[14:12] == 3'b100) begin
                                    op_keyword = "LBU";
                                end
                        end
            default: op_keyword = "NOP";
        endcase
        
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