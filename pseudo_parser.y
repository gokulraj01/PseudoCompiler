%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(char *);
int yylex(void);
FILE *inpFile, *interFile;
extern FILE *yyin;
char *currTemp = NULL;
int currTempInd = 0;

char* newTemp(){
    free(currTemp);
    currTemp = malloc(16);
    sprintf(currTemp, "t%d", currTempInd++);
    return currTemp;
}
%}

%start stmts
%union{
    char* text;
};

/* 
    ID - identifier (variable names)
    NUM - simple number
    NL - New line
    LE - <=
    GE - >=
    EE - ==
 */
%token <text> ID NUM
%token NL
    /* Operator Precedence */
%left LE GE EE
%left '%' '/' '*' '+' '-'
%nonassoc UMINUS 
    /* Keywords */
%token IF ELIF ELSE FI WHILE DO DONE FOR FROM TO SWITCH CASE ENDCASE FILE_END

/* Expression types */
%type <text> expr expr_high condn assg_lhs

%%

expr:
    expr_high { $$ = $1; }
    | '-' expr %prec UMINUS { fprintf(interFile, "%s = - %s\n", newTemp(), $2); $$ = currTemp; free($2);}
    | expr '+' expr_high { fprintf(interFile, "%s = %s + %s\n", newTemp(), $1, $3); $$ = currTemp; free($1); free($3);}
    | expr '-' expr_high { fprintf(interFile, "%s = %s - %s\n", newTemp(), $1, $3); $$ = currTemp; free($1); free($3);}

expr_high:
    NUM { $$ = strdup($1); }
    | ID { $$ = strdup($1); }
    | '(' expr ')' { $$ = strdup($2); }
    | expr_high '*' expr_high { fprintf(interFile, "%s = %s * %s\n", newTemp(), $1, $3); $$ = currTemp; free($1); free($3); }
    | expr_high '/' expr_high { fprintf(interFile, "%s = %s / %s\n", newTemp(), $1, $3); $$ = currTemp; free($1); free($3); }
    | expr_high '%' expr_high { fprintf(interFile, "%s = %s %% %s\n", newTemp(), $1, $3); $$ = currTemp; free($1); free($3); }

condn:
    expr { $$ = $1; }
    | expr '<' expr { fprintf(interFile, "%s = %s < %s\n", newTemp(), $1, $3); $$ = currTemp; free($1); free($3); }
    | expr '>' expr { fprintf(interFile, "%s = %s > %s\n", newTemp(), $1, $3); $$ = currTemp; free($1); free($3); }
    | expr LE expr { fprintf(interFile, "%s = %s <= %s\n", newTemp(), $1, $3); $$ = currTemp; free($1); free($3); }
    | expr GE expr { fprintf(interFile, "%s = %s >= %s\n", newTemp(), $1, $3); $$ = currTemp; free($1); free($3); }
    | expr EE expr { fprintf(interFile, "%s = %s == %s\n", newTemp(), $1, $3); $$ = currTemp; free($1); free($3); }

ifstmts:
    stmts
    | ELIF condn ':' ifstmts

ifelse:
    IF condn ':' ifstmts FI {}
    | IF condn ':' ifstmts ELSE stmts FI


switch_cases:
    | NL switch_cases
    | CASE NUM stmts ENDCASE switch_cases

assg_lhs: ID { $$ = strdup($1); }

stmt:
    assg_lhs '=' expr { fprintf(interFile, "%s = %s\n", $1, $3); /*free($1);*/ free($3);}
    | ifelse
    | SWITCH ID DO switch_cases DONE
    | WHILE condn DO stmts DONE
    | FOR ID FROM NUM TO NUM DO stmts DONE

stmts:
    /* null */
    | stmt stmts
    | NL stmts
    | FILE_END {YYACCEPT;}

%%

void yyerror(char* msg){
    printf("%s\n", msg);
}

void err(char *msg){
    printf("[ERROR] %s\n", msg);
    exit(EXIT_FAILURE);
}

int main(int argc, char **argv){
    yylval.text = malloc(16);
    if(argc < 3){
        printf("Use as:\n\t%s <input file> <output file>\n\n", argv[0]);
        err("Invalid format!!");
    }
    // Set input file to flex as user specified file
    printf("Parsing file %s...\n", argv[1]);
    inpFile = fopen(argv[1], "r");
    yyin = inpFile;

    // Set intermediate file to user specified one.
    interFile = fopen(argv[2], "w");
    if(!yyparse())
        printf("\nParsing complete!!\n");
}
