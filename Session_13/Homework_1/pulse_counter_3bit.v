module pulse_counter_3bit (
    input             clk,       
    input             rst_n,      
    input             pulse,      
    input             count_clr,  
    output reg [2:0]  count,      
    output reg        overflow    
);

reg [2:0] count_next;
reg       overflow_next;

// Sequential logic for counter value and overflow pulse 
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count    <= 3'h0; 
        overflow <= 1'b0; 
    end else begin
        count    <= count_next; 
        overflow <= overflow_next; 
    end
end

// Combinational logic for next state and overflow 
always @(*) begin
    overflow_next = 1'b0; 
    if (count_clr) begin
        count_next = 3'h0; 
    end else if (pulse) begin 
        if (count == 3'b111) begin 
            count_next = 3'h0; 
            overflow_next = 1'b1;   
        end else begin
            count_next = count + 1; 
        end
    end else begin
        count_next = count; 
    end
end

endmodule 