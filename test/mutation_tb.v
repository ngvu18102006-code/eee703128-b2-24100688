// Testbench cho phep thu pha mach. Bang EXP tinh tay tu phuong trinh p1,p2,p4
// (functional_spec.md muc 3-4), KHONG lay tu RTL.
module mutation_tb;
    reg  [3:0] data;
    wire [6:0] code;
    reg  [6:0] exp [0:15];
    integer d, bad;
    b06_hamming74_encoder dut(.data(data), .code(code));
    initial begin
        exp[0]=7'h00; exp[1]=7'h07; exp[2]=7'h19; exp[3]=7'h1E;
        exp[4]=7'h2A; exp[5]=7'h2D; exp[6]=7'h33; exp[7]=7'h34;
        exp[8]=7'h4B; exp[9]=7'h4C; exp[10]=7'h52; exp[11]=7'h55;
        exp[12]=7'h61; exp[13]=7'h66; exp[14]=7'h78; exp[15]=7'h7F;
        bad = 0;
        for (d = 0; d < 16; d = d + 1) begin
            data = d; #1;
            if (code !== exp[d]) begin
                bad = bad + 1;
                $display("RED data=%b code=%b exp=%b", data, code, exp[d]);
            end
        end
        $display("RESULT red=%0d/16", bad);
        $finish;
    end
endmodule
