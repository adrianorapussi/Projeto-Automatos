%{
#include <stdio.h>

#define YY_DECL int yylex()

#include "rapussiBison.tab.h"

%}

%%
[ \t]    ; //ignora espaços em branco
\n      {return T_NEWLINE;}
"+"         {return T_SOMA;}
"-"         {return T_SUB;}
"*"         {return T_MULT;}
"/"         {return T_DIV;}
[0-9]+      {
                yylval.integer = atoi(yytext); 
                return T_NUM;
            }
[0-9]+\.[0-9]+  {
                    yylval.floatPonto = atof(yytext); 
                    return T_NUMF;
                }

%%
