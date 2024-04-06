module PC (
    output reg [31:0] pc_out,
    input [31:0] pc_in,
    input clk, LE, reset
);

    always @(posedge clk) begin
        //#1;
        if (reset) begin
            pc_out  <= 32'b0;
        end
        else if (LE) begin    
            pc_out  <= pc_in;
        end
    end
endmodule