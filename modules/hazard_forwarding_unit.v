module HAZARD_FORWARDING_UNIT (
    output reg[1:0] pa_selector, pb_selector,
    output reg load_enable, pc_enable, nop_signal,  
    input wire[4:0] ex_destination, mem_destination, wb_destination,
    input wire[4:0] id_rs1, id_rs2,
    input wire ex_rf_enable, mem_rf_enable, wb_rf_enable, ex_load_instruction,
    input wire[1:0] source_registers_signal
);

    //Default values
    reg[1:0] pa_selector_val;
    reg[1:0] pb_selector_val;
    reg load_enable_val;
    reg pc_enable_val;
    reg nop_signal_val;

    always @(*) begin

            pa_selector_val = 2'b00;
            pb_selector_val = 2'b00;
            load_enable_val = 1'b1;
            pc_enable_val = 1'b1;
            nop_signal_val = 1'b0;

        case (source_registers_signal)
        2'b00: begin // Instrucciones sin registros fuente

            if (ex_load_instruction && (id_rs1 == ex_destination || id_rs2 == ex_destination)) begin
                load_enable_val = 1'b0;
                pc_enable_val = 1'b0;
                nop_signal_val = 1'b1;
            end
              
        end
        2'b01: begin // Instrucciones con un registro fuente
            if (ex_load_instruction && (id_rs1 == ex_destination)) begin
                load_enable_val = 1'b0;
                pc_enable_val = 1'b0;
                nop_signal_val = 1'b1;
            end 
            else begin
                if (ex_rf_enable && (id_rs1 == ex_destination))
                    pa_selector_val = 2'b01;
                else if (mem_rf_enable && (id_rs1 == mem_destination))
                    pa_selector_val = 2'b10;
                else if (wb_rf_enable && (id_rs1 == wb_destination))
                    pa_selector_val = 2'b11;
                else
                    pa_selector_val = 2'b00;
            end

            // pb_selector_val = 2'b00; 
        end
        2'b10: begin // Instrucciones con dos registros fuente
            if (ex_load_instruction && (id_rs1 == ex_destination || id_rs2 == ex_destination)) begin
                load_enable_val = 1'b0;
                pc_enable_val = 1'b0;
                nop_signal_val = 1'b1;
            end 
            else begin

                if (ex_rf_enable && (id_rs1 == ex_destination))
                    pa_selector_val = 2'b01;
                else if (mem_rf_enable && (id_rs1 == mem_destination))
                    pa_selector_val = 2'b10;
                else if (wb_rf_enable && (id_rs1 == wb_destination))
                    pa_selector_val = 2'b11;
                else
                    pa_selector_val = 2'b00;

                if (ex_rf_enable && (id_rs2 == ex_destination))
                    pb_selector_val = 2'b01;
                else if (mem_rf_enable && (id_rs2 == mem_destination))
                    pb_selector_val = 2'b10;
                else if (wb_rf_enable && (id_rs2 == wb_destination))
                    pb_selector_val = 2'b11;
                else
                    pb_selector_val = 2'b00;
            end
        end
        
        
    endcase

    pa_selector <= pa_selector_val;
    pb_selector <= pb_selector_val;
    load_enable <= load_enable_val;
    pc_enable <= pc_enable_val; 
    nop_signal <= nop_signal_val;
    end
endmodule


// Diego Aviles:

// module HAZARD_FORWARDING_UNIT (
//     output reg[1:0] pa_selector, pb_selector,
//     output reg load_enable, pc_enable, nop_signal,  
//     input wire[4:0] ex_destination, mem_destination, wb_destination,
//     input wire[4:0] id_rs1, id_rs2,
//     input wire ex_rf_enable, mem_rf_enable, wb_rf_enable, ex_load_instruction,
//     input wire[1:0] source_registers_signal
// );

//     //Default values
//     reg[1:0] pa_selector_val;
//     reg[1:0] pb_selector_val;
//     reg load_enable_val;
//     reg pc_enable_val;
//     reg nop_signal_val;

//     always @(*) begin

//             pa_selector_val = 2'b00;
//             pb_selector_val = 2'b00;
//             load_enable_val = 1'b1;
//             pc_enable_val = 1'b1;
//             nop_signal_val = 1'b0;

//         case (source_registers_signal)
//         // 2'b00: begin // Instrucciones sin registros fuente

//         //       if (ex_load_instruction && (id_rs1 == ex_destination)) begin
//         //         load_enable_val = 1'b0;
//         //         pc_enable_val = 1'b0;
//         //         nop_signal_val = 1'b1;
//         //     end
              
//         // end
//         2'b01: begin // Instrucciones con un registro fuente
//             if (ex_load_instruction && (id_rs1 == ex_destination)) begin
//                 load_enable_val = 1'b0;
//                 pc_enable_val = 1'b0;
//                 nop_signal_val = 1'b1;
//             end 
//             // else begin
//                 if (ex_rf_enable && (id_rs1 == ex_destination))
//                     pa_selector_val = 2'b01;
//                 else if (mem_rf_enable && (id_rs1 == mem_destination))
//                     pa_selector_val = 2'b10;
//                 else if (wb_rf_enable && (id_rs1 == wb_destination))
//                     pa_selector_val = 2'b11;
//                 else
//                     pa_selector_val = 2'b00;
//             // end

//             // pb_selector_val = 2'b00; 
//         end
//         2'b10: begin // Instrucciones con dos registros fuente
//             if (ex_load_instruction && (id_rs1 == ex_destination)) begin
//                 load_enable_val = 1'b0;
//                 pc_enable_val = 1'b0;
//                 nop_signal_val = 1'b1;
//             end 

//             if (ex_load_instruction && (id_rs2 == ex_destination)) begin
//                 load_enable_val = 1'b0;
//                 pc_enable_val = 1'b0;
//                 nop_signal_val = 1'b1;
//             end 
//             // else begin

//             if (ex_rf_enable && (id_rs1 == ex_destination))
//                 pa_selector_val = 2'b01;
//             else if (mem_rf_enable && (id_rs1 == mem_destination))
//                 pa_selector_val = 2'b10;
//             else if (wb_rf_enable && (id_rs1 == wb_destination))
//                 pa_selector_val = 2'b11;
//             else
//                 pa_selector_val = 2'b00;

//             if (ex_rf_enable && (id_rs2 == ex_destination))
//                 pb_selector_val = 2'b01;
//             else if (mem_rf_enable && (id_rs2 == mem_destination))
//                 pb_selector_val = 2'b10;
//             else if (wb_rf_enable && (id_rs2 == wb_destination))
//                 pb_selector_val = 2'b11;
//             else
//                 pb_selector_val = 2'b00;
//             // end
//         end
        
        
//     endcase

//     pa_selector <= pa_selector_val;
//     pb_selector <= pb_selector_val;
//     load_enable <= load_enable_val;
//     pc_enable <= pc_enable_val; 
//     nop_signal <= nop_signal_val;
//     end
// endmodule

// Mariana:

// module HAZARD_FORWARDING_UNIT (
//     output reg[1:0] pa_selector, pb_selector,
//     output reg load_enable, pc_enable, nop_signal,  
//     input wire[4:0] ex_destination, mem_destination, wb_destination,
//     input wire[4:0] id_rs1, id_rs2,
//     input wire ex_rf_enable, mem_rf_enable, wb_rf_enable, ex_load_instruction,
//     input [1:0] source_registers_signal
// );

//     //Default values
//     reg[1:0] pa_selector_val;
//     reg[1:0] pb_selector_val;
//     reg load_enable_val;
//     reg pc_enable_val;
//     reg nop_signal_val;

//     always @(*) begin

//         pa_selector_val = 2'b00;
//         pb_selector_val = 2'b00;
//         load_enable_val = 1'b1;
//         pc_enable_val = 1'b1;
//         nop_signal_val = 1'b0;

      
//         if (source_registers_signal != 2'b00) begin
//             //Load Data hazard
//             // $display("Hola");
//             if (ex_load_instruction && (id_rs1 == ex_destination)) begin
//                 load_enable_val = 1'b0;
//                 pc_enable_val = 1'b0;
//                 nop_signal_val = 1'b1;
//             end
//             // else begin
//                 //PA selector designation
//                 if (ex_rf_enable && (id_rs1 == ex_destination)) begin
//                     pa_selector_val = 2'b01;
//                 end
//                 else if (mem_rf_enable && (id_rs1 == mem_destination)) begin
//                     pa_selector_val = 2'b10;
//                 end
//                 else if (wb_rf_enable && (id_rs1 == wb_destination)) begin
//                     pa_selector_val = 2'b11;
//                 end
//                 else pa_selector_val = 2'b00;
//             // end
//         end

//         if (source_registers_signal == 2'b10) begin
//             //Load Data hazard
//             // $display("Hola2");
//             if (ex_load_instruction && (id_rs2 == ex_destination)) begin
//                 load_enable_val = 1'b0;
//                 pc_enable_val = 1'b0;
//                 nop_signal_val = 1'b1;
//             end
//             //PB selector designation
//             // else begin
//                 if (ex_rf_enable && (id_rs2 == ex_destination)) begin
//                     pb_selector_val = 2'b01;
//                 end
//                 else if (mem_rf_enable && (id_rs2 == mem_destination)) begin
//                     pb_selector_val = 2'b10;
//                 end
//                 else if (wb_rf_enable && (id_rs2 == wb_destination)) begin
//                     pb_selector_val = 2'b11;
//                 end
//                 else pb_selector_val = 2'b00;
//             // end
//         end

//         pa_selector <= pa_selector_val;
//         pb_selector <= pb_selector_val;
//         load_enable <= load_enable_val;
//         pc_enable <= pc_enable_val; 
//         nop_signal <= nop_signal_val;
//     end
// endmodule

// OG:

        // pa_selector_val = 2'b00;
        // pb_selector_val = 2'b00;
        // load_enable_val = 1'b1;
        // pc_enable_val = 1'b1;
        // nop_signal_val = 1'b0;
      
        // //Load Data hazard
        // if (ex_load_instruction && (id_rs1 == ex_destination)) begin
        //     load_enable_val = 1'b0;
        //     pc_enable_val = 1'b0;
        //     nop_signal_val = 1'b1;
        // end
        // else begin
        //      //PA selector designation
        //     if (ex_rf_enable && (id_rs1 == ex_destination)) begin
        //         pa_selector_val = 2'b01;
        //     end
        //     else if (mem_rf_enable && (id_rs1 == mem_destination)) begin
        //         pa_selector_val = 2'b10;
        //     end
        //     else if (wb_rf_enable && (id_rs1 == wb_destination)) begin
        //         pa_selector_val = 2'b11;
        //     end

        //     //PB selector designation
        //     if (ex_rf_enable && (id_rs2 == ex_destination)) begin
        //         pb_selector_val = 2'b01;
        //     end
        //     else if (mem_rf_enable && (id_rs2 == mem_destination)) begin
        //         pb_selector_val = 2'b10;
        //     end
        //     else if (wb_rf_enable && (id_rs2 == wb_destination)) begin
        //         pb_selector_val = 2'b11;
        //     end
        //     else pb_selector_val = 2'b00;
        // end

//         pa_selector <= pa_selector_val;
//         pb_selector <= pb_selector_val;
//         load_enable <= load_enable_val;
//         pc_enable <= pc_enable_val; 
//         nop_signal <= nop_signal_val;
//     end
// endmodule