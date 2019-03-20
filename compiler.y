%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "symboltable.h"
    
    //mémorisation des variables
    int depth = 0 ;
    SYMTAB symtab ;
    char* glob_variable ;
    int glob_value ;
    char glob_operator;
%}

%union {
    int nb ;
    char* text;
    char car ;
}

%token <text> tID
%token <nb> tVAL tCON
%token <car> tPLU tEQU tSLA tMOI tSTA
%token tPARO tPARF tACO tACF tVIR tPOV tINT tMAIN tIF tFOR tELS tRET tPRI  

%%
start: { printf("-- MEMOIRE -- symtab initialisé, succes code : %d\n",symtab_init(&symtab) ); } global ; 


global:tMAIN tPARO tPARF tACO body tACF;

body:declaration_lines instructions;

instructions : 
             | instructions instruction ;


/*declarations : /* empty 
             | declarations declaration ;
declaration:type tID tPOV {printf("Trouvé une déclaration\n");
                         // tab_add($2,$1,depth);
                            } 
| type tID tEQU tVAL tPOV {printf("Trouvé une déclaration-allocation\n"); 
                          //  tab_add($2,$1,depth); 
                          //  symbol var = tab_get($2); 
                         //    printf("STORE %d %d\n", var.address, $4);
                             printf("STORE %s %d\n", "ADDRESSE", $4);
                          }; */


declaration_lines : /* empty */
             | declaration_lines declaration_line ;

declaration_line : type declaration_variables tPOV ;

declaration_variables : declaration_variable
                      | declaration_variables tVIR declaration_variable ;

declaration_variable : tID {printf("-- PARSING -- Trouvé une déclaration : variable %s\n",$1); glob_variable=$1;} 
                     | tID tEQU operation {printf("-- PARSING -- Trouvé une déclaration-allocation: %s\n",$1); glob_variable=$1;}; 
 
operation : member 
          | operation operator member ;

operator : tPLU {glob_operator = $1;}
         | tMOI {glob_operator = $1;}
         | tSLA {glob_operator = $1;}
         | tSTA {glob_operator = $1;} ;

member : tVAL | tID ;

type:tINT;

instruction:tID tEQU operation tPOV {printf("-- PARSING -- Trouvé une instruction\n");
                                     glob_variable=$1;
                                    } 
           | print_instr ;
 
print_instr:tPRI tPARO tID tPARF tPOV {printf("-- PARSING -- Trouvé un printf sur la variable %s\n",$3);};
