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
);

    always@(posedge clk or reset) begin
       // #1;
       if(reset) begin
            EX_CONTROL_SIGNAL <= 20'b0;
       end
       else EX_CONTROL_SIGNAL <= ID_CONTROL_SIGNAL;
    end
    

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


);

    always@(posedge clk or reset) begin
       // #1;
       if(reset) begin
            MEM_CONTROL_SIGNAL <= 20'b0;
       end
       else MEM_CONTROL_SIGNAL <= EX_CONTROL_SIGNAL;
    end

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
);

    always@(posedge clk or reset) begin
       // #1;
       if(reset) begin
            WB_CONTROL_SIGNAL = 20'b0;
       end
       else WB_CONTROL_SIGNAL = MEM_CONTROL_SIGNAL;
    end
endmodule