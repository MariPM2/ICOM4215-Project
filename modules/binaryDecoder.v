
module binaryDecoder (output reg [31:0] O, input [4:0] D,input E);

        always @ (D, E)
        begin 
                if(E == 0 )
                        O =  32'b00000000000000000000000000000000;
                else   
                    begin 
                        case (D)
                                5'b00000: O = 32'b00000000000000000000000000000001;
                                5'b00001: O = 32'b00000000000000000000000000000010;  
                                5'b00010: O = 32'b00000000000000000000000000000100;
                                5'b00011: O = 32'b00000000000000000000000000001000;
                                5'b00100: O = 32'b00000000000000000000000000010000;
                                5'b00101: O = 32'b00000000000000000000000000100000;
                                5'b00110: O = 32'b00000000000000000000000001000000;
                                5'b00111: O = 32'b00000000000000000000000010000000;
                                5'b01000: O = 32'b00000000000000000000000100000000;
                                5'b01001: O = 32'b00000000000000000000001000000000;
                                5'b01010: O = 32'b00000000000000000000010000000000;
                                5'b01011: O = 32'b00000000000000000000100000000000;
                                5'b01100: O = 32'b00000000000000000001000000000000;
                                5'b01101: O = 32'b00000000000000000010000000000000;
                                5'b01110: O = 32'b00000000000000000100000000000000;
                                5'b01111: O = 32'b00000000000000001000000000000000;
                                5'b10000: O = 32'b00000000000000010000000000000000;
                                5'b10001: O = 32'b00000000000000100000000000000000;
                                5'b10010: O = 32'b00000000000001000000000000000000;
                                5'b10011: O = 32'b00000000000010000000000000000000;
                                5'b10100: O = 32'b00000000000100000000000000000000;
                                5'b10101: O = 32'b00000000001000000000000000000000;
                                5'b10110: O = 32'b00000000010000000000000000000000;
                                5'b10111: O = 32'b00000000100000000000000000000000;
                                5'b11000: O = 32'b00000001000000000000000000000000;
                                5'b11001: O = 32'b00000010000000000000000000000000;
                                5'b11010: O = 32'b00000100000000000000000000000000;
                                5'b11011: O = 32'b00001000000000000000000000000000;
                                5'b11100: O = 32'b00010000000000000000000000000000;
                                5'b11101: O = 32'b00100000000000000000000000000000;
                                5'b11110: O = 32'b01000000000000000000000000000000;
                                5'b11111: O = 32'b10000000000000000000000000000000;
                        endcase 
                    end
        end
endmodule


// module binaryDecoder_test;
//     reg [4:0] D;
//     reg E;

//     wire [31:0] O;

//     binaryDecoder binDec (O,D,E);

//     initial begin
//         $display("D     E   O");
//         $monitor("%b %b %b", D, E, O);

//         E = 1'b1;
//         #10; 
//         D = 5'b00000;
//         #10;
//         D = 5'b00001;
//         #10;
//         D = 5'b11111;
//         #10;

//         E = 1'b0;
//         #10;
//         D = 5'b11111;
//         #10;
//         D = 5'b00000;
//         #10;
//         D = 5'b01010;
//         #10;

//         $finish;
//     end
// endmodule


