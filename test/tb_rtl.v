module b06_tb;
    logic [3:0] data;
    logic [6:0] code, code_ref;
    logic [6:0] golden [0:15];   // bang ma cung, lay tu functional_spec.md muc 4
    logic [6:0] cw     [0:15];   // tu ma do DUT sinh ra (thu trong CC-08)
    integer i, j, w, dmin;

    b06_hamming74_encoder dut(.data(data), .code(code));
    b06_reference ref_i(.data(data), .code_ref(code_ref));

    function automatic [6:0] expected(input logic [3:0] d);
        logic p1,p2,p4;
        begin
            p1=d[0]^d[1]^d[3];
            p2=d[0]^d[2]^d[3];
            p4=d[1]^d[2]^d[3];
            expected={d[3],d[2],d[1],p4,d[0],p2,p1};
        end
    endfunction

    function automatic integer popcnt7(input logic [6:0] v);
        integer k;
        begin
            popcnt7 = 0;
            for (k = 0; k < 7; k = k + 1) popcnt7 = popcnt7 + v[k];
        end
    endfunction

    task automatic check(input logic [3:0] d);
        logic [6:0] e;
        begin
            data=d; #1;
            e=expected(d);
            assert(code===e)
                else $fatal(1,"B06 mismatch data=%b code=%b exp=%b",d,code,e);
            assert(code_ref===e)
                else $fatal(1,"B06 reference mismatch data=%b",d);
            assert(code===golden[d])
                else $fatal(1,"B06 khac bang cung data=%b code=%b bang=%b",d,code,golden[d]);
        end
    endtask

    initial begin
        $dumpfile("b06_tb.vcd");
        $dumpvars(0, b06_tb);

        golden[0]=7'h00; golden[1]=7'h07; golden[2]=7'h19; golden[3]=7'h1E;
        golden[4]=7'h2A; golden[5]=7'h2D; golden[6]=7'h33; golden[7]=7'h34;
        golden[8]=7'h4B; golden[9]=7'h4C; golden[10]=7'h52; golden[11]=7'h55;
        golden[12]=7'h61; golden[13]=7'h66; golden[14]=7'h78; golden[15]=7'h7F;

        // TC-001: vet can 16 to hop (+ doi chieu bang cung)
        for (i = 0; i < 16; i = i + 1) check(i[3:0]);
        $display("B06 exhaustive 16-word Hamming(7,4) encoder validation PASS");

        // CC-08: hoi chung bang 0 voi ca 16 tu ma (INV-2..INV-4)
        for (i = 0; i < 16; i = i + 1) begin
            data = i[3:0]; #1;
            cw[i] = code;
            assert((^{code[0],code[2],code[4],code[6]}) === 1'b0)
                else $fatal(1,"CC-08: s1 khac 0, data=%b", data);
            assert((^{code[1],code[2],code[5],code[6]}) === 1'b0)
                else $fatal(1,"CC-08: s2 khac 0, data=%b", data);
            assert((^{code[3],code[4],code[5],code[6]}) === 1'b0)
                else $fatal(1,"CC-08: s4 khac 0, data=%b", data);
        end
        $display("B06 CC-08 syndrome = 0 for all 16 codewords PASS");

        // CC-09: khoang cach Hamming nho nhat = 3 (INV-7), 120 cap
        dmin = 7;
        for (i = 0; i < 15; i = i + 1)
            for (j = i + 1; j < 16; j = j + 1) begin
                w = popcnt7(cw[i] ^ cw[j]);
                if (w < dmin) dmin = w;
                assert(w >= 3)
                    else $fatal(1,"CC-09: cap %0d,%0d chi cach nhau %0d bit", i, j, w);
            end
        assert(dmin == 3) else $fatal(1,"CC-09: d_min = %0d, mong doi 3", dmin);
        $display("B06 CC-09 d_min = %0d over 120 pairs PASS", dmin);

        // CC-11: tuyen tinh enc(a^b) = enc(a)^enc(b) (INV-6), moi cap
        for (i = 0; i < 16; i = i + 1)
            for (j = 0; j < 16; j = j + 1)
                assert(cw[i ^ j] === (cw[i] ^ cw[j]))
                    else $fatal(1,"CC-11: khong tuyen tinh voi a=%0d b=%0d", i, j);
        $display("B06 CC-11 linearity over 256 pairs PASS");

        // CC-12: ket qua khong phu thuoc thu tu dau vao (INV-8)
        for (i = 15; i >= 0; i = i - 1) begin
            data = i[3:0]; #1;
            assert(code === cw[i]) else $fatal(1,"CC-12: thu tu nguoc, data=%0d", i);
        end
        for (i = 0; i < 16; i = i + 1) begin
            j = (5*i + 3) % 16;
            data = j[3:0]; #1;
            assert(code === cw[j]) else $fatal(1,"CC-12: thu tu hoan vi, data=%0d", j);
        end
        $display("B06 CC-12 order independence PASS");

        // CC-10: ca bien X, mach khong duoc che giau X
        data = 4'bxxxx; #1;
        assert(code === 7'bxxxxxxx)
            else $fatal(1,"CC-10: dau vao X nhung code=%b", code);
        data = 4'b0000; #1;
        $display("B06 CC-10 X-propagation PASS");

        $display("B06 extended checks CC-08..CC-12 PASS");
        $finish;
    end
endmodule
