`timescale 1ns/1ns  // Configura la escala de tiempo para las simulaciones

/*
Pipeline between IF and ID
*/
module PIPELINE_IF_ID (
    // Outputs
    output reg [31:0] instruction_out,
    output reg [31:0] pc_out,

    //output reg [15:0] ID_IMM16,
    //output reg [25:0] ID_ADDRESS26,
    //output reg [4:0] ID_RS,
    //output reg [4:0] ID_RT,

    // Inputs
    input[31:0] instruction, pc,

    input reset, clk, load_enable, control_hazard_reset

);

    always@(posedge clk) begin

       if(reset || control_hazard_reset) begin
            instruction_out <= 32'b0;
        //    ID_IMM16        <= 16'b0;
        //    ID_ADDRESS26    <= 26'b0;
        //    ID_RS           <= 5'b0;
        //    ID_RT           <= 5'b0;
            pc_out          <= 32'b0;
        end
       
       else if (load_enable) begin
            instruction_out <= instruction;
        //    ID_IMM16        <= instruction[15:0];
        //    ID_ADDRESS26    <= instruction[25:0];
        //    ID_RS           <= instruction[25:21];
        //    ID_RT           <= instruction[20:16];
            pc_out          <= pc;
       end
    end
endmodule

/*
Pipeline between ID and EX
*/
module PIPELINE_ID_EX (
    // Outputs
    output reg[20:0] EX_CONTROL_SIGNAL,
    output reg[31:0] EX_INSTRUCTION,
    output reg[31:0] PA, PB,
    //output reg[5:0] OP,
    output reg[4:0] RW,
    // output reg[31:0] PC_P8,       //
    //output reg[15:0] IMM16,       //  
    output reg[31:0] PC,          //
    output reg[31:0] TA,          //
    // output reg[31:0] HI, LO,
    //output reg[31:0] INSTRUCTION,

    // Inputs
    input[20:0] ID_CONTROL_SIGNAL,
    input[31:0] ID_INSTRUCTION,
    input[31:0] PA_OUT, PB_OUT,
    //input[5:0] OP_CODE,
    input[4:0] RW_DATA,
    // input[31:0] PC_P8_DATA,
    //input[15:0] IMM16_DATA,
    input[31:0] PC_DATA,
    input[31:0] TA_DATA,
    // input[31:0] HI_DATA, LO_DATA,
    //input[31:0] INSTRUCTION_DATA,

    input wire reset, clk

);

    always@(posedge clk) begin
    //    #1;
       if(reset) begin
            EX_CONTROL_SIGNAL   <= 21'b0;
            EX_INSTRUCTION      <= 32'b0;
            PA                  <= 32'b0;  
            PB                  <= 32'b0;
            RW                  <= 5'b0;
            // PC_P8               <= 32'b0;
            PC                  <= 32'b0;
            TA                  <= 32'b0;
            // HI                  <= 32'b0;
            // LO                  <= 32'b0;
       end
       else begin
            EX_CONTROL_SIGNAL   <= ID_CONTROL_SIGNAL;
            EX_INSTRUCTION      <= ID_INSTRUCTION;
            PA                  <= PA_OUT;
            PB                  <= PB_OUT;
            RW                  <= RW_DATA;
            // PC_P8               <= PC_P8_DATA;
            PC                  <= PC_DATA;
            TA                  <= TA_DATA;
            // HI                  <= HI_DATA;
            // LO                  <= LO_DATA;
       end    
    end
endmodule

/*
Pipeline between EX and MEM
*/
module PIPELINE_EX_MEM (
    // Outputs
    output reg[20:0] MEM_CONTROL_SIGNAL,
    output reg[31:0] PB,
    output reg[4:0] RW,
    // output reg[31:0] PC_P8,
    output reg[31:0] ALU_RESULT,

    // Inputs
    input[20:0] EX_CONTROL_SIGNAL,
    input[31:0] PB_DATA,
    input[4:0] RW_DATA,
    // input[31:0] PC_P8_DATA,
    input[31:0] ALU_RESULT_DATA,

    input reset, clk 

);

    always@(posedge clk) begin
    //    #1;
        if(reset) begin
            MEM_CONTROL_SIGNAL  <= 21'b0;
            PB                  <= 32'b0;
            RW                  <= 5'b0;
            // PC_P8               <= 32'b0;
            ALU_RESULT          <= 32'b0;
        end
        else begin
            MEM_CONTROL_SIGNAL  <= EX_CONTROL_SIGNAL;
            PB                  <= PB_DATA;
            RW                  <= RW_DATA;
            // PC_P8               <= PC_P8_DATA;
            ALU_RESULT          <= ALU_RESULT_DATA;
        end
    end

endmodule

/*
Pipeline between MEM and WB
*/
module PIPELINE_MEM_WB (
    // Outputs
    output reg[20:0] WB_CONTROL_SIGNAL,
    output reg[4:0] RW,
    output reg[31:0] PW,

    // Inputs
    input[20:0] MEM_CONTROL_SIGNAL,
    input[4:0] RW_DATA,
    input[31:0] PW_DATA,

    input reset, clk
    
);

    always@(posedge clk) begin
    //    #1;
        if(reset) begin
            WB_CONTROL_SIGNAL   <= 21'b0;
            RW                  <= 5'b0;
            PW                  <= 32'b0;    
        end
        else begin
            WB_CONTROL_SIGNAL   <= MEM_CONTROL_SIGNAL;
            RW                  <= RW_DATA;
            PW                  <= PW_DATA;
        end
    end
endmodule