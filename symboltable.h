
#define SYMTAB_UNKNOWN_TYPE -1
#define SYMTAB_FULL -2
#define SYMTAB_ALREADY_EXISTS -3
#define SYMTAB_NO_TMP_LEFT -5

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



// Initialize a symbol table (with 1024 symbols)
// first address is 4000, return -1 if we couldn't initialize

/*  AS IT IS, you must give the address of the pointer to
    a symbol table (not initialized) */
int symtab_init(SYMTAB ** pp_symtab);

// Free the pointer and the memory associated to the symbol table
void symtab_free(SYMTAB ** pp_symtab);


// Add a symbol to the symbol table (return -1 if cannot add one)
/*
    Error codes :
    - SYMTAB_UNKNOWN_TYPE (-1) : The variable type hasn't been recognized
    - SYMTAB_FULL (-2) : The symbol table is already full (last_index >= size)
    - SYMTAB_ALREADY_EXISTS (-3) : The symbol already exists in the symbol table
*/
int symtab_add(SYMTAB * p_symtab, char * name, char * type, int depth);

// Get back the last_index of the table to the previous depth (curr_depth - 1)
// Return -1 if the depth is already 0
int symtab_pop(SYMTAB * p_symtab); //unused in implementation


/*  
*   Return the SYMBOL struct corresponding to the symbol designated by id
*   Depth equals -1 when no symbol has been found
*/
SYMBOL symtab_get(SYMTAB * p_symtab, char * id);



/****************************************************
            TEMPORARY SYMBOL PRIMITIVES
****************************************************/

// Add a temporary symbol to the symbol table and return its address
/*
    Error codes :
    - SYMTAB_UNKNOWN_TYPE (-1) : The variable type hasn't been recognized
    - SYMTAB_FULL (-2) : The symbol table is already full (last_index >= size)
*/
int symtab_add_tmp(SYMTAB * p_symtab, char * type);

/* 
*   Pop the last temporary symbol of the symbol table
*   Return its address
*   OR return SYMTAB_NO_TMP_LEFT (-5) if there is no temporary symbol to pop
*/
int symtab_pop_tmp(SYMTAB * p_symtab);

