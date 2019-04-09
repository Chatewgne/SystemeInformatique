#include "binwriter.h"

#define HIGHB(x) x>>8

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
    Instruction instruction = {OP, A, HIGHB(B), B};
    if (fwrite( &instruction , sizeof(int8_t) , 4, fasm) != 4) {
        printf("ERROR : couldn't write an instruction of type OP A B\n");
    }
}

// Writes the instruction OP A C (and A is 2 bytes <> 16 bits long)
void writeAC(FILE* fasm, int8_t OP, int16_t A, int8_t C) {
    Instruction instruction = {OP, HIGHB(A), A, C};
    if (fwrite( &instruction , sizeof(int8_t) , 4, fasm) != 4) {
        printf("ERROR : couldn't write an instruction of type OP A C\n");
    }
}