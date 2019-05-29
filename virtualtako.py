import sys


class Instruction:
    def __init__(self, OP, A, B, C):
        self.OP = OP
        self.A = A
        self.B = B
        self.C = C

def open_file(path):
    try:
        return open(path, 'r')
    except IOError as e:
        print(e, sys.stderr)
        return None

def parse_asm_file(file):

    instruction_table = []
    i = 0

    try:
        instruction_line = file.readline()
        while instruction_line:
            OP = int(instruction_line[slice(0,2,1)], 16)
            A = int(instruction_line[slice(2,4,1)], 16)
            B = int(instruction_line[slice(4,6,1)], 16)
            C = int(instruction_line[slice(6,8,1)], 16)
            instruction_table.append(Instruction(OP, A, B, C))
            i += 1
            instruction_line = file.readline()

        return instruction_table
            
    except (TypeError, IndexError) as e:
        return None




if __name__ == '__main__':

    ### Open and parse the assembly file in instruction_table
    if len(sys.argv) < 2 or len(sys.argv) > 3:
        print('usage: virtualtako <assemblyfile> (optional)--debug')
        exit(1)

    if len(sys.argv) == 3 :
        if sys.argv[2] != "--debug" :
            print('usage: virtualtako <assemblyfile> (optional)--debug')
            exit(1)
        else :
            debug = True
    else :
        debug = False

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

        if debug :
            print("====================")
            print("@", index, ":", inst.OP, inst.A, inst.B, inst.C)
        
        
        if inst.OP == 1:     # ADD

            if debug :
                print("ADD :\tR", inst.A, " =\tR", inst.B, "(", reg[inst.B], ")\t +\tR", inst.C, "(", reg[inst.C], ")")

            reg[inst.A] = reg[inst.B] + reg[inst.C]
            reg[inst.A] &= 0xffff # Only keep the 2 first bytes of the variable in order to stay closer to the real implementation

        elif inst.OP == 2:   # MUL

            if debug :
                print("MUL :\tR", inst.A, " =\tR", inst.B, "(", reg[inst.B], ")\t *\tR", inst.C, "(", reg[inst.C], ")")

            reg[inst.A] = reg[inst.B] * reg[inst.C]
            reg[inst.A] &= 0xffff

        elif inst.OP == 3:   # SOU

            if debug :
                print("SOU :\tR", inst.A, " =\tR", inst.B, "(", reg[inst.B], ")\t -\tR", inst.C, "(", reg[inst.C], ")")

            reg[inst.A] = reg[inst.B] - reg[inst.C]
            reg[inst.A] &= 0xffff

        elif inst.OP == 4:   # DIV

            if debug :
                print("DIV :\tR", inst.A, " =\tR", inst.B, "(", reg[inst.B], ")\t /\tR", inst.C, "(", reg[inst.C], ")")

            reg[inst.A] = reg[inst.B] // reg[inst.C]
            reg[inst.A] &= 0xffff


        elif inst.OP == 5:   # COP

            if debug :
                print("COP :\tR", inst.A, " <-\tR", inst.B, "(", reg[inst.B], ")")

            reg[inst.A] = reg[inst.B]

        elif inst.OP == 6:   # AFC

            if debug :
                print("AFC :\tR", inst.A, " <-\t", (inst.B<<8) + inst.C)

            reg[inst.A] = (inst.B<<8) + inst.C

        elif inst.OP == 7:   # LOAD

            if debug :
                print("LOAD :\tR", inst.A, " <-\t@", (inst.B<<8) + inst.C, "\t(", memory[(inst.B<<8) + inst.C + 1] + memory[(inst.B<<8) + inst.C]<<8, ")")

            reg[inst.A] = memory[(inst.B<<8) + inst.C + 1]
            reg[inst.A] += (memory[(inst.B<<8) + inst.C]<<8)

            if debug :
                print("In @ : ", (inst.B<<8) + inst.C + 1, "(2nd octet representing the value) : ", memory[(inst.B<<8) + inst.C + 1])
                print("In @", (inst.B<<8) + inst.C, "(1st octet representing the value) : ", memory[(inst.B<<8) + inst.C])

                print("Now R", inst.A, " = ", reg[inst.A])

        elif inst.OP == 8:   # STORE

            if debug :
                print("STORE :\t@", (inst.A<<8) + inst.B, " <-\tR", inst.C, "\t(", reg[inst.C], ")")

            memory[(inst.A<<8) + inst.B + 1] = (reg[inst.C] & 0x00ff)
            memory[(inst.A<<8) + inst.B] = (reg[inst.C] & 0xff00) >> 8

            if debug :
                print("In @ : ", (inst.A<<8) + inst.B + 1, "(2nd octet representing the value) : ", memory[(inst.A<<8) + inst.B + 1])
                print("In @", (inst.A<<8) + inst.B, "(1st octet representing the value) : ", memory[(inst.A<<8) + inst.B])

                print("Which equals when summing up : ", memory[(inst.A<<8) + inst.B + 1] + (memory[(inst.A<<8) + inst.B]<<8) )

        elif inst.OP == 9:   # EQU

            if debug :
                print("EQU :\tR", inst.A, "= 1 if\tR", inst.B, "(", reg[inst.B], ")\t =\tR", inst.C, "(", reg[inst.C], ") else 0")

            reg[inst.A] = 1 if reg[inst.B] == reg[inst.C] else 0


        elif inst.OP == 10:  # INF

            if debug :
                print("INF :\tR", inst.A, "= 1 if\tR", inst.B, "(", reg[inst.B], ")\t <\tR", inst.C, "(", reg[inst.C], ") else 0")

            reg[inst.A] = 1 if reg[inst.B] < reg[inst.C] else 0

        elif inst.OP == 11:  # INFE
        
            if debug :
                print("INFE :\tR", inst.A, "= 1 if\tR", inst.B, "(", reg[inst.B], ")\t <=\tR", inst.C, "(", reg[inst.C], ") else 0")

            reg[inst.A] = 1 if reg[inst.B] <= reg[inst.C] else 0

        elif inst.OP == 12:  # SUP

            if debug :
                print("SUP :\tR", inst.A, "= 1 if\tR", inst.B, "(", reg[inst.B], ")\t >\tR", inst.C, "(", reg[inst.C], ") else 0")

            reg[inst.A] = 1 if reg[inst.B] > reg[inst.C] else 0

        elif inst.OP == 13:  # SUPE

            if debug :
                print("SUPE :\tR", inst.A, "= 1 if\tR", inst.B, "(", reg[inst.B], ")\t >=\tR", inst.C, "(", reg[inst.C], ") else 0")

            reg[inst.A] = 1 if reg[inst.B] >= reg[inst.C] else 0


        # JUMP instructions
        if inst.OP == 14:  # JMP

            if debug :
                print("JMP :\t@", inst.A, (inst.A<<8) + inst.B)

            index = (inst.A<<8) + inst.B

        elif inst.OP == 15:  # JMPC

            if debug :
                print("JMPC :\t@", inst.A, (inst.A<<8) + inst.B, "if R", inst.C, "(", reg[inst.C], ") = 0")

            index = (inst.A<<8) + inst.B if reg[inst.C] == 0 else (index + 1)

        else:
            index += 1

    ### End of iteration on instruction_table

    if debug :
        print("====================")

    print("\nEnd of execution.\n\n")

    print("Memory table :")
    
    for i in range(4000,4020):
        print("|", i, "\t|", memory[i], "\t|")
    
    
    user_input = input("Read value from (r)eg, (m)em or (e)xit : ")

    while user_input != "e":

        if user_input == "r":
            for i in range(len(reg)):
                print("| R", i, "\t|", reg[i], "\t|")
        elif user_input == "m":
            user_input = int(input("Read value mem[?] : "))
            print("memory[", user_input, "] = ", memory[user_input])

        print("==========\n")

        user_input = input("Read value from (r)eg, (m)em or (e)xit : ")
        
