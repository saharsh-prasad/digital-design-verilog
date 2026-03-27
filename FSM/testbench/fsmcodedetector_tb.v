module tb_code_detector;
    reg clk, rst, s, r, g, b;
    wire u, a;

    codedetector uut (.clk(clk), .reset(rst), .s(s), .r(r), .g(g), .b(b), .a(a),.output_signal(u));

    initial clk = 0;
    always #5 clk = ~clk;   //clock signal with period of 10 time units

    task press(input ps, pr, pg, pb);
        begin
            s=ps; r=pr; g=pg; b=pb;
            @(posedge clk); #1;
            s=0; r=0; g=0; b=0;
            @(posedge clk); #1;
        end
    endtask

    initial begin
        clk=0; rst=1; s=0; r=0; g=0; b=0;
        #12; rst=0;

        // Correct sequence: s → r → b → g → r
        press(1,0,0,0); // start
        press(0,1,0,0); // red
        press(0,0,0,1); // blue
        press(0,0,1,0); // green
        press(0,1,0,0); // red → expect u=1

        #20;
        $finish;
    end

    initial begin
    $dumpfile("FSM/waveform/fsmcodedetector_tb.vcd");
    $dumpvars(0, tb_code_detector);
    $monitor("t=%0t | input s=%b r=%b g=%b b=%b | u=%b", $time, s, r, g, b, u);
    end
endmodule
