%{
#include <stdio.h>
#include <stdlib.h>
%}

%%

[0-9]+ {
    printf("NUM ");
}

IF {
    printf("IF ");
    
}

ELSE {printf("ELSE ");}
ELIF {printf("ELIF ");}
FI {printf("FI ");}

[a-zA-Z][a-zA-Z0-9]* {printf("ID ");}

. {}

%%