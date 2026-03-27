module codedetector (
    input  wire clk,
    input  wire reset,
    input  wire s, r, g, b,
    output wire a,
    output reg  output_signal
);

    localparam [2:0] S0 = 3'b000, //initial state
                     S1 = 3'b001, // s pressed
                     S2 = 3'b010, // s,r pressed
                     S3 = 3'b011, // s,r,b pressed
                     S4 = 3'b100, // s,r,b,g pressed
                     S5 = 3'b101; // success state

    reg [2:0] state, next_state;

    // "Any button pressed" flag
    assign a = s | r | g | b;

    // 1. Sequential Block: State Memory (Synchronous Reset)
    always @(posedge clk) begin
        if (reset) begin
            state <= S0; // Reset to initial state
        end else begin
            state <= next_state;
        end
    end

    // 2. Combinational Block: Next State Logic
    always @(*) begin
        // Default assignments to prevent latches
        next_state = state; 
        
        case(state)
            S0: begin
                
                if (s && !r && !g && !b) next_state = S1; // Only advance if EXACTLY 's' is pressed
                else if (a)              next_state = S0; // Any other press resets
            end
            S1: begin
                if (r && !s && !g && !b) next_state = S2;
                else if (s && !r && !g && !b) next_state = S1; 
                else if (a)              next_state = S0;
            end
            S2: begin
                if (b && !s && !r && !g) next_state = S3;
                else if (s && !r && !g && !b) next_state = S1;
                else if (a)              next_state = S0;
            end
            S3: begin
                if (g && !s && !r && !b) next_state = S4;
                else if (s && !r && !g && !b) next_state = S1;
                else if (a)              next_state = S0;
            end
            S4: begin
                if (r && !s && !g && !b) next_state = S5;
                else if (s && !r && !g && !b) next_state = S1;
                else if (a)              next_state = S0;
            end
            S5: begin
                // Wait in success state until another button is pressed
                if (s && !r && !g && !b) next_state = S1;
                else if (a)              next_state = S0;
            end
            default: next_state = S0;
        endcase
    end

    // 3. Sequential Block: Registered Output
    always @(posedge clk) begin
        if (reset) begin
            output_signal <= 1'b0;
        end else if (next_state == S5) begin
            output_signal <= 1'b1;
        end else begin
            output_signal <= 1'b0;
        end
    end

endmodule

