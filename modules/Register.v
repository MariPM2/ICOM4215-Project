module register32 (output reg [31:0] Qs , input clk, Ld, input [31:0] Ds);


always @  (posedge clk)  
    if(Ld)       
        Qs <= Ds; 
endmodule


// module register32_test;

//     reg clk, Ld;
//     reg [31:0] Ds;

//     wire [31:0] Qs;

//     register32 R (Qs, clk, Ld, Ds);

//     always #5 clk = ~clk; 
    
//     initial begin

//         clk = 0;
//         Ld = 0;
//         Ds = 32'h0000000;
//         #10;

//         Ld = 1;
//         Ds = 32'h12345768; 
//         #10; 

//         Ld = 0;
//         Ds = 32'h11111111; 
//         #10; 

//         $finish;
//     end
   
//     always @(posedge clk) begin
//         $display( "clk Ld  Qs       Ds");
//         $monitor("%b   %b   %h %h",clk , Ld, Qs, Ds);
//     end

// endmodule
