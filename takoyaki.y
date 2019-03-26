%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "symboltable.h"
    #include <string.h>
    int yylex();
    void yyerror(char*);

//mémorisation des variables
    int depth = 0 ;
    SYMTAB* symtab ;
    SYMBOL global_sym ;
//SYMBOL : address (int)    name (char[])   type (char[])    depth (int) 
    char glob_type[30] ;
    char* glob_variable = 0;
    int glob_value = 0 ;
    char glob_operator = '+';

//TODO pour la prochaine fois : gérer les erreurs et débugger les calculs d'opérations 
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


global:tMAIN tPARO tPARF tACO {depth+=1;} body tACF {depth-=1;} ;

body:declaration_lines instructions;

instructions : 
             | instructions instruction ;

declaration_lines : /* empty */
                  | declaration_lines declaration_line ;

declaration_line : type declaration_variables tPOV ;

declaration_variables : declaration_variable
                      | declaration_variables tVIR declaration_variable ;

declaration_variable : tID {    printf("PARSING ---- Trouvé une déclaration\n");
                                if ((symtab_add(symtab,$1,"int",depth)==3)) {
                                    printf("PARSING ---- Cette variable existe déjà >:( \n");
                                }
                                else {
                                        printf("---- MEMOIRE Variable %s ajoutée au symtab\n",$1) ;
                                }}
                     | tID  {   printf("PARSING ---- Trouvé une déclaration-allocation\n");
                                if ((symtab_add(symtab,$1,"int",depth)==3)) {
                                    printf("PARSING ---- Cette variable existe déjà >:( \n");
                                }
                                else {
                                    printf("---- MEMOIRE Variable %s ajoutée au symtab",$1) ;
                                 }}
                           tEQU operation ; 

operation : member 
          | operation tPLU operation 
                { 
                    printf("PARSING ---- Trouvé une réduction\n");
                    int op1_addr = symtab_pop_tmp(symtab) ;
                    int op2_addr = symtab_pop_tmp(symtab) ;
                    if( (op1_addr == -1) || (op2_addr == -1) )
                    {
                        printf("---- MEMOIRE Erreur : \n"); //TODO
                    }
                    else {
                        printf("---- MEMOIRE Poped deux variables temporaires\n");
                        printf("-- ASSEMBLY --\n");
                        printf("LOAD R0 %d\n",op1_addr);
                        printf("LOAD R1 %d\n",op2_addr);
                        printf("ADD R0 R0 R1\n");
                        int addr_tmp = symtab_add_tmp(symtab,"int"); //TODO y a pas que des int
                        if (addr_tmp == SYMTAB_FULL) 
                        {
                            printf("---- MEMOIRE Erreur : problème de sauvegarde d'une variable temporaire -> table pleine\n");
                        } else if (addr_tmp == SYMTAB_UNKNOWN_TYPE) 
                        {
                        printf("---- MEMOIRE Erreur : problème de sauvegarde d'une variable temporaire -> type inconnu\n");
                        } else {
                        printf("---- MEMOIRE Sauvegarde d'une variable temporaire\n"); 
                        printf(" -- ASSEMBLY -- \n");
                        printf("STORE %d R0\n",addr_tmp);
                        }
                        
                    }
                } 
          | operation tMOI operation 
          | operation tSLA operation 
          | operation tSTA operation 
          | tPARO operation tPARF
          ;

member : tID 
            { 
                global_sym = symtab_get(symtab,$1);
                if (!(global_sym.depth == 0)){
                    printf("PARSING ---- Récupération de la variable %s\n",$1);
                    printf(" -- ASSEMBLY -- \n");
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
                        printf(" -- ASSEMBLY -- \n");
                        printf("STORE %d R0\n",addr_tmp);
                    }

                } else {
                    printf("---- MEMOIRE Erreur : variable absente de la table des symboles\n");
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
                    printf(" -- ASSEMBLY -- \n");
                    printf("AFC R0 %d\n",$1);
                    printf("STORE %d R0\n",addr_tmp);
                }
            };

type:tINT { strcpy(glob_type,$1);} ;

instruction:tID tEQU operation tPOV {printf("PARSING ---- Trouvé une instruction\n");
           glob_variable=$1;
                                    } 
           | print_instr ;

print_instr:tPRI tPARO tID tPARF tPOV {printf("---- PARSING Trouvé un printf sur la variable %s\n",$3);};
