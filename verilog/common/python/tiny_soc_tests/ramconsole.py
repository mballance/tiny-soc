'''
Created on Jan 26, 2021

@author: mballance
'''

class RamConsole(object):
    
    def __init__(self, start, size):
        self.start = start
        self.size = size
        self.line = ""
        
    def memwrite(self, addr, data, sel):
        if addr >= self.start and addr < (self.start+self.size):
            for i in range(4):
                if sel & (1 << i) != 0:
                    db = (data >> 8*i) & 0xFF
                    if db != 0x0:
                        if db == 0xa:
                            print("# " + self.line)
                            self.line = ""
                        else:
                            self.line += "%c" % (db,)
                    
                    