//----------------------------------------------------------------------//
// Module: counter
//----------------------------------------------------------------------//
// Description:
// 8-bit synchronous counter with asynchronous active-low reset,
// synchronous enable, and synchronous active-high clear.
// Generates a single-cycle overflow pulse.
// Based on Homework 2 specification.
//----------------------------------------------------------------------//
module counter (
    input             clk,        
    input             rst_n,      
    input             count_en,   
    input             count_clr,  
    output reg [7:0]  count,      
    output reg        overflow    
);

reg [7:0] count_next;

// Sequential logic for counter value
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count <= 8'h00; 
    end else begin
        count <= count_next; 
    end
end

// Combinational logic for next state and overflow
always @(*) begin
    overflow = 1'b0; 
    if (count_clr) begin
        count_next = 8'h00; 
    end else if (count_en) begin
        if (count == 8'hFF) begin
            count_next = 8'h00; 
            overflow = 1'b1;   
        end else begin
            count_next = count + 1; 
        end
    end else begin
        count_next = count; 
    end
end

endmodule 