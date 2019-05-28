#include "instrutable.h"
#include <stdlib.h>

#include <string.h>


// Writes the instruction OP A B C
void writeABC(FILE* fasm, int8_t OP, int8_t A, int8_t B, int8_t C) {
    fprintf(fasm, "%02x%02x%02x%02x\n", OP, ((unsigned int) A) & 0xFF, ((unsigned int) B) & 0xFF, ((unsigned int) C) & 0xFF);
}


// Initialize an instru table with 1024 symbols, first index is 0
int instrutab_init(INSTRUTAB ** pp_instrutab) {
    *pp_instrutab = malloc(sizeof(INSTRUTAB));
/*
    if (*pp_instrutab == NULL)
        return 3;
*/
    (*pp_instrutab)->last_index = 0 ;

    return 0;

}

// Free the pointer and the memory associated to the symbol table
void instrutab_free(INSTRUTAB ** pp_instrutab){
    free(*pp_instrutab);
}


// Add a symbol to the symbol table
int instrutab_add(INSTRUTAB * p_instrutab, int8_t opcode, int8_t valA, int8_t valB, int8_t valC) {
    
    INSTRU inst ;
    inst.instr = opcode ;
    inst.valA = valA;
    inst.valB=valB;
    inst.valC=valC;
    int current_index = p_instrutab->last_index;
    p_instrutab->instrutab[current_index] = inst ;
     
    int new_index = current_index+1;
    p_instrutab->last_index = new_index;

    return new_index;

}

int get_instrutab_index(INSTRUTAB * p_instrutab){
    return p_instrutab->last_index; 
}

int patch_instru(INSTRUTAB * p_instrutab, int index, int8_t valA, int8_t valB, int8_t valC) {
    p_instrutab->instrutab[index].valA = valA;
    p_instrutab->instrutab[index].valB = valB;
    p_instrutab->instrutab[index].valC = valC;
}

INSTRU get_instru(INSTRUTAB * p_instrutab, int index){
    return p_instrutab->instrutab[index];
}

int write_to_file(INSTRUTAB*  p_instrutab, FILE* fasm){
    INSTRU tmp ;
    for (int i = 0; i < p_instrutab->last_index; i++)
    {
        tmp = get_instru(p_instrutab,i);
        writeABC(fasm,tmp.instr,tmp.valA,tmp.valB,tmp.valC);
    }
}

void tprint(INSTRUTAB* p_instrutab){
    INSTRU tmp ;
    for (int i = 0; i < p_instrutab->last_index; i++)
    {
        tmp = get_instru(p_instrutab,i);
        printf("@%d : %u - ",i,tmp.instr);
        printf("%u - ",tmp.valA);
        printf("%u - ",tmp.valB);
        printf("%u\n",tmp.valC);
    }
}
