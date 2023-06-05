%{
#include <stdio.h>
#include <stdlib.h>
#include "pseudo_defs.h"
%}

%%

[0-9]+ {
    yylval = atoi(yytext);
    printf("NUM ");
    return NUM;
}

IF {
    printf("IF ");
    return IF;
}

ELSE {printf("ELSE ");return ELSE;}
ELIF {printf("ELIF ");return ELIF;}
FI {printf("FI ");return FI;}

[a-zA-Z][a-zA-Z0-9]* {printf("ID ");return ID;}

[\n] {return NL;}

[ \t] {}

. {printf(" \'%s\' ", yytext); return *yytext;}


%%