%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "symboltable.h"
    #include <string.h>

// Codes corresponding to the operation to reduce
    #define OP_ADD 1
    #define OP_SOU 2
    #define OP_MUL 3
    #define OP_DIV 4
    #define OP_COP 5 
    #define OP_AFC 6 
    #define OP_LOAD 7 
    #define OP_STORE 8
    #define OP_EQU 9
    #define OP_INF 10 
    #define OP_INFE 11 
    #define OP_SUP 12
    #define OP_SUPE 13 
    #define OP_JMP 14 
    #define OP_JMPC 15 
    

    int yylex();
    void yyerror(char*);

//mémorisation des variables
    int depth = 0 ;
    SYMTAB* symtab ;
    SYMBOL global_sym ; //SYMBOL : address (int)    name (char[])   type (char[])    depth (int) 
    char glob_type[30] ;

/* An instruction is written like this :
    OP_CODE |   A   |   B   |   C   
     1 byte |1 byte |1 byte |1 byte
*/
// Assembly file
    FILE * fasm = NULL;


// Reduce and executing an operation according to the given op (op codes at the beginning of this file)
    void op_reducing(int operation){
        printf("PARSING ---- Trouvé une réduction\n");
        int op1_addr = symtab_pop_tmp(symtab) ;
        int op2_addr = symtab_pop_tmp(symtab) ;
        if( (op1_addr == SYMTAB_NO_TMP_LEFT) || (op2_addr == SYMTAB_NO_TMP_LEFT) )
        {
            printf("---- MEMOIRE Error : plus de variable temporaire à pop \n"); //TODO
        }
        else {
            printf("---- MEMOIRE Poped deux variables temporaires\n");
            printf("--- ASMB ---\n");
            printf("LOAD R0 %d\n",op1_addr);
            printf("LOAD R1 %d\n",op2_addr);

            switch(operation){

                case OP_ADD :
                printf("ADD R0 R0 R1\n");
               // fprintf("")
                break;

                case OP_SOU :
                printf("SOU R0 R0 R1\n");
                break;

                case OP_MUL :
                printf("MUL R0 R0 R1\n");
                break;

                case OP_DIV :
                printf("DIV R0 R0 R1\n");
                break;

                default:
                printf("--- ASMB --- ERROR : UNKNOWN OPERATION\n");
                return;

            }

            
            int addr_tmp = symtab_add_tmp(symtab,"int"); //TODO y a pas que des int
            if (addr_tmp == SYMTAB_FULL) 
            {
                printf("---- MEMOIRE Error : problème de sauvegarde d'une variable temporaire -> table pleine\n");
            } else if (addr_tmp == SYMTAB_UNKNOWN_TYPE) 
            {
            printf("---- MEMOIRE Error : problème de sauvegarde d'une variable temporaire -> type inconnu\n");
            } else {
            printf("---- MEMOIRE Sauvegarde d'une variable temporaire\n"); 
            printf("--- ASMB --- \n");
            printf("STORE %d R0\n",addr_tmp);
            }
            
        }
    }

%}

%union {
    int nb ;
    char* text;
    char car ;
}

%token <text> tID tINT
%token <nb> tVAL tCON
%token <car> tPLU tEQU tSLA tMOI tSTA
%token tPARO tPARF tACO tACF tVIR tPOV tMAIN tIF tFOR tELS tRET tPRI  

%left tPLU tMOI
%left tSTA tSLA //STA et SLA prioritaires

%%
start: {
     printf("---- MEMOIRE Symtab initialisé, success code : %d\n",symtab_init(&symtab) ); } global ; 


global:tMAIN tPARO tPARF tACO {depth+=1; fopen("asm.tako", "wb+");} body tACF {depth-=1; fclose(fasm);} ;

body:declaration_lines instructions;

instructions : 
             | instructions instruction ;

declaration_lines : /* empty */
                  | declaration_lines declaration_line ;

declaration_line : type declaration_variables tPOV ;

declaration_variables : declaration_variable
                      | declaration_variables tVIR declaration_variable ;

declaration_variable : tID {    printf("PARSING ---- Trouvé une déclaration\n");
                                int symtab_result = symtab_add(symtab,$1,"int",depth);
                                if ((symtab_result==SYMTAB_ALREADY_EXISTS)) {
                                    printf("---- MEMOIRE Error : Cette variable existe déjà\n");
                                }
                                else if (symtab_result==SYMTAB_UNKNOWN_TYPE) { 
                                    printf("PARSING ---- Error : Type non reconnu\n");
                                }
                                 else if (symtab_result==SYMTAB_FULL) { 
                                    printf("---- MEMOIRE Error : La table est pleine\n");
                                }
                                else {
                                        printf("---- MEMOIRE Variable %s ajoutée au symtab\n",$1) ;
                                }}
                     | tID  {   printf("PARSING ---- Trouvé une déclaration-allocation\n");
                                int symtab_result = symtab_add(symtab,$1,"int",depth);
                                if ((symtab_result==SYMTAB_ALREADY_EXISTS)) {
                                    printf("---- MEMOIRE Error : Cette variable existe déjà\n");
                                }
                                else if (symtab_result==SYMTAB_UNKNOWN_TYPE) { 
                                    printf("PARSING ---- Error : Type non reconnu\n");
                                }
                                 else if (symtab_result==SYMTAB_FULL) { 
                                    printf("---- MEMOIRE Error : La table est pleine\n");
                                }
                                else {
                                        printf("---- MEMOIRE Variable %s ajoutée au symtab\n",$1) ;
                                }}
                       tEQU operation { 
                                            printf("PARSING --- Fin de déclaration : récupérer la var temp\n");
                                            int val_addr = symtab_pop_tmp(symtab) ;
                                            if (val_addr == SYMTAB_NO_TMP_LEFT)  {
                                                printf("---- MEMOIRE Error : plus de variable temporaire à pop\n");
                                            } else {
                                                printf("--- MEMOIRE Poped une variable temporaire\n");
                                                printf("--- ASMB ---\n");
                                                printf("LOAD R0 %d\n",val_addr);
                                                printf("--- MEMOIRE Récupération de l'addresse de %s\n",$1);
                                                global_sym = symtab_get(symtab,$1);
                                                if (global_sym.depth==-1)
                                                { 
                                                    printf("--- MEMOIRE Error : variable absente de la table des symboles\n"); 
                                                }else{
                                                    printf("--- MEMOIRE Stockage de la nouvelle valeur pour cette variable\n");
                                                    printf("--- ASMB ---\n");
                                                    printf("STORE %d R0\n",global_sym.address);
                                                }
                                            }
                                        }
                                
                                ; 

operation: member 
          | operation tPLU operation 
                { 
                    op_reducing(OP_ADD);
                } 
          | operation tMOI operation
                {
                    op_reducing(OP_SOU);
                }
          | operation tSLA operation
                {
                    op_reducing(OP_DIV);
                }
          | operation tSTA operation
                {
                    op_reducing(OP_MUL);
                }
          | tPARO operation tPARF
          ;

member: tID 
            { 
                global_sym = symtab_get(symtab,$1);
                if (global_sym.depth == -1){
                    printf("---- MEMOIRE Error : variable absente de la table des symboles\n");
                } else {
                    printf("PARSING ---- Récupération de la variable %s\n",$1);
                    printf("--- ASMB --- \n");
                    printf("LOAD R0 %d\n",global_sym.address);

                    int addr_tmp = symtab_add_tmp(symtab,"int"); //TODO y a pas que des int
                    if (addr_tmp == SYMTAB_FULL) 
                    {
                        printf("---- MEMOIRE Erreur : problème de sauvegarde d'une variable temporaire -> table pleine\n");
                    } else if (addr_tmp == SYMTAB_UNKNOWN_TYPE) 
                    {
                        printf("---- MEMOIRE Erreur : problème de sauvegarde d'une variable temporaire -> type inconnu\n");
                    } else {
                        printf("---- MEMOIRE Sauvegarde d'une variable temporaire\n"); 
                        printf("--- ASMB --- \n");
                        printf("STORE %d R0\n",addr_tmp);
                    }
                }
            } 
       | tVAL
            {
                int addr_tmp = symtab_add_tmp(symtab,"int"); //TODO y a pas que des int
                if (addr_tmp == SYMTAB_FULL) 
                {
                    printf("---- MEMOIRE Erreur : problème de sauvegarde d'une variable temporaire -> table pleine\n");
                } else if (addr_tmp == SYMTAB_UNKNOWN_TYPE) 
                {
                    printf("---- MEMOIRE Erreur : problème de sauvegarde d'une variable temporaire -> type inconnu\n");
                } else {
                    printf("---- MEMOIRE Sauvegarde d'une variable temporaire\n"); 
                    printf("--- ASMB --- \n");
                    printf("AFC R0 %d\n",$1);
                    printf("STORE %d R0\n",addr_tmp);
                }
            };

type:tINT { strcpy(glob_type,$1);} ;

instruction: tID {printf("PARSING ---- Trouvé une instruction\n");} 
             tEQU operation tPOV {            
                                            printf("PARSING --- Fin d'instruction : récupérer la var temp\n");
                                            int val_addr = symtab_pop_tmp(symtab) ;
                                            if (val_addr == SYMTAB_NO_TMP_LEFT)  {
                                                printf("---- MEMOIRE Error : plus de variable temporaire à pop\n");
                                            } else {
                                                printf("--- MEMOIRE Poped une variable temporaire\n");
                                                printf("--- ASMB ---\n");
                                                printf("LOAD R0 %d\n",val_addr);
                                                printf("--- MEMOIRE Récupération de l'addresse de %s\n",$1);
                                                global_sym = symtab_get(symtab,$1);
                                                if (global_sym.depth==-1)
                                                { 
                                                    printf("--- MEMOIRE Error : variable absente de la table des symboles\n"); 
                                                }else{
                                                    printf("--- MEMOIRE Stockage de la nouvelle valeur pour cette variable\n");
                                                    printf("--- ASMB ---\n");
                                                    printf("STORE %d R0\n",global_sym.address);
                                                }
                                            }

                                 } 
           | print_instr ;

print_instr:tPRI tPARO tID tPARF tPOV {printf("---- PARSING Trouvé un printf sur la variable %s\n",$3);};
