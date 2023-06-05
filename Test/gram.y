%{
#include <stdio.h>
int yyerror(char *);
int yylex(void);
%}

%union{
    char *str;
}

%token IF ELSE FI NUM

%%

program: statement
        | program statement

statement: IF NUM ':' s2 FI
        | IF NUM ':' s2 ELSE s2 FI
        | NUM

s2: | statement

%%

int main() {
    yyparse();
    return 0;
}

int yyerror(char *msg) {
    fprintf(stderr, "Error: %s\n", msg);
    return 0;
}
