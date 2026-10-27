module b06_reference (
    input  logic [3:0] data,
    output logic [6:0] code_ref
);
    always_comb begin
        code_ref[0] = data[0] ^ data[1] ^ data[3];
        code_ref[1] = data[0] ^ data[2] ^ data[3];
        code_ref[2] = data[0];
        code_ref[3] = data[1] ^ data[2] ^ data[3];
        code_ref[4] = data[1];
        code_ref[5] = data[2];
        code_ref[6] = data[3];
    end
endmodule
