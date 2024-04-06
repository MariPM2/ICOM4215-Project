/*
Pipeline between IF and ID
*/
module PIPELINE_IF_ID (
    // Outputs
    output reg [31:0] instruction_out,

    // Inputs
    input[31:0] instruction,
    input reset, clk

);

    always@(posedge clk or reset) begin
       // #1;
       if(reset) begin
            instruction_out <= 32'b0;
       end
       else instruction_out <= instruction;
    end
endmodule


/*
Pipeline between ID and EX
*/
module PIPELINE_ID_EX (
    // Outputs
    output reg[20:0] EX_CONTROL_SIGNAL,

    // Inputs
    input[20:0] ID_CONTROL_SIGNAL,
    input wire reset, clk
    
    // input wire [2:0] ID_Shift_IMM,
    // input wire [3:0] ID_ALU_OP,
    // input wire ID_LOAD_INSTR,
    // input wire ID_RF_ENABLE,
    // input wire ID_BRANCH_ENABLE,
    // input wire ID_JUMP_ENABLE,
    // input wire ID_HI_ENABLE,
    // input wire ID_LO_ENABLE,
    // input wire [1:0] ID_SIZE,
    // input wire ID_MEM_DATA_SE,
    // input wire ID_MEM_DATA_RW,
    // input wire ID_MEM_DATA_ENABLE,
    // input wire ID_PC_PLUS_EIGHT_ENABLE,

    // output reg[2:0] EX_Shift_IMM,           
    // output reg[3:0] EX_ALU_OP,              
    // output reg EX_LOAD_INSTR,               
    // output reg EX_RF_ENABLE,                
    // output reg EX_BRANCH_ENABLE,            
    // output reg EX_JUMP_ENABLE,              
    // output reg EX_HI_ENABLE,                
    // output reg EX_LO_ENABLE,                
    // output reg[1:0] EX_SIZE,                
    // output reg EX_MEM_DATA_SE,              
    // output reg EX_MEM_DATA_RW,              
    // output reg EX_MEM_DATA_ENABLE,          
    // output reg EX_PC_PLUS_EIGHT_ENABLE
);

    always@(posedge clk or reset) begin
       // #1;
       if(reset) begin
            EX_CONTROL_SIGNAL <= 20'b0;
       end
       else EX_CONTROL_SIGNAL <= ID_CONTROL_SIGNAL;
    end
    
    // always@(posedge clk or posedge reset) begin
    //     if(reset) begin
    //         EX_CONTROL_SIGNAL = 20'b0;
    //         // EX_Shift_IMM                <= 3'b0;
    //         // EX_ALU_OP                   <= 4'b0;
    //         // EX_LOAD_INSTR               <= 1'b0;
    //         // EX_RF_ENABLE                <= 1'b0;
    //         // EX_BRANCH_ENABLE            <= 1'b0;
    //         // EX_JUMP_ENABLE              <= 1'b0;
    //         // EX_HI_ENABLE                <= 1'b0;
    //         // EX_LO_ENABLE                <= 1'b0;
    //         // EX_SIZE                     <= 2'b0;
    //         // EX_MEM_DATA_SE              <= 1'b0;
    //         // EX_MEM_DATA_RW              <= 1'b0;
    //         // EX_MEM_DATA_ENABLE          <= 1'b0;
    //         // EX_PC_PLUS_EIGHT_ENABLE     <= 1'b0; 
    //     end 
    //     else begin
    //         EX_CONTROL_SIGNAL = ID_CONTROL_SIGNAL;
    //         // EX_Shift_IMM                <= ID_Shift_IMM;
    //         // EX_ALU_OP                   <= ID_ALU_OP;
    //         // EX_LOAD_INSTR               <= ID_LOAD_INSTR;
    //         // EX_RF_ENABLE                <= ID_RF_ENABLE;
    //         // EX_BRANCH_ENABLE            <= ID_BRANCH_ENABLE;
    //         // EX_JUMP_ENABLE              <= ID_JUMP_ENABLE;
    //         // EX_HI_ENABLE                <= ID_HI_ENABLE;
    //         // EX_LO_ENABLE                <= ID_LO_ENABLE;
    //         // EX_SIZE                     <= ID_SIZE;
    //         // EX_MEM_DATA_SE              <= ID_MEM_DATA_SE;
    //         // EX_MEM_DATA_RW              <= ID_MEM_DATA_RW;
    //         // EX_MEM_DATA_ENABLE          <= ID_MEM_DATA_ENABLE;
    //         // EX_PC_PLUS_EIGHT_ENABLE     <= ID_PC_PLUS_EIGHT_ENABLE;
    //     end
    // end
endmodule

/*
Pipeline between EX and MEM
*/
module PIPELINE_EX_MEM (
    // Outputs
    output reg[20:0] MEM_CONTROL_SIGNAL,

    // Inputs
    input[20:0] EX_CONTROL_SIGNAL,
    input reset, clk

    // input wire EX_LOAD_INSTR,
    // input wire EX_RF_ENABLE,                 
    // input wire EX_JUMP_ENABLE,
    // input wire EX_HI_ENABLE,                 
    // input wire EX_LO_ENABLE,                 
    // input wire [1:0] EX_SIZE,
    // input wire EX_MEM_DATA_SE,
    // input wire EX_MEM_DATA_RW,
    // input wire EX_MEM_DATA_ENABLE,
    // input wire EX_PC_PLUS_EIGHT_ENABLE,

    // output reg MEM_LOAD_INSTR,
    // output reg MEM_RF_ENABLE,
    // output reg MEM_JUMP_ENABLE,
    // output reg MEM_HI_ENABLE,
    // output reg MEM_LO_ENABLE,
    // output reg [1:0] MEM_SIZE,
    // output reg MEM_MEM_DATA_SE,
    // output reg MEM_MEM_DATA_RW,
    // output reg MEM_MEM_DATA_ENABLE,
    // output reg MEM_PC_PLUS_EIGHT_ENABLE,  

);

    always@(posedge clk or reset) begin
       // #1;
       if(reset) begin
            MEM_CONTROL_SIGNAL <= 20'b0;
       end
       else MEM_CONTROL_SIGNAL <= EX_CONTROL_SIGNAL;
    end


    //always@(posedge clk or posedge reset) begin
    //    if(reset) begin
    //        MEM_CONTROL_SIGNAL <= 20'b0;
            // MEM_LOAD_INSTR               <= 1'b0;
            // MEM_RF_ENABLE                <= 1'b0;
            // MEM_JUMP_ENABLE              <= 1'b0;
            // MEM_HI_ENABLE                <= 1'b0;
            // MEM_LO_ENABLE                <= 1'b0;
            // MEM_SIZE                     <= 2'b0;
            // MEM_MEM_DATA_SE              <= 1'b0;
            // MEM_MEM_DATA_RW              <= 1'b0;
            // MEM_MEM_DATA_ENABLE          <= 1'b0;
            // MEM_PC_PLUS_EIGHT_ENABLE     <= 1'b0;
    //    end 
    //    else begin
    //        MEM_CONTROL_SIGNAL = EX_CONTROL_SIGNAL;
            // MEM_LOAD_INSTR               <= EX_LOAD_INSTR;
            // MEM_RF_ENABLE                <= EX_RF_ENABLE;
            // MEM_JUMP_ENABLE              <= EX_JUMP_ENABLE;
            // MEM_HI_ENABLE                <= EX_HI_ENABLE;
            // MEM_LO_ENABLE                <= EX_LO_ENABLE;
            // MEM_SIZE                     <= EX_SIZE;
            // MEM_MEM_DATA_SE              <= EX_MEM_DATA_SE;
            // MEM_MEM_DATA_RW              <= EX_MEM_DATA_RW;
            // MEM_MEM_DATA_ENABLE          <= EX_MEM_DATA_ENABLE;
            // MEM_PC_PLUS_EIGHT_ENABLE     <= EX_PC_PLUS_EIGHT_ENABLE;
    //    end
    //end
endmodule

/*
Pipeline between MEM and WB
*/
module PIPELINE_MEM_WB (
    // Outputs
    output reg[20:0] WB_CONTROL_SIGNAL,

    // Inputs
    input[20:0] MEM_CONTROL_SIGNAL,
    input reset, clk
    
    // input wire MEM_RF_ENABLE,
    // input wire MEM_HI_ENABLE,
    // input wire MEM_HI_ENABLE,

    // output reg WB_RF_ENABLE,
    // output reg WB_HI_ENABLE,
    // output reg WB_LO_ENABLE,

);

    always@(posedge clk or reset) begin
       // #1;
       if(reset) begin
            WB_CONTROL_SIGNAL <= 20'b0;
       end
       else WB_CONTROL_SIGNAL <= MEM_CONTROL_SIGNAL;
    end
endmodule