`include "../modules/RegisterFile.v"

module RegisterFile_test;

    reg [4:0] RA, RB, RW;
    reg [31:0] PW;
    reg clk, LE;

    wire [31:0] PA, PB;

    RegisterFile RF(PA, PB, PW, RA, RB, RW, clk, LE);

    initial begin 
        clk = 1'b0; 
        forever #2 clk = ~clk;
    end 
  
    initial 
    begin 
        PW = 20;
        RW = 0; 
        RA = 0; 
        RB = 31;
        LE = 1; 
    
        #5;

        repeat(31)
        begin 
        
            PW++; 
            RW++;
            RA++;
            RB++; 
            #4;

        end
    end

    initial begin
       #150;  
        $finish;
    end

    initial begin

        $display(" RA   RB  RW          PW          PA         PB LE clk ");
        $monitor(" %d   %d  %d  %d  %d %d %d %d", RA, RB, RW, PW, PA, PB, LE, clk); 

    end
    
endmodule 
