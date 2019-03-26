#include "symboltable.h"
#include <stdlib.h>

#include <string.h>


// Initialize a symbol table with 1024 symbols, first address is 4000
int symtab_init(SYMTAB ** pp_symtab) {
    *pp_symtab = malloc(sizeof(SYMTAB));

    if (*pp_symtab == NULL)
        return 3;

    ((*pp_symtab)->symboltab[0]).address = 4000;
    (*pp_symtab)->size = 1024;
    (*pp_symtab)->last_index = -1;

    return 0;

}

// Free the pointer and the memory associated to the symbol table
void symtab_free(SYMTAB ** pp_symtab){
    free(*pp_symtab);
}


// Add a symbol to the symbol table
int symtab_add(SYMTAB * p_symtab, char * name, char * type, int depth) {

    // Size of the variable type given
    int typesize = 0;


    // Variable type size evaluation (return 1 if type not recognized)
    if(strcmp(type,"int") == 0)
        typesize = 4;
    else
        return 1;

    // If the symbol table is full, we return 2
    if(p_symtab->last_index >= p_symtab->size)
        return 2;

    // Checking if the symbol already exists in the table
    // If it does, we return 3
    SYMBOL symbol_check = symtab_get(p_symtab, name);
    if(symbol_check.address == -1)
        return 3;
    
    
    // Pointer to the array of symbols of symtab
    SYMBOL * stab = p_symtab->symboltab;

    (p_symtab->last_index)++;

    // Copying symbol informations
    strcpy(stab[p_symtab->last_index].name, name);
    strcpy(stab[p_symtab->last_index].type, type);
    stab[p_symtab->last_index].depth = depth;

    // Evaluate symbol address 
    // (the first address doesn't need evaluation, since it is fixed at initialization)
    if(p_symtab->last_index > 0)
        stab[p_symtab->last_index].address = stab[p_symtab->last_index - 1].address + typesize;

    return 0;

}


// Get back the last_index of the table to the previous depth (curr_depth - 1)
// Return -1 if the depth is already 0
int symtab_pop(SYMTAB * p_symtab) {

    // Last (so current) depth in the table
    int last_depth;

    // Pointer to the array of symbols of symtab
    SYMBOL * stab = p_symtab->symboltab;

    last_depth = stab[p_symtab->last_index].depth;

    if (last_depth > 0) {

        do {
            (p_symtab->last_index)--;            
        } while (last_depth == stab[p_symtab->last_index].depth);

        return 0;

    }

    else
        return -1;


}




// Return the SYMBOL struct corresponding to the symbol designated by id
SYMBOL symtab_get(SYMTAB * p_symtab, char * id) {

    // Current index of the symbol being checked and size of the table
    int currIndex;

    // Boolean true when the symbol is found
    int found_symbol = 0;

    // Symbol returned by the function
    SYMBOL symbol;
    
    // Pointer to the array of symbols of symtab
    SYMBOL * stab = p_symtab->symboltab;

    // The symbol (to return) is initialized to null
    // It will be returned as it is if nothing is found
    symbol.address = -1;
    symbol.name[0] = '\0';
    symbol.type[0] = '\0';
    symbol.depth = -1;

    currIndex = 0;
    
    // While we haven't found the symbol, we iterate on the array
    while(currIndex <= p_symtab->last_index && !found_symbol){
        
        // Check if the name of the symbol matches with the given ID
        if(strcmp(stab[currIndex].name,id) == 0)
        {
            symbol = stab[currIndex];
        }
        currIndex++;
    }

    return symbol;

}