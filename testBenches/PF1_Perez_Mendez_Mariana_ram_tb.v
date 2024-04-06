/*
    512 RAM test bench by Mariana Pérez
*/

`include "../modules/PF1_Perez_Mendez_Mariana_ram.v"

module RAM_tb;

    wire [31:0] DataOut;
    reg Enable, ReadWrite, SE; 
    reg [8:0] Address;
    reg [31:0] DataIn;
    reg [1:0] Size;

    
    ram ram1 (DataOut, Enable, ReadWrite, SE, Address, DataIn, Size);

    // Reading file
    integer fi, fo, code, i;
    reg [31:0] data;

    initial begin
        fi = $fopen("../textFiles/PF1_Perez_Mendez_Mariana_precharge.txt","r");
        Address = 9'b0;
        while (!$feof(fi)) begin
            code = $fscanf(fi, "%b", data);
            ram1.Mem[Address] = data;
            Address = Address + 1'b1;
        end
        $fclose(fi);
    end

    // Testing:
    initial begin

    /*
        Leer un word de las localizaciones 0, 4, 8 y 12.
    */

        Address = 9'b0;
        Enable = 1'b1;
        ReadWrite = 1'b0;
        Size = 2'b10; // Word, 2'b11 would also work here
        SE = 'bx; // Don't care
        $display("Reading a word from locations 0, 4, 8, and 12:");
        $display("R/W = %b, E = %b, SE = %b", ReadWrite, Enable, SE);

        repeat(4) begin
            #1;
            $display("Size = %b, A = %d, DO = %h", Size, Address, DataOut);
            Address = Address + 4;
        end  

    // ----------------------------------------------------------------------------------------------------------------------------------

    /*
        Leer sin signo un byte de la localización 0, un halfword de la localización 2 y un halfword de la localización 4.
    */

        Address = 9'b0;
        Enable = 1'b1;
        ReadWrite = 1'b0;
        SE = 1'b0; // unsigned

        $display("\nReading an unsigned byte from location 0, a halfword from location 2 and a halfword from location 4:");
        $display("R/W = %b, E = %b, SE = %b", ReadWrite, Enable, SE);

        // Reading an unsigned byte from location 0
        Size = 2'b00; // Byte
        #1;
        $display("Size = %b, A = %d, DO = %h", Size, Address, DataOut);

        // Reading an unsigned halfword from location 2
        Size = 2'b01; // Halfword
        Address += 2;
        #1;
        $display("Size = %b, A = %d, DO = %h", Size, Address, DataOut);

        // Reading an unsigned halfword from location 4
        Size = 2'b01; // Halfword
        Address += 2;
        #1;
        $display("Size = %b, A = %d, DO = %h", Size, Address, DataOut);

    // ----------------------------------------------------------------------------------------------------------------------------------

    /*
        Leer con signo un byte de la localización 0, un halfword de la localización 2 y un halfword de la localización 4
    */

        Address = 9'b0;
        Enable = 1'b1;
        ReadWrite = 1'b0;
        SE = 1'b1; // signed

        $display("\nReading a signed byte from location 0, a halfword from location 2 and a halfword from location 4:");
        $display("R/W = %b, E = %b, SE = %b", ReadWrite, Enable, SE);

        // Reading a signed byte from location 0
        Size = 2'b00; // Byte
        #1;
        $display("Size = %b, A = %d, DO = %h", Size, Address, DataOut);

        // Reading a signed halfword from location 2
        Size = 2'b01; // Halfword
        Address += 2;
        #1;
        $display("Size = %b, A = %d, DO = %h", Size, Address, DataOut);

        // Reading a halfword from location 4
        Size = 2'b01; // Halfword
        Address += 2;
        #1;
        $display("Size = %b, A = %d, DO = %h", Size, Address, DataOut);

    // ----------------------------------------------------------------------------------------------------------------------------------

    /*
        Escribir el byte 0xA6 en la localización 0, el halfword 0xBBDD en la localización 2, el halfword 0x5419 en la localización 4 y 
        el 0xABCDEF01 word en la localización 8.
    */
        Address = 9'b0;
        Enable = 1'b1;
        ReadWrite = 1'b1; // Write

        // Writing byte at 0:
        Size = 2'b00;
        DataIn = 32'hA6;
        #1;

        // Writing halfword at 2:
        Address += 2;
        Size = 2'b01;
        DataIn = 32'hBBDD;
        #1;

        // Writing halfword at 4:
        Address += 2;
        Size = 2'b01;
        DataIn = 32'h5419;
        #1;

        // Writing word at 8:
        Address += 4;
        Size = 2'b10;
        DataIn = 32'hABCDEF01;
        #1

        $display("\nWriting byte 0xA6 in location 0, halfword 0xBBDD in location 2, halfword 0x5419 in location 4 and 0xABCDEF01 word in location 8.");
    
    // ----------------------------------------------------------------------------------------------------------------------------------

    /*
        Leer un Word de las localizaciones 0, 4 y 8.
    */

        Address = 9'b0;
        Size = 2'b10;
        SE = 'bx;
        Enable = 1'b1;
        ReadWrite = 1'b0;

        $display("\nReading a word from locations 0, 4, and 8:");

        $display("R/W = %b, E = %b, SE = %b",ReadWrite, Enable, SE);

        repeat(3) begin
            #1;
            $display("Size = %b, A = %d, DO = %h",Size, Address,DataOut);
            Address = Address + 4;
        end

    end

endmodule
