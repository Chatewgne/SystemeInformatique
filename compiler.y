%token tPLU tEQU tMOI tSTA tSLA tPARO tPARF tACO tACF tVIR tPOV tINT tCON tMAIN tIF tFOR tELS tRET tVAL tID

%%
start:global;
global:tMAIN tPARO tPARF tACO body tACF;
body: tID tEQU tVAL tPOV;
