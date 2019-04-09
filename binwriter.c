#include "binwriter.h"

typedef struct {
    int8_t OP;
    int8_t A;
    int8_t B;
    int8_t C;
}Instruction;

// Writes the instruction OP A B C
void writeABC(FILE* fasm, int8_t OP, int8_t A, int8_t B, int8_t C) {
    Instruction instruction = {OP, A, B, C};
    if (fwrite( &instruction , sizeof(int8_t) , 4, fasm) != 4) {
        printf("ERROR : couldn't write an instruction of type OP A B C\n");
    }
}

// Writes the instruction OP A B (and B is 2 bytes <> 16 bits long)
void writeAB(FILE* fasm, int8_t OP, int8_t A, int16_t B) {
    Instruction instruction = {OP, A, 0, 0};
    if (fwrite( &instruction , sizeof(int8_t) , 2, fasm) != 2) {
        printf("ERROR : couldn't write an instruction beginning with OP A\n");
    }
    if (fwrite( &B , sizeof(B) , 1, fasm) != 1) {
        printf("ERROR : couldn't write an instruction finishing with a 2 bytes B operand\n");
    }
}

// Writes the instruction OP A C (and A is 2 bytes <> 16 bits long)
void writeAC(FILE* fasm, int8_t OP, int16_t A, int8_t C) {

    if (fwrite( &OP , sizeof(int8_t) , 1, fasm) != 1) {
        printf("ERROR : couldn't write an instruction beginning with OP\n");
    }
    if (fwrite( &A , sizeof(A) , 1, fasm) != 1) {
        printf("ERROR : couldn't write an instruction with a 2 bytes A operand\n");
    }
    if (fwrite( &C , sizeof(int8_t) , 1, fasm) != 1) {
        printf("ERROR : couldn't write an instruction finishing with a C operand (1byte)\n");
    }

}