`timescale 1ns/1ps
`default_nettype none

module tb (
    input  wire       clk,
    input  wire       ena,
    input  wire       rst_n,
    input  wire [7:0] ui_in,
    input  wire [7:0] uio_in,
    output wire [7:0] uo_out,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe
);

    supply1 VPWR;
    supply0 VGND;

    tt_um_eee703128_24100688 dut (
        .clk(clk),
        .ena(ena),
        .rst_n(rst_n),
        .ui_in(ui_in),
        .uio_in(uio_in),
        .uo_out(uo_out),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .VPWR(VPWR),
        .VGND(VGND)
    );

endmodule

`default_nettype wire
