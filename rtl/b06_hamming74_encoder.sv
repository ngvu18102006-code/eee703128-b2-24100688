module b06_hamming74_encoder (
    input  logic [3:0] data,
    output logic [6:0] code
);
    logic p1, p2, p4;

    assign p1 = data[0] ^ data[1] ^ data[3];
    assign p2 = data[0] ^ data[2] ^ data[3];
    assign p4 = data[1] ^ data[2] ^ data[3];

    // code[0..6] correspond to Hamming positions 1..7.
    assign code = {data[3], data[2], data[1], p4, data[0], p2, p1};
endmodule
