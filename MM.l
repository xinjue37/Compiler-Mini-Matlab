%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <time.h>
    #include "data_struct.h"
    #include "MM.tab.h"
    void yyerror(char*);
    int symLookup(char *s);    
    
    // Declaration of variable
    int START_ID = 100;  // ID 0-99 is reserved for keyword
    int current_id;                      // Store the index of current usable id to store the variable        
    SymbolTable *list_name = NULL;       // pointer that point to the last node in the linked_list
    SymbolTable *start_list_name = NULL; // pointer that point to the start of list_name
    
%}

%%
0                   {
                        yylval.dValue = atof(yytext);
                        return DOUBLE;
                    }
[1-9][0-9]*         {    
                        yylval.dValue = atof(yytext);
                        return DOUBLE;
                    } 

[0-9]+[.][0-9]*     {  
                        yylval.dValue = atof(yytext);
                        return DOUBLE;
                    }

[-^()=+*{}/;,.\n]   { return *yytext; }
"["                 { return *yytext; }
"]"                 { return *yytext; }
[a-zA-Z][A-Za-z0-9]* {  
                        if (list_name == NULL){  // If it is NULL, declared it
                            list_name = malloc(sizeof(SymbolTable));
                            list_name->nextSymbol = NULL;
                            start_list_name = list_name;
                            current_id = START_ID;
                        }
                        yylval.id = symLookup(yytext);
                        return IDENTIFIER;
                    }
[ \t]               { ; }                           // ignore whitespace 
.                   yyerror("Unknown character");   // All other character is considered as unknown

%%

int yywrap(){ return 1; }

int symLookup(char *s){
    /* 
        range [0 ,20) is function with 1 argument
        range [20,30) is function with 2 arguments
        range [30,40) is function with 3 arguments
        range [40,50) is function without argument 
    */
    if (strcmp(s, "sin") == 0)           return 0;
    else if(strcmp(s, "cos") == 0)       return 1;
    else if(strcmp(s, "tan") == 0)       return 2;
    else if (strcmp(s, "asin") == 0)     return 3;
    else if(strcmp(s, "acos") == 0)      return 4;
    else if(strcmp(s, "atan") == 0)      return 5;
    else if(strcmp(s, "round") == 0)     return 6;
    else if(strcmp(s, "ceil") == 0)      return 7;
    else if(strcmp(s, "floor") == 0)     return 8;
    else if(strcmp(s, "exp") == 0)       return 9;
    else if(strcmp(s, "log") == 0)       return 10;
    else if(strcmp(s, "log10") == 0)     return 11;
    else if(strcmp(s, "sqrt") == 0)      return 12;
    else if(strcmp(s, "length") ==0)     return 13;
    else if(strcmp(s, "size") ==0)       return 14;
    else if(strcmp(s, "ndims") ==0)      return 15;
    else if(strcmp(s, "numel") ==0)      return 16;
    else if(strcmp(s, "transpose") == 0) return 17;
    
    else if(strcmp(s, "mod") == 0)       return 20;
    else if(strcmp(s, "horzat") == 0)    return 21;
    else if(strcmp(s, "verzat") == 0)    return 22;
    else if(strcmp(s, "zeros") ==0)      return 23;
    else if(strcmp(s, "ones") ==0)       return 24;

    else if(strcmp(s, "reshape") == 0)   return 30;
    else if(strcmp(s, "linspace") ==0)   return 31;
    else if(strcmp(s, "logspace") ==0)   return 32;

    else if(strcmp(s, "clc") ==0)        return 40;
    else if(strcmp(s, "ans") ==0)        return 41;
    else if(strcmp(s, "datetime")==0)    return 42;
    else if(strcmp(s, "calendar")==0)    return 43;

    /* Identifier */
    else{
        SymbolTable *temp_list_name = start_list_name;
        int temp_id                 = START_ID;
        while (temp_list_name->nextSymbol != NULL){  // Check is this identifier already be declared
            if (strcmp(temp_list_name->name,s) ==0 )  // If the identifier exist
                return temp_id;
            temp_id ++;
            temp_list_name = temp_list_name->nextSymbol;
        }
            
        if (temp_list_name->nextSymbol == NULL){  // If the identifier not exist
            for (int i=0; i< strlen(s); i++)      // Store the name of identifier
                list_name->name[i] = s[i];           
            list_name->name[strlen(s)] = '\0';   // Indicate the end of string     

            list_name->nextSymbol = malloc(sizeof(SymbolTable)); // Allocate memory to next symbol
            list_name             = list_name->nextSymbol;         // Point to next pointer
            list_name->nextSymbol = NULL;
            return current_id++;
        }
    }
}
