%{
#include <stdio.h>
void yyerror(char *);
int yylex(void);
%}

%start stmts

/* 
    ID - identifier (variable names)
    NUM - simple number
    NL - New line
    LE - <=
    GE - >=
    EE - ==
 */
%token ID NUM NL
%left LE GE EE
%left '%' '/' '*' '+' '-'
%nonassoc UMINUS 

/* Keywords */
%token IF ELIF ELSE FI

%%

expr:
    expr_high
    | '-' expr %prec UMINUS;
    | expr '+' expr_high
    | expr '-' expr_high
    | '(' expr ')';

expr_high:
    ID | NUM
    | expr_high '*' expr_high
    | expr_high '/' expr_high
    | expr_high '%' expr_high

condn:
    expr
    | expr '<' expr
    | expr '>' expr
    | expr LE expr
    | expr GE expr
    | expr EE expr

ifelse:
    IF condn ':' ifstmts FI
    | IF condn ':' ifstmts ELSE stmts FI

ifstmts:
    stmts
    | ELIF condn ':' ifstmts

stmt:
    ID '=' expr
    | ifelse

stmts:
    /* null */
    | NL stmts
    | stmt NL stmts

%%

void yyerror(char* msg){
    printf("%s", msg);
}

int main(void){
    yyparse();
}
