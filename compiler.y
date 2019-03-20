%{
    #include <stdio.h>
    #include <stdlib.h>
    int depth = 0 ;
%}

%union {
    int nb ;
    char* text;
}

%token <text> tID
%token <nb> tVAL tCON
%token tPLU tEQU tMOI tSTA tSLA tPARO tPARF tACO tACF tVIR tPOV tINT tMAIN tIF tFOR tELS tRET 

%%
start:global;
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
declaration_variable : tID {printf("Trouvé une déclaration : variable %s\n",$1);} 
                     | tID tEQU operation {printf("Trouvé une déclaration-allocation: %s\n",$1);}; 
 
operation : member
          | operation operator member ;
operator : tPLU | tMOI | tSLA | tSTA ;
member : tVAL | tID ;

type:tINT;
instruction:tID tEQU operation tPOV {printf("Trouvé une instruction\n");};
 
