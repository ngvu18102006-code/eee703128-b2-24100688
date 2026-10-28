import cocotb
from cocotb.triggers import Timer


@cocotb.test()
async def test_hamming74_all_inputs(dut):
    dut.clk.value = 0
    dut.ena.value = 1
    dut.rst_n.value = 1
    dut.uio_in.value = 0

    for data in range(16):
        dut.ui_in.value = data
        await Timer(2, units="ns")

        d0 = (data >> 0) & 1
        d1 = (data >> 1) & 1
        d2 = (data >> 2) & 1
        d3 = (data >> 3) & 1

        p1 = d0 ^ d1 ^ d3
        p2 = d0 ^ d2 ^ d3
        p4 = d1 ^ d2 ^ d3

        expected = (
            (d3 << 6)
            | (d2 << 5)
            | (d1 << 4)
            | (p4 << 3)
            | (d0 << 2)
            | (p2 << 1)
            | p1
        )

        actual = int(dut.uo_out.value)

        assert actual == expected, (
            f"data=0x{data:X}: expected uo_out=0x{expected:02X}, "
            f"got 0x{actual:02X}"
        )
        assert int(dut.uio_out.value) == 0, "uio_out phải bằng 0"
        assert int(dut.uio_oe.value) == 0, "uio_oe phải bằng 0"

    dut._log.info("PASS: all 16 Hamming(7,4) inputs verified")
