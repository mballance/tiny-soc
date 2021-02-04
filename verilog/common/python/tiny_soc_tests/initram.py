'''
Created on Jan 25, 2021

@author: mballance
'''

import cocotb
from elftools.elf.elffile import ELFFile
from elftools.elf.sections import SymbolTableSection
import pybfms
from riscv_debug_bfms.riscv_debug_bfm import RiscvDebugTraceLevel, RiscvDebugBfm
from tiny_soc_tests.ramconsole import RamConsole


@cocotb.test()
async def test(top):
    await pybfms.init()
    
    u_bram = pybfms.find_bfm(".*u_bram")
    u_dbg_bfm : RiscvDebugBfm = pybfms.find_bfm(".*u_dbg_bfm")
    
    sw_image = cocotb.plusargs["sw.image"]
    u_dbg_bfm.load_elf(sw_image)
    u_dbg_bfm.set_trace_level(RiscvDebugTraceLevel.All)

    ram_console = 0
    ram_console_sz = 0

    print("Note: loading image " + sw_image)    
    with open(sw_image, "rb") as f:
        elffile = ELFFile(f)

        symtab = elffile.get_section_by_name('.symtab')

        ram_console = symtab.get_symbol_by_name("ram_console")[0]["st_value"]
        ram_console_sz = symtab.get_symbol_by_name("CONFIG_RAM_CONSOLE_BUFFER_SIZE")[0]["st_value"]
        
        # Find the section that contains the data we need
        section = None
        for i in range(elffile.num_sections()):
            shdr = elffile._get_section_header(i)
#            print("sh_addr=" + hex(shdr['sh_addr']) + " sh_size=" + hex(shdr['sh_size']) + " flags=" + hex(shdr['sh_flags']))
#            print("  keys=" + str(shdr.keys()))
            if shdr['sh_size'] != 0 and (shdr['sh_flags'] & 0x2) == 0x2:
                section = elffile.get_section(i)
                data = section.data()
                addr = shdr['sh_addr']
                j = 0
                while j < len(data):
                    word = (data[j+0] << (8*0))
                    word |= (data[j+1] << (8*1)) if j+1 < len(data) else 0
                    word |= (data[j+2] << (8*2)) if j+2 < len(data) else 0
                    word |= (data[j+3] << (8*3)) if j+3 < len(data) else 0
#                    print("Write: " + hex(addr) + "(" + hex(int((addr & 0xFFFFF)/4)) + ") " + hex(word))
                    u_bram.write_nb(int((addr & 0xFFFFF)/4), word, 0xF)
                    addr += 4
                    j += 4    

    console = RamConsole(ram_console, ram_console_sz)
    u_dbg_bfm.add_memwrite_cb(console.memwrite)
    
    # Wait for the main function to exit
    print("--> wait main")
    await u_dbg_bfm.on_exit("main")
    print("<-- wait main")
    
    # Wait for the OS to go idle
    print("--> wait idle")
    await u_dbg_bfm.on_entry("idle")
    print("<-- wait idle")
    
