
module PC (
    output reg [31:0] pc_out,
    input [31:0] pc_in,
    input clk, LE, reset
);

    always @(posedge clk) begin
        if (reset) begin
            // pc_out = 0;
            pc_out  <= 32'b0;
        end
        else pc_out <= pc_in;
    end
endmodule