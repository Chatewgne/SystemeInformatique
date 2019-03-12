%{
    #include "y.tab.h"
%}

%% 
[ \t\n]+ ;
"=" {return tEQU ;}
"+" {return tPLU ;}
"-" {return tMOI;}
"*" {return tSTA;}
"/" {return tSLA;}
"(" {return tPARO;}
")" {return tPARF;}
"{" {return tACO;}
"}" {return tACF;}
";" {return tPOV;}
"," {return tVIR;}
"int" {return tINT;}
"const" {return tCON;}
"main" {return tMAIN;}
"if" {return tIF;}
"else" {return tELS;}
"for" {return tFOR;}
"return" {return tRET;}
([0-9]+)|([0-9]+e[0-9]+) {yylval.text = strdup(yytext); return tVAL;}
[a-zA-Z]([a-z]|[A-Z]|[0-9]|_)* {yylval.text = strdup(yytext); return tID;}
