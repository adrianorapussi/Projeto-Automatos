%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

extern int yylex();
extern int yyparse();
extern FILE* yyin;

void yyerror(const char* s);

/* Método de impressõa em console */
void imprime(){
    char completo[4096] = "adrianoRapussi@Shell:";
    char path[2048];
    getcwd(path, sizeof(path));
    strcat(completo,path);
    strcat(completo,">> ");
    printf("%s",completo); 
}

%}
%union {
    int integer;
    float floatPonto;
    char string;
    char * stringp;
}

%token T_NEWLINE T_QUIT
%token <floatPonto> T_NUMF
%token <integer> T_NUM
%token T_SOMA T_SUB T_MULT T_DIV
%left T_SOMA T_SUB T_MULT T_DIV

%type<integer> intCalculo
%type<floatPonto> floatCalculo

%start start

%%

start: { imprime(); }
        | start line {
                       imprime();
                     }
;

line: T_NEWLINE
    | intCalculo T_NEWLINE {
                            printf("Resultado: %i\n", $1);
                           }
    | floatCalculo T_NEWLINE {
                                printf("Resultado: %f\n", $1);
                             }
    | T_QUIT T_NEWLINE { 
                        printf("Fim da execução \n"); 
                        exit(0);
                        }
;

/* Cálculo para inteiros */
intCalculo: T_NUM                   { $$ = $1; }
    | intCalculo T_SOMA intCalculo  { $$ = $1 + $3; }
    | intCalculo T_SUB intCalculo  { $$ = $1 - $3; }
    | intCalculo T_MULT intCalculo  { $$ = $1 * $3; }
;
/* Cálculo para pontos flutuantes */
floatCalculo: T_NUMF                    { $$ = $1; }
    | floatCalculo T_SOMA floatCalculo  { $$ = $1 + $3; }
    | floatCalculo T_SUB floatCalculo  { $$ = $1 - $3; }
    | floatCalculo T_MULT floatCalculo  { $$ = $1 * $3; }
    | floatCalculo T_DIV floatCalculo   { $$ = $1 / $3; }
    | intCalculo T_SOMA floatCalculo    { $$ = $1 + $3; }
    | intCalculo T_SUB floatCalculo    { $$ = $1 - $3; }
    | intCalculo T_MULT floatCalculo    { $$ = $1 * $3; }
    | intCalculo T_DIV floatCalculo     { $$ = $1 / $3; }
    | floatCalculo T_SOMA intCalculo    { $$ = $1 + $3; }
    | floatCalculo T_SUB intCalculo    { $$ = $1 - $3; }
    | floatCalculo T_MULT intCalculo    { $$ = $1 * $3; }
    | floatCalculo T_DIV intCalculo     { $$ = $1 / $3; }
    | intCalculo T_DIV intCalculo       { $$ = $1 / (float)$3; }
;

%%

int main() {
    yyin = stdin;

    do { 
        yyparse();
    } while(!feof(yyin));

    return 0;
}

void yyerror(const char* s) {
    fprintf(stderr, "Entrada inválida. Error: %s\n", s);
}
