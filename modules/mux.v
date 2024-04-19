// Verified :)

module CONTROL_UNIT_MUX (
    output reg[20:0] out_id_signal,
    input[20:0] in_id_signal,
    input wire nop_signal
);

    always @(*) begin
        if (nop_signal) begin
            out_id_signal = 21'b0;
        end
        else begin
            out_id_signal = in_id_signal;
        end
    end
endmodule