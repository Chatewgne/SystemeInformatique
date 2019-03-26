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
    char glob_type[30] ;
    char* glob_variable = 0;
    int glob_value = 0 ;
    char glob_operator = '+';
    
    //init 
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
    printf("-- MEMOIRE -- Symtab initialisé, success code : %d\n",symtab_init(&symtab) ); } global ; 


global:tMAIN tPARO tPARF tACO {depth+=1;} body tACF {depth-=1;} ;

body:declaration_lines instructions;

instructions : 
             | instructions instruction ;

declaration_lines : /* empty */
             | declaration_lines declaration_line ;

declaration_line : type declaration_variables tPOV ;

declaration_variables : declaration_variable
                      | declaration_variables tVIR declaration_variable ;

declaration_variable : tID { printf("-- PARSING -- Trouvé une déclaration\n");
                     printf("-- MEMOIRE -- Variable %s ajoutée au symtab avec success code",$1) ;
                    printf(" %d\n",symtab_add(symtab,$1,"int",depth));
 } 
                     | tID tEQU operation {printf("-- PARSING -- Trouvé une déclaration-allocation \n"); 
printf("-- MEMOIRE -- Variable %s ajoutée au symtab avec success code %d\n",$1,symtab_add(symtab,$1,glob_type,depth)); 
} ; 
 
operation : member {//glob_value = glob_value gob_op member 
          }
          | operation tPLU operation { //printf("LOAD  }
} 
          | operation tMOI operation 
          | operation tSLA operation 
          | operation tSTA operation 
          ;

member : tVAL | tID ;

type:tINT { strcpy(glob_type,$1);} ;

instruction:tID tEQU operation tPOV {printf("-- PARSING -- Trouvé une instruction\n");
                                     glob_variable=$1;
                                    } 
           | print_instr ;
 
print_instr:tPRI tPARO tID tPARF tPOV {printf("-- PARSING -- Trouvé un printf sur la variable %s\n",$3);};