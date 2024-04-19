module PB_MUX(
    output reg [31:0] pb_out,
    input wire [1:0] pb_selector,
    input wire [31:0] Ex_Rd, Mem_Rd, Wb_Rd, pb_in
);
    always @(*) begin
        case (pb_selector)
            2'b00: pb_out = pb_in;
            2'b01: pb_out = Ex_Rd;
            2'b10: pb_out = Mem_Rd;
            2'b11: pb_out = Wb_Rd;
        endcase
    end
endmodule