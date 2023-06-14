%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "pseudo_defs.h"
%}

%%
    /* Ignore comments */
#.* {}

    /* Number clause */
([0-9]*\.[0-9]+|[0-9]+) {
    strncpy(yylval.text, yytext, 16);
    printf("NUM ");
    return NUM;
}

    /* IF tokens */
IF {printf("IF "); return IF;}
ELSE {printf("ELSE ");return ELSE;}
ELIF {printf("ELIF ");return ELIF;}
FI {printf("FI ");return FI;}

    /* WHILE tokens */
WHILE {printf("WHILE "); return WHILE;}
DONE {printf("DONE "); return DONE;}
DO {printf("DO "); return DO;}

    /* FOR tokens */
FOR {printf("FOR "); return FOR;}
FROM {printf("FROM "); return FROM;}
TO {printf("TO "); return TO;}

    /* SWITCH tokens */
SWITCH {printf("SWITCH "); return SWITCH;}
CASE {printf("CASE "); return CASE;}
ENDCASE {printf("ENDCASE "); return ENDCASE;}

    /* Condition tokens */
"<=" {printf("LE"); return LE;}
">=" {printf("GE"); return GE;}

    /* Identifier clause */
[a-zA-Z][a-zA-Z0-9]* {
    strncpy(yylval.text, yytext, 16);
    printf("ID[%s] ", yylval.text);
    return ID;
}

    /* New lines and whitespace skip */
[\n]* {putchar('\n'); return NL;}
[ \t] {}

    /* Catch all clause */
. {printf(" \'%s\' ", yytext); return *yytext;}

<<EOF>> {return FILE_END;}
%%