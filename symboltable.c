#include "symboltable.h"
#include <stdlib.h>

#include <string.h>


// Initialize a symbol table with 1024 symbols, first address is 4000
int symtab_init(SYMTAB * symtab) {
    (symtab->symboltab[0]).address = 4000;
    symtab->size = 1024;
    symtab->last_index = -1;
}


// Add a symbol to the symbol table
int symtab_add(SYMTAB * symtab, char * name, char * type, int depth) {

    // Size of the variable type given
    int typesize = 0;

    if(symtab->size == symtab->last_index)
        return -1;
    
    // Pointer to the array of symbols of symtab
    SYMBOL * stab = symtab->symboltab;

    (symtab->last_index)++;
    strcpy(stab[symtab->last_index].name, name);
    strcpy(stab[symtab->last_index].type, type);
    stab[symtab->last_index].depth = depth;

    if(strcmp(type,"int") == 0)
        typesize = 4;

    if(symtab->last_index > 0)
        stab[symtab->last_index].address = stab[symtab->last_index - 1].address + typesize;

    return 0;

}


// Return the SYMBOL struct corresponding to the symbol designated by id
SYMBOL symtab_get(SYMTAB symtab, char * id) {

    // Current index of the symbol being checked and size of the table
    int currIndex;

    // Boolean true when the symbol is found
    int found_symbol = 0;

    // Symbol returned by the function
    SYMBOL symbol;
    
    // Pointer to the array of symbols of symtab
    SYMBOL * stab = symtab.symboltab;

    // The symbol (to return) is initialized to null
    // It will be returned as it is if nothing is found
    symbol.address = -1;
    symbol.name[0] = '\0';
    symbol.type[0] = '\0';
    symbol.depth = -1;

    currIndex = 0;
    
    // While we haven't found the symbol, we iterate on the array
    while(currIndex <= symtab.last_index && !found_symbol){
        
        // Check if the name of the symbol matches with the given ID
        if(strcmp(stab[currIndex].name,id) == 0)
        {
            symbol = stab[currIndex];
        }
        currIndex++;
    }

    return symbol;

}