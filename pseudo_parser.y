%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define STACK_SIZE 128
#define TEMP_SIZE 16

void yyerror(char *);
int yylex(void);
FILE *inpFile, *interFile;
extern FILE *yyin;
char *currTemp = NULL;
int currTempInd = 0, currLabInd = 0;

char* newTemp(char* prefix, int* index){
    currTemp = malloc(TEMP_SIZE);
    sprintf(currTemp, "%s%d", prefix, (*index)++);
    return currTemp;
}

// Stack declarations
struct Stack{
    char **data;
    int top;
};
struct Stack condStack, labelStack;
char* pop(struct Stack *s){
    if(s->top > -1) return s->data[s->top--]; else return NULL;
}
void push(char* item, struct Stack *s){
    if(s->top < STACK_SIZE)
        s->data[++s->top] = strdup(item);
}
%}

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
%start stmts

%%

stmts:
    /* null */
    | stmt stmts
    | NL stmts
    | FILE_END {YYACCEPT;}

expr:
    expr_high { $$ = $1; }
    | '-' expr %prec UMINUS { fprintf(interFile, "%s = - %s\n", newTemp("t", &currTempInd), $2); $$ = currTemp; free($2);}
    | expr '+' expr_high { fprintf(interFile, "%s = %s + %s\n", newTemp("t", &currTempInd), $1, $3); $$ = currTemp; free($1); free($3);}
    | expr '-' expr_high { fprintf(interFile, "%s = %s - %s\n", newTemp("t", &currTempInd), $1, $3); $$ = currTemp; free($1); free($3);}

expr_high:
    NUM { $$ = strdup($1); }
    | ID { $$ = strdup($1); }
    | '(' expr ')' { $$ = strdup($2); }
    | expr_high '*' expr_high { fprintf(interFile, "%s = %s * %s\n", newTemp("t", &currTempInd), $1, $3); $$ = currTemp; free($1); free($3); }
    | expr_high '/' expr_high { fprintf(interFile, "%s = %s / %s\n", newTemp("t", &currTempInd), $1, $3); $$ = currTemp; free($1); free($3); }
    | expr_high '%' expr_high { fprintf(interFile, "%s = %s %% %s\n", newTemp("t", &currTempInd), $1, $3); $$ = currTemp; free($1); free($3); }

condn:
    expr { $$ = $1; }
    | expr '<' expr { fprintf(interFile, "%s = %s < %s\n", newTemp("t", &currTempInd), $1, $3); $$ = currTemp; free($1); free($3); }
    | expr '>' expr { fprintf(interFile, "%s = %s > %s\n", newTemp("t", &currTempInd), $1, $3); $$ = currTemp; free($1); free($3); }
    | expr LE expr { fprintf(interFile, "%s = %s <= %s\n", newTemp("t", &currTempInd), $1, $3); $$ = currTemp; free($1); free($3); }
    | expr GE expr { fprintf(interFile, "%s = %s >= %s\n", newTemp("t", &currTempInd), $1, $3); $$ = currTemp; free($1); free($3); }
    | expr EE expr { fprintf(interFile, "%s = %s == %s\n", newTemp("t", &currTempInd), $1, $3); $$ = currTemp; free($1); free($3); }

cond__: { push(currTemp, &condStack); }
if__: {
    // Get latest condition clause
    char* temp = pop(&condStack);
    fprintf(interFile, "assert %s ", temp);
    free(temp);
    // Return location 
    temp = newTemp("# label", &currLabInd);
    push(temp, &labelStack);

    fprintf(interFile, "goto %s\n%s:\n", temp, newTemp("# label", &currLabInd));
}
else__: {
    char* temp = pop(&labelStack);
    fprintf(interFile, "%s\n", temp);
}

ifstmts:
    stmts
    | ELIF condn cond__ ':' if__ ifstmts

ifelse:
    IF condn cond__ ':' if__ ifstmts FI else__
    | IF condn cond__ ':' if__ ifstmts ELSE else__ stmts FI

switch_cases:
    | NL switch_cases
    | CASE NUM stmts ENDCASE switch_cases

assg_lhs: ID { $$ = strdup($1); }

while__: {
    // Get latest condition clause
    char* temp = condStack.data[condStack.top];
    fprintf(interFile, "assert %s ", temp);
    // Return location 
    temp = newTemp("# label", &currLabInd);
    push(temp, &labelStack);

    fprintf(interFile, "goto %s\n%s:\n", temp, newTemp("# label", &currLabInd));
}

endwhile__: {
    char* temp = pop(&condStack);
}

stmt:
    assg_lhs '=' expr { fprintf(interFile, "%s = %s\n", $1, $3); free($1); free($3); }
    | ifelse
    | SWITCH ID DO switch_cases DONE
    | WHILE condn cond__ DO if__ stmts endwhile__ DONE
    | FOR ID FROM NUM TO NUM DO stmts DONE
%%

void yyerror(char* msg){
    printf("%s\n", msg);
}

void err(char *msg){
    printf("[ERROR] %s\n", msg);
    exit(EXIT_FAILURE);
}

int main(int argc, char **argv){
    /* Initialize the stack pointers*/
    condStack.data = malloc(sizeof(condStack.data)*STACK_SIZE);
    condStack.top = -1;
    labelStack.data = malloc(sizeof(labelStack.data)*STACK_SIZE);
    labelStack.top = -1;

    yylval.text = malloc(TEMP_SIZE);
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
