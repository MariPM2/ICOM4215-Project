/*
    512 ROM test bench by Mariana Pérez
*/

`include "../modules/ROM.v"

module rom_tb;

    // Module variables
    wire [31:0] I; //output
    reg [8:0] A; //input

    // A = 9'b0; // Initializing input in 0

    // ROM module instance
    rom rom1(I, A);


    // Reading file
    reg [31:0] data; //variable para alojamiento temporero
    integer fr, code; // declaracion variable para manejo de files

    initial begin
        fr = $fopen("../textFiles/ROMinput.txt","r"); // Opening file to read
        A = 9'b0;
        while (!$feof(fr))
        begin
            code = $fscanf(fr, "%b", data); // Reading file in binary
            rom1.Mem[A] = data;
            A += 1;
        end
        $fclose(fr); // closing file
        // $finish;
    end 

    // Printing results
    initial begin
        A = 9'b0;
        $display("--A--  |  ------I------");
        repeat(4) begin
            #1;
            $display("%d         %h", A, I);
            A += 4;
        end
    end

endmodule
