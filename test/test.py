# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import os

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

HEX_PATH = os.path.join(os.path.dirname(__file__), "..", "src", "testmem.hex")


def load_rom(path):
    with open(path) as f:
        return [int(line, 16) for line in f if line.strip()]


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    rom = load_rom(HEX_PATH)
    assert len(rom) == 256

    for addr, expected in enumerate(rom):
        dut.uio_in.value = addr
        await ClockCycles(dut.clk, 1)
        assert dut.uo_out.value == expected, (
            f"addr {addr:#04x}: got {int(dut.uo_out.value):#04x}, expected {expected:#04x}"
        )
