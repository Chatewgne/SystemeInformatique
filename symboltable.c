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
        typesize = 2;
    else
        return SYMTAB_UNKNOWN_TYPE;

    // If the symbol table is full, we return 2
    if(p_symtab->last_index >= p_symtab->size)
        return SYMTAB_FULL;

    // Checking if the symbol already exists in the table
    // If it does, we return 3
    SYMBOL symbol_check = symtab_get(p_symtab, name);
    if(symbol_check.address != -1)
        return SYMTAB_ALREADY_EXISTS;
    
    
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



/****************************************************
            TEMPORARY SYMBOL PRIMITIVES
****************************************************/

// Add a temporary symbol to the symbol table and return its address
int symtab_add_tmp(SYMTAB * p_symtab, char * type) {

    // Size of the variable type given
    int typesize = 0;

    // Variable type size evaluation (return 1 if type not recognized)
    if(strcmp(type,"int") == 0)
        typesize = 4;
    else
        return SYMTAB_UNKNOWN_TYPE;

    // If the symbol table is full, we return 2
    if(p_symtab->last_index >= p_symtab->size)
        return SYMTAB_FULL;
    
    
    // Pointer to the array of symbols of symtab
    SYMBOL * stab = p_symtab->symboltab;

    (p_symtab->last_index)++;

    // Setting name and depth at NULL and -42
    (stab[p_symtab->last_index]).name[0] = '\0';
    stab[p_symtab->last_index].depth = -42;

    // Copying type information
    strcpy(stab[p_symtab->last_index].type, type);
    

    // Evaluate symbol address 
    // (the first address doesn't need evaluation, since it is fixed at initialization)
    if(p_symtab->last_index > 0)
        stab[p_symtab->last_index].address = stab[p_symtab->last_index - 1].address + typesize;

    return stab[p_symtab->last_index].address;

}

/* 
*   Pop the last temporary symbol of the symbol table
*   Return this last symbol (it has no name and its depth is -42)
*   Depth equals SYMTAB_NO_TMP_LEFT (-5) if there is no temporary symbol to pop
*/
int symtab_pop_tmp(SYMTAB * p_symtab){
    
    // Address of the temporary symbol to return
    // By default equals -5 (SYMTAB_NO_TMP_LEFT)
    int tmp_symbol_address = SYMTAB_NO_TMP_LEFT;

    // Pointer to the array of symbols of symtab
    SYMBOL * stab = p_symtab->symboltab;



    // IF the last symbol is a temporary one...
    if(stab[p_symtab->last_index].depth == -42){

        // ... we will return this symbol
        tmp_symbol_address = (stab[p_symtab->last_index]).address;
        (p_symtab->last_index)--;

        // ELSE it will return SYMTAB_NO_TMP_LEFT
    }

    return tmp_symbol_address;

}