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
"<" {return tINF;}
">" {return tSUP;}
"<=" {return tIOE;}
">=" {return tSOE;}
"(" {return tPARO;}
")" {return tPARF;}
"{" {return tACO;}
"}" {return tACF;}
";" {return tPOV;}
"," {return tVIR;}
"int" {yylval.text = strdup(yytext);return tINT;}
"const" {return tCON;}
"main" {return tMAIN;}
"if" {return tIF;}
"while" {return tWHIL;}
"else" {return tELS;}
"for" {return tFOR;}
"true" {return tTRU;}
"false" {return tFAL;}
"return" {return tRET;}
"printf" {return tPRI;}
([0-9]+)|([0-9]+e[0-9]+) {yylval.nb = atoi(yytext); return tVAL;}
[a-zA-Z]([a-z]|[A-Z]|[0-9]|_)* {yylval.text = strdup(yytext); return tID;}
"//"(.)*\n {return tCOM;} 
