`default_nettype none

module b06_hamming74_encoder (
    input  wire [3:0] data,
    output wire [6:0] code
);
    wire p1 = data[0] ^ data[1] ^ data[3];
    wire p2 = data[0] ^ data[2] ^ data[3];
    wire p4 = data[1] ^ data[2] ^ data[3];
    // code[0..6] = vi tri Hamming 1..7
    assign code = {data[3], data[2], data[1], p4, data[0], p2, p1};
endmodule

module tt_um_eee703128_24100688 (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);
    wire [6:0] code;
    b06_hamming74_encoder enc (.data(ui_in[3:0]), .code(code));

    assign uo_out  = {1'b0, code};
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    wire _unused = &{ena, clk, rst_n, uio_in, ui_in[7:4], 1'b0};
endmodule

`default_nettype wire
