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
    char completo[4096] = "adrianoRapussiShell:";
    char path[2048];
    getcwd(path, sizeof(path));
    strcat(completo,path);
    strcat(completo,"---->");
    printf("%s",completo); 
}

%}
%union {
    int integer;
    float floatPonto;
    char string;
    char * pontString;
}

%token T_PS T_INVALIDO T_KILL T_LS T_MKDIR T_RMDIR T_NEWLINE T_QUIT T_CD T_TOUCH T_IFCONFIG T_START
%token <pontString> T_ARG
%token <pontString> T_FOLDERARG
%token <floatPonto> T_NUMF
%token <integer> T_NUM
%token T_SOMA T_SUB T_MULT T_DIV
%left T_SOMA T_SUB T_MULT T_DIV

%type<string> action
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
    | action T_NEWLINE  
    | intCalculo T_NEWLINE {   
                            printf("Saída = %i\n", $1);
                        }
    | floatCalculo T_NEWLINE { 
                            printf("Saída = %f\n", $1);
                          }
    | T_QUIT T_NEWLINE { printf("Fim da execução \n"); exit(0); }
;
//Comandos de execução da shell
action: T_CD T_FOLDERARG {
                            int representative = chdir($2);
                            if(representative != 0){
                                printf("Erro, Pasta não encontrada \n");
                            }
                          }
       | T_CD T_ARG {
                        int representative;
                        char path[2048];
                        getcwd(path, sizeof(path));
                        strcat(path, "/");
                        strcat(path, $2);
                        printf("cd com entrada");
                        representative = chdir(path);
                        if(representative != 0){
                            printf("Erro, Pasta não encontrada \n");
                        }
                    }
        | T_LS { 
                    system("/bin/ls");
                 }
        | T_PS {
                    system("/bin/ps");
                 }
        | T_IFCONFIG { 
                        system("ifconfig");
                     }
        | T_KILL T_NUM {  
                         char string[100], lastString[1000] = "/bin/kill ";
                         int i, rem, len = 0, n;
                         n = $2;
                         while (n != 0)
                         {
                             len++;
                             n /= 10;
                         }
                         for (i = 0; i < len; i++)
                         {
                             rem = $2 % 10;
                             $2 = $2 / 10;
                             string[len - (i + 1)] = rem + '0';
                         }
                         string[len] = '\0';
                         strcat(lastString, string);
                         system(lastString); 
                     }
       | T_MKDIR T_ARG {
                         char lastString[1000] = "/bin/mkdir ";
                         strcat(lastString, $2);
                         system(lastString);
                       }
       | T_RMDIR T_ARG {
                         char lastString[1000] = "/bin/rmdir ";
                         strcat(lastString, $2);
                         system(lastString);
                       }

        | T_TOUCH T_ARG {
                          char lastString[1000] = "/bin/touch ";
                          strcat(lastString, $2);
                          system(lastString);
                        }
        | T_START T_ARG { 
                            if(fork() == 0){
                                system($2);
                                exit(0);
                            } 
                        }
        | T_ARG { 
                    yyerror("Entrada inválida");
                 }
        | T_FOLDERARG {
                         yyerror("Entrada inválida");
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
