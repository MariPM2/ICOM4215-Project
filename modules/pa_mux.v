module PA_MUX(
    output reg [31:0] pa_out,
    input wire [1:0] pa_selector,
    input wire [31:0] Ex_Rd, Mem_Rd, Wb_Rd, pa_in
);
    always @(*) begin
        case (pa_selector)
            2'b00: pa_out = pa_in;
            2'b01: pa_out = Ex_Rd;
            2'b10: pa_out = Mem_Rd;
            2'b11: pa_out = Wb_Rd;
        endcase
    end
endmodule