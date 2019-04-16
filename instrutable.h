#include <stdlib.h>
#include "binwriter.h"

typedef struct {
    int8_t instr ;
    int8_t valA;
    int8_t valB;
    int8_t valC;
} INSTRU ;

typedef struct{
    INSTRU instrutab[1024];
    int last_index;
} INSTRUTAB;



// Initialize a symbol table (with 1024 symbols)
// first address is 4000, return -1 if we couldn't initialize

/*  AS IT IS, you must give the address of the pointer to
    an instru table (not initialized) */
int instrutab_init(INSTRUTAB ** pp_instrutab);

// Free the pointer and the memory associated to the instru table
void instrutab_free(INSTRUTAB ** pp_instrutab);


// Add a instruction to the symbol table
int instrutab_add(INSTRUTAB * p_instrutab, int8_t opcode, int8_t valA, int8_t valB, int8_t valC);

// Returns the last_index of the table
int get_instrutab_index(INSTRUTAB * p_instrutab);

//Changes parameter values for instruction at given index in the table
int patch_instru(INSTRUTAB * p_instrutab, int index, int8_t valA, int8_t valB, int8_t valC);

//Gets instruction at given index
INSTRU get_instru(INSTRUTAB * p_instrutab, int index);

//writes the whole tab to given file 
int write_to_file(INSTRUTAB* p_instrutab, FILE* fasm);

void tprint(INSTRUTAB* p_instrutab);

