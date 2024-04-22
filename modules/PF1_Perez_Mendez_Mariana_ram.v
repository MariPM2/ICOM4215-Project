/*
    512 RAM module by Mariana Pérez
*/

module ram (output reg [31:0] DataOut, input Enable, ReadWrite, SE, input [8:0] Address, input [31:0] DataIn, input [1:0] Size);

    reg [7:0] Mem[0:511]; //512 localizaciones de 8 bits
    
    always @(Enable, ReadWrite, SE, Address, DataIn, Size) begin
    if(Enable)
        if(!ReadWrite)begin // READING:
            case (Size)
                2'b00:  begin
                            if (SE) begin
                                // Read Byte with sign
                                if (Mem[Address][7] == 1'b1) begin
                                    DataOut = {24'b111111111111111111111111, Mem[Address]}; // negative
                                end
                                else begin
                                    DataOut = {24'b0, Mem[Address]}; // positive
                                end
                            end
                            else begin
                                // Read Byte without sign
                                DataOut = {24'b0, Mem[Address]};
                            end
                        end
                2'b01: begin
                            if(SE)begin
                                // Read Half-word with sign
                                if (Mem[Address+1][7] == 1'b1) begin
                                    DataOut = {16'b1111111111111111, Mem[Address+1], Mem[Address]}; //negative
                                end
                                else begin
                                    DataOut = {16'b0, Mem[Address+1],Mem[Address]}; //positive
                                end
                            end
                            else begin
                                // Read Half-word without sign
                                DataOut = {16'b0, Mem[Address+1], Mem[Address]}; 
                            end
                        end
                2'b10: DataOut = {Mem[Address+3], Mem[Address+2], Mem[Address+1], Mem[Address]}; // Same as 2'b10
                2'b11: DataOut = {Mem[Address+3], Mem[Address+2], Mem[Address+1], Mem[Address]}; // Same as 2'b11
            endcase
        end
        else begin //WRITING
            case(Size)
                2'b00: Mem[Address] = DataIn[7:0];
                2'b01: begin
                            Mem[Address] = DataIn[7:0];
                            Mem[Address + 1] = DataIn[15:8];
                       end
                2'b10: begin
                            Mem[Address] = DataIn[7:0];
                            Mem[Address + 1] = DataIn[15:8];
                            Mem[Address + 2] = DataIn[23:16];
                            Mem[Address + 3] = DataIn[31:24]; 
                       end
                2'b11: begin
                            Mem[Address] = DataIn[7:0];
                            Mem[Address + 1] = DataIn[15:8];
                            Mem[Address + 2] = DataIn[23:16];
                            Mem[Address + 3] = DataIn[31:24]; 
                       end
            endcase

        end

    end


endmodule