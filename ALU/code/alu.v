module alu(
input signed [width-1:0] X,Y,
input [2:0] ALUControl,
output reg [width-1:0] Z,
output reg [width-1:0] Z_high, // higher bits of multiplication
output S,P,Zero,Overflow,
output reg C);

parameter width=16;
parameter ADD=3'b000, SUB=3'b001, AND=3'b010, OR=3'b011, SLT=3'b100, MUL=3'b101;

reg signed [2*width-1:0] expected_mul; // to hold the full signed result of multiplication
always @(*) begin
    Z=0;
    Z_high=0;
    C=0;
    case(ALUControl)
    ADD: {C,Z}={1'b0,X}+{1'b0,Y}; // extended addition
    SUB:{C,Z}= {1'b0,X}+{1'b0,~Y}+1'b1; // extended two's complement subtraction
    AND: Z=X&Y;
    OR: Z=X|Y;
    SLT: Z=(X<Y)? {{(width-1){1'b0}},1'b1}:{(width){1'b0}};
    MUL: begin
            expected_mul = X * Y; // full multiplication result
            Z = expected_mul[width-1:0]; // lower bits
            Z_high = expected_mul[2*width-1:width]; // higher bits
        end
    endcase
end
assign Zero=~|Z;
assign S=Z[width-1];  //MSB(sign)
assign P=~^Z;         //even parity
assign Overflow=(ALUControl==ADD)?((X[width-1] == Y[width-1]) && (Z[width-1] != X[width-1])):     
                (ALUControl==SUB)?((X[width-1] != Y[width-1]) && (Z[width-1] != X[width-1])):
                1'b0; //for other operations, overflow is not defined
endmodule
