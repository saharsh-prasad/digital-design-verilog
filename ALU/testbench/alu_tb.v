`timescale 1ns/1ns
module alutest;
   parameter width=16;
   reg signed [width-1:0] x,y;
   wire [width-1:0] z, z_high;
   wire s,p,c,zero,overflow;
   reg [2:0] ALUControl;
   alu A (.X(x), .Y(y), .Z(z), .Z_high(z_high), .P(p), .C(c), .Zero(zero), .S(s), .Overflow(overflow), .ALUControl(ALUControl));
integer i;
reg signed [width-1:0] expected_z, expected_z_high;
reg expected_c, expected_zero;
reg signed [2*width-1:0] expected_mul;
initial
begin
    $dumpfile("ALU/waveform/alu_sim.vcd");
    $dumpvars(0,alutest);
    for (i=0;i<50;i=i+1) begin
        x=$random;
        y=$random;
        ALUControl=$urandom_range(0,5);
        #5;
        //verification
        case(ALUControl)
        3'b000: {expected_c, expected_z} = x + y; // ADD
        3'b001: {expected_c, expected_z} = x + (~y + 1'b1); // SUB
        3'b010: expected_z = x & y; // AND
        3'b011: expected_z = x | y; // OR
        3'b100: expected_z = (x<y)? {{(width-1){1'b0}},1'b1}:{(width){1'b0}}; // SLT
        3'b101: begin
                    expected_mul = x * y; // MUL
                    expected_z = expected_mul[width-1:0];
                    expected_z_high = expected_mul[2*width-1:width];
                end
        default: begin expected_z = 0; expected_c = 0; end
        endcase
        expected_zero = (expected_z == 0);
        if (z !== expected_z || zero !== expected_zero || (ALUControl == 3'b101 && z_high !== expected_z_high)) begin
            $display("ERROR at iter %0d", i);
            $display("x=%h y=%h ALU=%b", x, y, ALUControl);
           if (ALUControl == 3'b101) begin
                    $display("Expected z_high=%h z=%h, Got z_high=%h z=%h\n", expected_z_high, expected_z, z_high, z);
                end else begin
                    $display("Expected z=%h, Got z=%h\n", expected_z, z);
                end
        end
    end
    $display("Test completed");
    $finish;
end
endmodule


