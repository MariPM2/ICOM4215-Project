
module PC (
    output reg [31:0] pc_out,
    input [31:0] pc_in,
    input clk, LE, reset
);

    always @(posedge clk or reset) begin
        #1;
        if (reset) begin
            pc_out = 0;
        end
        else pc_out = pc_in;
    end
endmodule