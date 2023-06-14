#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int currTempInd = 0;
char *tempVar;

char* assignTemp(){
    sprintf(tempVar, "t%d", currTempInd++);
    return tempVar;
}

void main(){
    tempVar = malloc(8);
    for(int i=0; i<100; i++){
        printf("%s, ", assignTemp());
    }
}