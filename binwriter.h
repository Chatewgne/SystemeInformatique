#include <stdio.h>
#include <stdlib.h>

// Writes the instruction OP A B C
void writeABC(FILE* fasm, int8_t OP, int8_t A, int8_t B, int8_t C);

// Writes the instruction OP A B (and B is 2 bytes <> 16 bits long)
void writeAB(FILE* fasm, int8_t OP, int8_t A, int16_t B);

// Writes the instruction OP A C (and A is 2 bytes <> 16 bits long)
void writeAC(FILE* fasm, int8_t OP, int16_t A, int8_t C);