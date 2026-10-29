`timescale 1ns/1ps

// Behavioral model for the Sky130 XOR3 cell used by this netlist.
// Functional simulation only; not a transistor-level model.
module sky130_fd_sc_hd__xor3_1 (
    input A,
    input B,
    input C,
    output X
);
    assign X = A ^ B ^ C;
endmodule
