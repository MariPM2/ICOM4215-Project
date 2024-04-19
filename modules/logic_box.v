module LOGIC_BOX(
    output wire[2:0] decision_output,
    output reg if_id_reset, 
    output reg id_ex_reset,
    input reg cond_hand_out,
    input reg Jal,
    input reg JalR
    );
    
    always @(*) begin
        if (cond_hand_out) begin
            decision_output = 3'b001; // Any branch
            if_id_reset = 0;
            id_ex_reset = 1;
        end
        else if (JAL) begin
            decision_output = 3'b010; // JAL jump
            if_id_reset = 1;
            id_ex_reset = 0;
        end
        else if (JalR) begin
            decision_output = 3'b011; // JALR jump
            if_id_reset = 1;
            id_ex_reset = 0;
        end 
    end
endmodule