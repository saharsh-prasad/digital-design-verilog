module tb_code_detector;
    reg clk, rst, s, r, g, b;
    wire u, a;

    codedetector uut (.clk(clk), .reset(rst), .s(s), .r(r), .g(g), .b(b), .a(a),.unlock(u));

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

integer pass_count, fail_count;
initial begin
    $dumpfile("FSM/waveform/fsm_sim.vcd");
    $dumpvars(0, tb_code_detector);
end 
initial begin
        pass_count = 0;
        fail_count = 0;
        rst=1; {s,r,g,b} = 0;
        @(posedge clk); #1; rst=0;
  // Test 1: Correct sequence 
        $display("Test 1: Correct sequence");
        press(1,0,0,0); // s
        press(0,1,0,0); // r
        press(0,0,0,1); // b
        press(0,0,1,0); // g
        press(0,1,0,0); // r
        @(posedge clk); #1;
        if (u==1) begin
            $display("Test 1 PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 1 FAIL: got u=%b", u);
            fail_count = fail_count + 1;
        end

        // Test 2: Lockout after 3 wrong attempts
        $display("Test 2: Lockout after 3 wrong attempts");
        rst=1; @(posedge clk); #1; rst=0;

        press(1,0,0,0); press(0,0,1,0); // wrong — count=1
        press(1,0,0,0); press(0,0,0,1); // wrong — count=2
        press(1,0,0,0); press(0,0,1,0); // wrong — count=3 → LOCKED

        press(1,0,0,0); press(0,1,0,0);
        press(0,0,0,1); press(0,0,1,0);
        press(0,1,0,0);
        @(posedge clk); #1;
        if (u==0) begin
            $display("Test 2 PASS: Locked correctly");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 2 FAIL: got u=%b", u);
            fail_count = fail_count + 1;
        end

        // Test 3: Reset verification
        $display("Test 3: Reset escapes locked state");
        rst=1; @(posedge clk); #1; rst=0;

        press(1,0,0,0); press(0,1,0,0);
        press(0,0,0,1); press(0,0,1,0);
        press(0,1,0,0);
        @(posedge clk); #1;
        if (u==1) begin
            $display("Test 3 PASS: Reset works");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 3 FAIL: got u=%b", u);
            fail_count = fail_count + 1;
        end

        // Results 
        $display("PASSED : %0d", pass_count);
        $display("FAILED : %0d", fail_count);
        if (fail_count==0) $display("ALL TESTS PASSED");
        else               $display("SOME TESTS FAILED");
        #20; $finish;
end
endmodule   
