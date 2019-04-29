import sys


class Instruction:
    def __init__(self, OP, A, B, C):
        self.OP = OP
        self.A = A
        self.B = B
        self.C = C

def open_file(path):
    try:
        return open(path, 'rb')
    except IOError as e:
        print(e, sys.stderr)
        return None

def parse_asm_file(file):

    instruction_table = []
    i = 0

    try:
        instruction_bytes = file.read(4)
        while instruction_bytes:
            OP, A, B, C = instruction_bytes
            instruction_table.append(Instruction(OP, A, B, C))
            i += 1
            instruction_bytes = file.read(4)

        return instruction_table
            
    except (TypeError, IndexError) as e:
        return None




if __name__ == '__main__':

    ### Open and parse the assembly file in instruction_table
    if len(sys.argv) != 2:
        print('usage: virtualtako <assemblyfile>')
        exit(1)

    file = open_file(sys.argv[1])
    if file is None:
        exit(1)
    
    instruction_table = parse_asm_file(file)
    if instruction_table is None:
        print('Could not parse file {sys.argv[1]}', sys.stderr)
        exit(1)
    

    reg = []
    memory = []

    # Instanciate registry
    for i in range(16):
        reg.append(0)

    # Instanciate memory table
    for i in range(10000):
        memory.append(0)

    inst_tab_length = len(instruction_table)
    index = 0

    ### Executes the instructions
    while index < inst_tab_length:
        inst = instruction_table[index]

        print(inst.OP, inst.A, inst.B, inst.C)
        
        if inst.OP == 1:     # ADD
            # print("Add : ", reg[inst.B], " + ", reg[inst.C])
            reg[inst.A] = reg[inst.B] + reg[inst.C]
            reg[inst.A] &= 0xffff # Only keep the 2 first bytes of the variable in order to stay closer to the real implementation

        elif inst.OP == 2:   # MUL
            # print("Mul : ", reg[inst.B], " * ", reg[inst.C])
            reg[inst.A] = reg[inst.B] * reg[inst.C]
            reg[inst.A] &= 0xffff

        elif inst.OP == 3:   # SOU
            # print("Sou : ", reg[inst.B], " - ", reg[inst.C])
            reg[inst.A] = reg[inst.B] - reg[inst.C]
            reg[inst.A] &= 0xffff

        elif inst.OP == 4:   # DIV
            # print("Div : ", reg[inst.B], " // ", reg[inst.C])
            reg[inst.A] = reg[inst.B] // reg[inst.C]
            reg[inst.A] &= 0xffff


        elif inst.OP == 5:   # COP
            reg[inst.A] = reg[inst.B]

        elif inst.OP == 6:   # AFC
            reg[inst.A] = (inst.B<<8) + inst.C

        elif inst.OP == 7:   # LOAD
            reg[inst.A] = memory[(inst.B<<8) + inst.C + 1]
            reg[inst.A] += (memory[(inst.B<<8) + inst.C]<<8)

        elif inst.OP == 8:   # STORE
            memory[(inst.A<<8) + inst.B + 1] = (reg[inst.C] & 0x00ff)
            memory[(inst.A<<8) + inst.B] = (reg[inst.C] & 0xff00)

        elif inst.OP == 9:   # EQU
            reg[inst.A] = 1 if reg[inst.B] == reg[inst.C] else 0

        elif inst.OP == 10:  # INF
            reg[inst.A] = 1 if reg[inst.B] < reg[inst.C] else 0

        elif inst.OP == 11:  # INFE
            reg[inst.A] = 1 if reg[inst.B] <= reg[inst.C] else 0

        elif inst.OP == 12:  # SUP
            reg[inst.A] = 1 if reg[inst.B] > reg[inst.C] else 0

        elif inst.OP == 13:  # SUPE
            reg[inst.A] = 1 if reg[inst.B] >= reg[inst.C] else 0


        # JUMP instructions
        if inst.OP == 14:  # JMP
            index = (inst.A<<8) + inst.B

        elif inst.OP == 15:  # JMPC
            index = (inst.A<<8) + inst.B if reg[inst.C] == 0 else (index + 1)

        else:
            index += 1

    ### End of iteration on instruction_table

    print("End of execution.\n\n")
    
    
    user_input = input("Read value from (r)eg, (m)em or (e)xit : ")

    while user_input != "e":

        if user_input == "r":
            user_input = int(input("Read value reg[?] : "))
            print("reg[", user_input, "] = ", reg[user_input])
        elif user_input == "m":
            user_input = int(input("Read value mem[?] : "))
            print("memory[", user_input, "] = ", memory[user_input])

        user_input = input("Read value from (r)eg, (m)em or (e)xit : ")
        
