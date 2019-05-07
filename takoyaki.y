%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "symboltable.h"
    #include <string.h>
    #include "binwriter.h"
    #include "instrutable.h"

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
    #define OP_PRINT 16     //PRINT Ri X X  
    

    int yylex();
    void yyerror(char*);

//mémorisation des variables
    int depth = 0 ;
    SYMTAB* symtab ;
    INSTRUTAB* instrup;
    SYMBOL global_sym ; //SYMBOL : address (int)    name (char[])   type (char[])    depth (int) 
    char glob_type[30] ;
    int instruction_to_patch ;
    int loop_address ;

/* An instruction is written like this :
    OP_CODE |   A   |   B   |   C   
     1 byte |1 byte |1 byte |1 byte
*/
// Assembly file
    FILE * fasm = NULL;
    FILE * fasm1 = NULL;

    int8_t higher_bits(int16_t value){
    return (int8_t) ((value >> 8) & 0xFF);
    }

    int8_t lower_bits(int16_t value){
    return (int8_t)(value & 0xFF);
    }


// Reduce and executing an operation according to the given op (op codes at the beginning of this file)
    void op_reducing(int operation){
        printf("PARSING ---- Trouvé une réduction\n");
        int16_t op1_addr = (int16_t) symtab_pop_tmp(symtab) ; //TODO attention, on a hardcodé 4000 comme addresse de début mais ça va surement causer soucis sur 16 bits ???
        int16_t op2_addr = (int16_t) symtab_pop_tmp(symtab) ;
        if( (op1_addr == SYMTAB_NO_TMP_LEFT) || (op2_addr == SYMTAB_NO_TMP_LEFT) )
        {
            printf("---- MEMOIRE Error : plus de variable temporaire à pop \n"); //TODO
        }
        else {
            printf("---- MEMOIRE Poped deux variables temporaires\n");
            printf("--- ASMB ---\n");
            printf("LOAD R1 %d\n",op1_addr);
            instrutab_add(instrup,OP_LOAD,1,higher_bits(op1_addr),lower_bits(op1_addr));
            writeAB(fasm,OP_LOAD,1,op1_addr);
            printf("LOAD R0 %d\n",op2_addr);
            instrutab_add(instrup,OP_LOAD,0,higher_bits(op2_addr),lower_bits(op2_addr));
            writeAB(fasm,OP_LOAD,0,op2_addr);
             
            switch(operation){

                case OP_ADD :
                printf("ADD R0 R0 R1\n");
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
                        
                case OP_INF:
                printf("INF R0 R0 R1\n");
                break;  
    
                case OP_SUP:
                printf("SUP R0 R0 R1\n");
                break;  

                case OP_SUPE:
                printf("SUPE R0 R0 R1\n");
                break;  

                case OP_INFE:
                printf("INFE R0 R0 R1\n");
                break;  
            
                default:
                printf("--- ASMB --- ERROR : UNKNOWN OPERATION\n");
                return;
            }
           
            writeABC(fasm,operation,0,0,1); 
            instrutab_add(instrup,operation,0,0,1);
            
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
            instrutab_add(instrup,OP_STORE,higher_bits(addr_tmp),lower_bits(addr_tmp),0);
            writeAC(fasm,OP_STORE,addr_tmp,0);
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
%token <nb> tVAL tCON tIF
%token <car> tPLU tEQU tSLA tMOI tSTA tIOE tSOE tINF tSUP
%token tPARO tPARF tACO tACF tVIR tPOV tMAIN tFOR tELS tRET tPRI tTRU tFAL tWHIL tCOM t2EQ

%type <nb> action_if

%nonassoc tIFX
%nonassoc tELS

%left tPLU tMOI
%left tINF tSUP tSOE tIOE 
%left tSTA tSLA //STA et SLA prioritaires

%%
start: {
     instrutab_init(&instrup);
     printf("---- MEMOIRE Symtab initialisé, success code : %d\n",symtab_init(&symtab) ); } global ; 


global:tMAIN tPARO tPARF tACO {depth+=1; fasm = fopen("asm.tako", "wb+"); fasm1 = fopen("new_asm.tako","wb+");} body tACF {depth-=1; fclose(fasm); write_to_file(instrup,fasm1); fclose(fasm1); printf("--- GENERATED ASSEMBLY (decimal form) ---\n"); tprint(instrup);} ;

body:declaration_lines instructions;

instructions : 
             | instructions instruction ;

declaration_lines : /* empty */
                  | declaration_lines declaration_line ;

declaration_line : type declaration_variables tPOV 
                   | tCOM {printf("PARSING ---- Trouvé un commentaire\n");} ;

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
                                                instrutab_add(instrup,OP_LOAD,0,higher_bits(val_addr),lower_bits(val_addr));
                                                writeAB(fasm,OP_LOAD,0,val_addr);
                                                printf("--- MEMOIRE Récupération de l'addresse de %s\n",$1);
                                                global_sym = symtab_get(symtab,$1);
                                                if (global_sym.depth==-1)
                                                { 
                                                    printf("--- MEMOIRE Error : variable absente de la table des symboles\n"); 
                                                }else{
                                                    printf("--- MEMOIRE Stockage de la nouvelle valeur pour cette variable\n");
                                                    printf("--- ASMB ---\n");
                                                    printf("STORE %d R0\n",global_sym.address);
                                                    instrutab_add(instrup,OP_STORE,higher_bits(global_sym.address),lower_bits(global_sym.address),0);
                                                    writeAC(fasm,OP_STORE,global_sym.address,0);
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
          | operation tINF operation
                {
                    op_reducing(OP_INF);
                }
          | operation tSUP operation
                {
                    op_reducing(OP_SUP);
                }
          | operation tSOE operation
                {
                    op_reducing(OP_SUPE);
                }
          | operation tIOE operation
                {
                    op_reducing(OP_INFE);
                }
         | operation t2EQ operation
                {
                    op_reducing(OP_EQU);
                }
          | tPARO operation tPARF
          ;
print_instr: tPRI {printf("---- PARSING Trouvé un printf\n");} 
             tPARO tID {
                          global_sym = symtab_get(symtab,$4);
                          printf("LOAD R0 %d\n", global_sym.address);
                          instrutab_add(instrup,OP_LOAD,0,higher_bits(global_sym.address),lower_bits(global_sym.address));
                          printf("PRINTF R0 x x\n");
                          instrutab_add(instrup,OP_PRINT,0,42,42);
                       } 
             tPARF tPOV ;

member: tID 
            { 
                global_sym = symtab_get(symtab,$1);
                if (global_sym.depth == -1){
                    printf("---- MEMOIRE Error : variable absente de la table des symboles\n");
                } else {
                    printf("PARSING ---- Récupération de la variable %s\n",$1);
                    printf("--- ASMB --- \n");
                    printf("LOAD R0 %d\n",global_sym.address);
                    instrutab_add(instrup,OP_LOAD,0,higher_bits(global_sym.address),lower_bits(global_sym.address));
                    writeAB(fasm,OP_LOAD,0,global_sym.address);

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
                        instrutab_add(instrup,OP_STORE,higher_bits(addr_tmp),lower_bits(addr_tmp),0);
                        writeAC(fasm,OP_STORE,addr_tmp,0);
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
                    instrutab_add(instrup,OP_AFC,0,higher_bits($1),lower_bits($1));
                    writeAB(fasm,OP_AFC,0,$1);
                    printf("STORE %d R0\n",addr_tmp);
                    instrutab_add(instrup,OP_STORE,higher_bits(addr_tmp),lower_bits(addr_tmp),0);
                    writeAC(fasm,OP_STORE,addr_tmp,0);
                }
            };

type:tINT { strcpy(glob_type,$1);} ;

instruction: tCOM {printf("PARSING ---- Trouvé un commentaire\n");} |
             tID {printf("PARSING ---- Trouvé une instruction\n");} 
             tEQU operation tPOV {            
                                            printf("PARSING --- Fin d'instruction : récupérer la var temp\n");
                                            int val_addr = symtab_pop_tmp(symtab) ;
                                            if (val_addr == SYMTAB_NO_TMP_LEFT)  {
                                                printf("---- MEMOIRE Error : plus de variable temporaire à pop\n");
                                            } else {
                                                printf("--- MEMOIRE Poped une variable temporaire\n");
                                                printf("--- ASMB ---\n");
                                                printf("LOAD R0 %d\n",val_addr);
                                                instrutab_add(instrup,OP_LOAD,0,higher_bits(val_addr),lower_bits(val_addr));
                                                writeAB(fasm,OP_LOAD,0,val_addr);
                                                printf("--- MEMOIRE Récupération de l'addresse de %s\n",$1);
                                                global_sym = symtab_get(symtab,$1);
                                                if (global_sym.depth==-1)
                                                { 
                                                    printf("--- MEMOIRE Error : variable absente de la table des symboles\n"); 
                                                }else{
                                                    printf("--- MEMOIRE Stockage de la nouvelle valeur pour cette variable\n");
                                                    printf("--- ASMB ---\n");
                                                    printf("STORE %d R0\n",global_sym.address);
                                                    instrutab_add(instrup,OP_STORE,higher_bits(global_sym.address),lower_bits(global_sym.address),0);
                                                    writeAC(fasm,OP_STORE,global_sym.address,0);
                                                }
                                            }

                                 } 
           | print_instr 
           | if | while ;
action_if :{
                printf("JMPC -1 R0"); //format AC
                //instruction_to_patch = get_instrutab_index(instrup);
                instrutab_add(instrup,OP_JMPC,0xFF,0xFF,0); //patch me later !
                $$ = get_instrutab_index(instrup)-1;
                printf("LIGNE QUI DEVRA ETRE PACTHEE : %d\n", $$);
           }


if: tIF tPARO condition tPARF action_if tACO instructions tACF %prec tIFX {
                    //patching previous jump 
                    int16_t current_instru;
                    current_instru = get_instrutab_index(instrup);
                  //  patch_instru(instrup,instruction_to_patch,higher_bits(current_instru),lower_bits(current_instru),0);
                    printf("ON PATCHE LA LIGNE : %d\n",$5);
                    patch_instru(instrup,$5,higher_bits(current_instru),lower_bits(current_instru),0);
  
            } 
  | tIF tPARO condition tPARF action_if
    tACO instructions tACF  {    
                       //patching previous jump 
                 int16_t next_instru;
                 next_instru = get_instrutab_index(instrup) + 1 ;
                 //patch_instru(instrup,instruction_to_patch,higher_bits(next_instru),lower_bits(next_instru),0);
                 patch_instru(instrup,$5,higher_bits(next_instru),lower_bits(next_instru),0);

                 printf("JMPC -1 R0\n"); //format AC
                 //instruction_to_patch = get_instrutab_index(instrup);
                 $1 = get_instrutab_index(instrup);
                 instrutab_add(instrup,OP_JMPC,0xFF,0xFF,0); //patch me later !

            }
     tELS tACO instructions tACF  {
                  //patching previous jump 
                  int16_t current_instru;
                  current_instru = get_instrutab_index(instrup);
                  //patch_instru(instrup,instruction_to_patch,higher_bits(current_instru),lower_bits(current_instru),0);
                  patch_instru(instrup,$1,higher_bits(current_instru),lower_bits(current_instru),0);
              };
;

                                
while: tWHIL  { loop_address = get_instrutab_index(instrup); 
              } 
       tPARO condition tPARF {  instruction_to_patch = get_instrutab_index(instrup);
                                instrutab_add(instrup,OP_JMPC,0xFF,0xFF,0); //patch me later
                             } 
       tACO instructions tACF {         
                                        int next_instru = get_instrutab_index(instrup)+1;
                                        patch_instru(instrup,instruction_to_patch,higher_bits(next_instru),lower_bits(next_instru),0);
                                        printf("JMP %d 0",loop_address);
                                        instrutab_add(instrup,OP_JMP,higher_bits(loop_address),lower_bits(loop_address),42);
                                       };

condition: tTRU {
                    printf("AFC R0 1"); //true est un 1
                    instrutab_add(instrup,OP_AFC,0,0,1); //format AB
                }
         | tFAL 
                {
                    printf("AFC R0 0"); // false est un 0
                    instrutab_add(instrup,OP_AFC,0,0,0); //format AB
                }
         | operation {
                      int val_addr = symtab_pop_tmp(symtab) ;
                      if (val_addr == SYMTAB_NO_TMP_LEFT)  {
                        printf("---- MEMOIRE Error : plus de variable temporaire à pop\n");
                      } else {
                        printf("--- MEMOIRE Poped une variable temporaire\n");
                        printf("--- ASMB ---\n");
                        printf("LOAD R0 %d\n",val_addr);
                        instrutab_add(instrup,OP_LOAD,0,higher_bits(val_addr),lower_bits(val_addr)); 
                      }

}
