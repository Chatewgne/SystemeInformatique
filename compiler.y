%token tPLU tEQU tMOI tSTA tSLA tPARO tPARF tACO tACF tVIR tPOV tINT tCON tMAIN tIF tFOR tELS tRET tVAL tID

%%
start:global;
global:tMAIN tPARO tPARF tACO body tACF;
body:declaration instruction;
declaration:type tID tPOV | type tID tEQU tVAL tPOV;
type:tINT;
instruction:tID tEQU tVAL tPOV;
 