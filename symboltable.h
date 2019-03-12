


typedef struct {
    int address;
    char name[40];
    char type[10];
    int depth;
} SYMBOL;

typedef struct{
    SYMBOL symboltab[1024];
    int size;
    int last_index;
} SYMTAB;



// Initialize a symbol table (with 1024 symbols), first address is 4000, return -1 if we couldn't initialize
int symtab_init(SYMTAB * symtab);


// Add a symbol to the symbol table (return -1 if cannot add one)
int symtab_add(SYMTAB * symtab, char * name, char * type, int depth);


/*  
*   Return the SYMBOL struct corresponding to the symbol designated by id
*   Depth equals -1 when no symbol has been found
*/
SYMBOL symtab_get(SYMTAB symtab, char * id);