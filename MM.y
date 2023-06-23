%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <math.h>
    #include <string.h>
    #include <stdarg.h>
    #include <time.h>
    #include "data_struct.h"

    /* Declaration of function*/
    // 1. Function to print out the expression
    void print_expr(nodeType* );

    // 2. Function to store the constant, matrix and 'arguments number for each IDENTIFIER'
    nodeType *con(double value);
    nodeType *store_matrix();  
    void saved_arguments_num();
    
    // 3. Function to perform function operation [IDENTIFIER '(' arguments ')']
    nodeType *func_operation();
    
    // 3.1 Function to perform arithmetric and U-arithmetric (E.g. U-MINUS) operation
    nodeType *arithmetric(nodeType *a, nodeType *b, char opr1);
    nodeType *U_arithmetric(nodeType *a, char opr1);
    double calculate(double a, double b, char opr1);
    double U_calculate(double a, char opr1);

    // 3.2 Function to perform basic function operation. E.g. sin(), cos(), mod(),...
    double apply_function(int num, ...);

    // 3.3 Function to perform matrix and vector operation
    nodeType* create_array(nodeType* rowNode, nodeType* colNode, double value);
    nodeType* reshape_array(nodeType* a, nodeType* new_row, nodeType* new_col);
    nodeType* horzat_array(nodeType* matrix1, nodeType* matrix2);
    nodeType* verzat_array(nodeType* matrix1, nodeType* matrix2);
    nodeType* linspace(double start, double stop, double num);
    nodeType* logspace(double start, double stop, double num);
    nodeType* transpose_array(nodeType* input);

    // 3.4 Function to show to current datetime and calender
    void show_datetime();
    void show_calender();

    // 4. Function needed in .lex file
    int yylex(void);
    void yyerror(char *s);
    
    /* Declare of variables */
    int MAX_NUM_SYMBOL = 500;       // 500 = Total number of identifier available for the program
    int MAX_NUM_ARGS   = 10;        // 10  = Total number of arguments available for the program
    nodeType **symbols;             // a pointer to store list of variables
    nodeType **arguments;           // a pointer to store list of arguments
    int symbols_id[500];            // To indicate whether the data have been assigned value before 
    double matrix_buffer[50][50];   // Matrix maximum size
    int func_arg[100];              // Array to store number of argument that a function should have
    int error_flag = 0;             // A flag to indicate whether the programmer type some syntax wrongly
    int row=0, col=0;               // Variable to store row and col of a matrix
    int count_arg;                  // Variable to count the number of arguments for a function
    int temp_Identifier = 0;        // Variable to store temperary identifier for a variable
    nodeType* ans;                  // Variable to store latest display answer in screen
    
%}

%union {                        
    int id;                 /* Integer value */
    double dValue;          /* Double value*/
    nodeType* nPtr;
};    
 
// Declaration of datatype for terminal and non-terminal
%token <id> IDENTIFIER
%token <dValue> DOUBLE 
%type <nPtr> expr 

// Declaration of  all operator used and assign the priority to difference operation
%left ';' ','
%left '+' '-' 
%left '*' '/' 
%left '^'
%nonassoc UMINUS UPLUS  
%nonassoc '(' ')'


%%
program: program stmt '\n'
         | ;                       

stmt:   IDENTIFIER '=' expr       { symbols[$1] = malloc(sizeof(nodeType));
                                    symbols[$1] = $3;
                                    symbols_id[$1] = 1;
                                    }      
        | expr                    { if (!(temp_Identifier == 40|| temp_Identifier == 41|| temp_Identifier == 42 || temp_Identifier == 43)){
                                        print_expr($1);
                                        ans = $1;
                                    }
                                  }
         
expr:    expr '+' expr                { $$ = arithmetric($1, $3, '+');
                                        if (error_flag) return 1;
                                      }
         | expr '-' expr              { $$ = arithmetric($1, $3, '-');
                                        if (error_flag) return 1;
                                      }
         | expr '*' expr              { $$ = arithmetric($1, $3, '*');
                                        if (error_flag) return 1;
                                      }
         | expr '/' expr              { $$ = arithmetric($1, $3, '/');
                                        if (error_flag) return 1;
                                      }
         | expr '^' expr              { $$ = arithmetric($1, $3, '^');
                                        if (error_flag) return 1;
                                      }        
         | '-' expr %prec UMINUS      { $$ = U_arithmetric($2, '-');
                                        if (error_flag) return 1;
                                      }        
         | '+' expr %prec UPLUS       { $$ = U_arithmetric($2, '+');
                                        if (error_flag) return 1;
                                      }        
         | '(' expr ')'               { $$ = $2; }

         | IDENTIFIER '(' argument ')'  {
                                            if ($1 >= 100){
                                                yyerror("The identifier is not a function");
                                                return 1;
                                            }
                                            temp_Identifier = $1;
                                            if (count_arg > func_arg[temp_Identifier]) {
                                                printf("The arguments number exceed the argument allowed. Current: %d, Correct: %d.\n", count_arg, func_arg[temp_Identifier]);
                                                return 1;
                                            }
                                            $$ = func_operation();
                                            if (error_flag) return 1;
                                        }
         | DOUBLE                       { $$ = con($1);   }
         | IDENTIFIER                   { temp_Identifier = $1;
                                          if (symbols_id[$1] == 1) { $$ = symbols[$1]; }
                                          else if($1 == 40) { printf("\e[1;1H\e[2J"); }
                                          else if($1 == 41) { print_expr(ans); }
                                          else if($1 == 42) { show_datetime(); }
                                          else if($1 == 43) { show_calender(); }
                                          else{
                                            yyerror("Undeclared Identifier!");
                                            return 1;
                                          }
                                        }
          | '[' matrix ']'              { temp_Identifier = 0;
                                          $$ = store_matrix();
                                          row=0;  col=0; // Reset the row and column
                                        }

argument:   argument ','  expr          {
                                          arguments[count_arg] = malloc(sizeof(nodeType));
                                          arguments[count_arg] = $3;
                                          count_arg++;
                                        }

            | expr                      { count_arg = 0;
                                          arguments[count_arg] = malloc(sizeof(nodeType));
                                          arguments[count_arg] = $1;
                                          count_arg++;
                                        }

matrix:  matrix ';' matrix              { ; }
         | vector                       {row ++;}

vector:  vector DOUBLE                  {matrix_buffer[row][col++] = $2; }
         | vector ',' DOUBLE            {matrix_buffer[row][col++] = $3;}
         | DOUBLE                       { col = 0;  
                                          matrix_buffer[row][col++] = $1;}
%%

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}

int main(void) {
    ans       = malloc(sizeof(nodeType));
    symbols   = malloc(MAX_NUM_SYMBOL*sizeof(nodeType));
    arguments = malloc(MAX_NUM_ARGS*sizeof(nodeType));
    saved_arguments_num();
    yyparse();
    return 0;
}

void print_expr(nodeType* p){
    printf("out: ");
    if (p->type == typeConstant)
    {
        printf("%.4lf\n",p->cons);
    }
    else if (p->type == typeVector){
        printf("[ ");
        for (int i=0; i<p->vec.length; i++)
            printf("%.4lf ",p->vec.vector[i]);
        printf("]\n");
    }
    else if (p->type == typeMatrix){
        printf("[ ");
        for (int i=0; i< p->mat.row; i++){
            for (int j=0; j<p->mat.col; j++)
                printf("%lf ",p->mat.matrix[i][j]);
            if (i < p->mat.row-1)
                printf("\n      ");
        }
        printf("]\n");
    }
}

nodeType *con(double value) {
    nodeType *p;      // Declare a pointer of node

    /* allocate node */
    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeConstant;
    p->cons = value;

    return p;
}

nodeType* store_matrix(){
    nodeType *node = malloc(sizeof(nodeType));

    if (row == 1){ // It is a vector
        node->type = typeVector;
        node->vec.length = col;
        node->vec.vector = malloc(sizeof(double) * col);

        for (int i=0; i< col; i++)
            node->vec.vector[i] = matrix_buffer[row-1][i];
    }
    else {    //It is a matrix
        
        node->type = typeMatrix;
        node->mat.row = row;
        node->mat.col = col;
        node->mat.matrix = malloc(sizeof(double) * row * col);   
        for (int i=0; i< row; i++){
            node->mat.matrix[i] = malloc(sizeof(double) * col);
            for (int j =0; j< col; j++)
                node->mat.matrix[i][j] = matrix_buffer[i][j];
        }
    }

    return node;
}

void saved_arguments_num(){
    for (int i=0; i<20; i++)        // Function that have 1 argument
        func_arg[i] = 1;
    for (int i=20; i<30; i++)       // Function that have 2 arguments
        func_arg[i] = 2;
    for (int i =30; i<40; i++)      // Function that have 3 arguments
        func_arg[i] = 3;
}

nodeType *func_operation(){
    nodeType *p = malloc(sizeof(nodeType));

    switch (count_arg){
        case 1:
        {
            if (temp_Identifier < 20)
            {
                if (arguments[0]->type == typeConstant){
                    p->type = typeConstant;
                    p->cons = apply_function(count_arg, arguments[0]->cons);
                }
                else if (arguments[0]->type == typeVector){
                    if (temp_Identifier >=0 && temp_Identifier <=12){
                        p->type = typeVector;
                        p->vec.length = arguments[0]->vec.length;
                        p->vec.vector = malloc(sizeof(arguments[0]->vec.vector));
                        
                        for (int i=0; i<p->vec.length; i++)
                            p->vec.vector[i] = apply_function(count_arg, arguments[0]->vec.vector[i]); 
                    }
                    else if (temp_Identifier == 13){
                        p->type = typeConstant;
                        p->cons = arguments[0]->vec.length;
                    }
                    else if (temp_Identifier == 14){
                        p->type = typeVector;
                        p->vec.vector = malloc(sizeof(double) * 1);
                        p->vec.length = 1;
                        p->vec.vector[0] = arguments[0]->vec.length;
                    }
                    else if (temp_Identifier == 15){
                        p->type = typeConstant;
                        p->cons = 1;
                    }
                    else if (temp_Identifier == 16){
                        p->type = typeConstant;
                        p->cons = arguments[0]->vec.length;
                    }
                    else if (temp_Identifier == 17){
                            return transpose_array(arguments[0]);
                    }
                }
                else if (arguments[0]->type == typeMatrix){
                    if (temp_Identifier >=0 && temp_Identifier <=12){
                        p->type = typeMatrix;
                        p->mat.row    = arguments[0]->mat.row;
                        p->mat.col    = arguments[0]->mat.col;
                        p->mat.matrix = malloc(sizeof(double) * p->mat.row * p->mat.col);
                        
                        for (int i=0; i< p->mat.row; i++){
                            p->mat.matrix[i] =  malloc(sizeof(double) * p->mat.col);
                            for (int j =0; j< p->mat.col; j++){
                                p->mat.matrix[i][j] = apply_function(count_arg, arguments[0]->mat.matrix[i][j]);
                            }
                        }
                    }
                    else if (temp_Identifier == 13){
                        p->type = typeConstant;
                        p->cons = arguments[0]->mat.row > arguments[0]->mat.col ? arguments[0]->mat.row : arguments[0]->mat.col;
                    }
                    else if (temp_Identifier == 14){
                        p->type = typeVector;
                        p->vec.vector = malloc(sizeof(double) * 2);
                        p->vec.length = 2;
                        p->vec.vector[0] = arguments[0]->mat.row;
                        p->vec.vector[1] = arguments[0]->mat.col;
                    }
                    else if (temp_Identifier == 15){
                        p->type = typeConstant;
                        p->cons = 2;
                    }
                    else if (temp_Identifier == 16){
                        p->type = typeConstant;
                        p->cons = arguments[0]->mat.row * arguments[0]->mat.col;
                    }
                    else if (temp_Identifier == 17){
                            return transpose_array(arguments[0]);
                    }
                } 
            }
            else
            {
                printf("The arguments number are too few, %d. Use %d arguments.\n", count_arg, func_arg[temp_Identifier]);
                error_flag = 1;
                return NULL;
            }
            break;
        }
        case 2:
        {
            if (temp_Identifier >= 20 && temp_Identifier < 30)
            {
                if (arguments[0]->type == typeConstant && arguments[1]->type == typeConstant){
                    if (temp_Identifier == 23){
                        return create_array(arguments[0], arguments[1], 0.0);
                    } 
                    else if (temp_Identifier == 24){
                        return create_array(arguments[0], arguments[1], 1.0);
                    }
                    else if (temp_Identifier == 20){
                        p->type = typeConstant;
                        p->cons = apply_function(count_arg, arguments[0]->cons, arguments[1]->cons);
                    }
                    else{
                        printf("Incorrect format of arguments.\n");
                        error_flag = 1;
                        return NULL;
                    }
                }
                else if (arguments[0]->type == typeVector && arguments[1]->type == typeConstant){
                    if (temp_Identifier == 20){
                        p->type = typeVector;
                        p->vec.length = arguments[0]->vec.length;
                        p->vec.vector = malloc(sizeof(arguments[0]->vec.vector));
                        
                        for (int i=0; i<p->vec.length; i++)
                            p->vec.vector[i] = apply_function(count_arg, arguments[0]->vec.vector[i], arguments[1]->cons); 
                    }
                    else{
                        printf("Incorrect format of arguments.\n");
                        error_flag = 1;
                        return NULL;
                    }
                }
                else if (arguments[0]->type == typeMatrix && arguments[1]->type == typeConstant){
                    if (temp_Identifier == 20){
                        p->type = typeMatrix;
                        p->mat.row    = arguments[0]->mat.row;
                        p->mat.col    = arguments[0]->mat.col;
                        p->mat.matrix = malloc(sizeof(double) * p->mat.row * p->mat.col);
                        
                        for (int i=0; i< p->mat.row; i++){
                            p->mat.matrix[i] =  malloc(sizeof(double) * p->mat.col);
                            for (int j =0; j< p->mat.col; j++){
                                p->mat.matrix[i][j] = apply_function(count_arg, arguments[0]->mat.matrix[i][j], arguments[1]->cons);
                            }
                        }
                    }
                    else{
                        printf("Incorrect format of arguments.\n");
                        error_flag = 1;
                        return NULL;
                    }
                }
                else if (arguments[0]->type == typeMatrix && arguments[1]->type == typeMatrix ){
                    if (temp_Identifier == 21)
                        return horzat_array(arguments[0], arguments[1]);
                    else if (temp_Identifier == 22)
                        return verzat_array(arguments[0], arguments[1]);
                    else{
                        printf("Incorrect format of arguments.\n");
                        error_flag = 1;
                        return NULL;
                    }
                }
                else{
                    printf("Incorrect format of arguments.\n");
                    error_flag = 1;
                    return NULL;
                }
            }
            else
            {
                printf("The arguments number are too few, %d. Use %d arguments.\n", count_arg, func_arg[temp_Identifier]);
                error_flag = 1;
                return NULL;
            }
            break;
        }
        case 3:
        {
            if (temp_Identifier >= 30 && temp_Identifier < 40)
            {
                if ((arguments[0]->type == typeMatrix || arguments[0]->type == typeVector) && arguments[1]->type == typeConstant && arguments[2]->type == typeConstant){ 
                    if (temp_Identifier == 30){
                        return reshape_array(arguments[0], arguments[1], arguments[2]);
                    }
                    else{
                        printf("Incorrect format of arguments.\n");
                        error_flag = 1;
                        return NULL;
                    }
                }
                else if (arguments[0]->type == typeConstant && arguments[1]->type == typeConstant && arguments[2]->type == typeConstant){
                    if (temp_Identifier == 31)
                        return linspace(arguments[0]->cons, arguments[1]->cons, arguments[2]->cons);
                    else if (temp_Identifier == 32)
                        return logspace(arguments[0]->cons, arguments[1]->cons, arguments[2]->cons);
                    else{
                        printf("Incorrect format of arguments.\n");
                        error_flag = 1;
                        return NULL;
                    }
                }
                else{
                    printf("Incorrect format of arguments.\n");
                    error_flag = 1;
                    return NULL;
                }
                
            }
            else
            {
                printf("The arguments number are too few, %d. Use %d arguments.\n", count_arg, func_arg[temp_Identifier]);
                error_flag = 1;
                return NULL;
            }
            break;
        }
        default:
            error_flag = 1;
            return NULL;
    }

    return p;
}

nodeType *arithmetric(nodeType *a, nodeType *b, char opr1){
    nodeType *p = malloc(sizeof(nodeType));
    if (a->type == typeConstant && b->type == typeConstant){
        p->type = typeConstant;
        p->cons = calculate(a->cons, b->cons, opr1);
    }
    else if (a->type == typeVector && b->type == typeVector){
        if (a->vec.length == b->vec.length){
            p->type = typeVector;
            p->vec.length = a->vec.length;
            p->vec.vector = malloc(sizeof(a->vec.vector));
            for (int i=0; i<p->vec.length; i++)
                p->vec.vector[i] = calculate(a->vec.vector[i], b->vec.vector[i], opr1);
        }
        else{
            error_flag = 1;
            printf("The vector have difference length a: %d, b:%d\n",a->vec.length, b->vec.length);
        }
    }
    else if (a->type == typeMatrix && b->type == typeMatrix){
        if (a->mat.row == b->mat.row && a->mat.col == b->mat.col ){
            p->type = typeMatrix;
            p->mat.row   = a->mat.row;
            p->mat.col   = a->mat.col;
            p->mat.matrix = malloc(sizeof(double) * p->mat.row * p->mat.col);
            for (int i=0; i< p->mat.row; i++){
                p->mat.matrix[i] =  malloc(sizeof(double) * p->mat.col);
                for (int j =0; j< p->mat.col; j++){
                    p->mat.matrix[i][j] = calculate(a->mat.matrix[i][j], b->mat.matrix[i][j], opr1);
                }
            }
        }
        else{
            error_flag = 1;
            printf("The matrix have difference shape a: (%d,%d), b:(%d,%d)\n",a->mat.row, a->mat.col, b->mat.row, b->mat.col);
        }
    }
    else{
        error_flag = 1;
    }
    return p;
}

nodeType *U_arithmetric(nodeType *a, char opr1){
    nodeType *p = malloc(sizeof(nodeType));
    if (a->type == typeConstant ){
        p->type = typeConstant;
        p->cons = U_calculate(a->cons, opr1);
    }
    else if (a->type == typeVector){
        p->type = typeVector;
        p->vec.length = a->vec.length;
        p->vec.vector = malloc(sizeof(a->vec.vector));
        for (int i=0; i<p->vec.length; i++)
            p->vec.vector[i] = U_calculate(a->vec.vector[i], opr1); 
    }
    else if (a->type == typeMatrix){
        p->type = typeMatrix;
        p->mat.row   = a->mat.row;
        p->mat.col   = a->mat.col;
        p->mat.matrix = malloc(sizeof(double) * p->mat.row * p->mat.col);
        for (int i=0; i< p->mat.row; i++){
            p->mat.matrix[i] =  malloc(sizeof(double) * p->mat.col);
            for (int j =0; j< p->mat.col; j++){
                p->mat.matrix[i][j] = U_calculate(a->mat.matrix[i][j], opr1);
            }
        }
    }

    return p;
}

double calculate(double a, double b, char opr1){
    if (opr1 == '+')      return a+b;
    else if (opr1 == '-') return a-b;
    else if (opr1 == '*' )return a*b;
    else if (opr1 == '/') return a/b;
    else if (opr1 == '^') return pow(a,b);
}

double U_calculate(double a, char opr1){
    if (opr1 == '+')      return a;
    else if (opr1 == '-') return -a;
}

double apply_function(int num, ...){
    double result;
    double temp_arr[MAX_NUM_ARGS];
    va_list valist;
    va_start(valist, num);          // Initialize valist for num of number of arguments

    switch(temp_Identifier){
        /* Functions with 1 argument */
        case 0:  result = sin(va_arg(valist, double));   break;        // access all the arguments assigned to valist
        case 1:  result = cos(va_arg(valist, double));   break;
        case 2:  result = tan(va_arg(valist, double));   break;
        case 3:  result = asin(va_arg(valist, double));  break;
        case 4:  result = acos(va_arg(valist, double));  break;
        case 5:  result = atan(va_arg(valist, double));  break;
        case 6:  result = round(va_arg(valist, double)); break;
        case 7:  result = ceil(va_arg(valist, double));  break;
        case 8:  result = floor(va_arg(valist, double)); break;
        case 9:  result = exp(va_arg(valist, double));   break;
        case 10: result = log(va_arg(valist, double));   break;
        case 11: result = log10(va_arg(valist, double)); break;
        case 12: result = sqrt(va_arg(valist, double));  break;

        /* Functions with 2 arguments */
        case 20: temp_arr[0] = va_arg(valist, double); 
                 result = fmod(temp_arr[0], va_arg(valist, double)); break;
        
        /* Functions with 3 arguments */

    }

    va_end(valist);    // clean memory reserved for valist
    return result;
}

nodeType* create_array(nodeType* rowNode, nodeType* colNode,  double value) {
    nodeType* p = malloc(sizeof(nodeType));
    
    if (rowNode->type == typeConstant && colNode->type == typeConstant) {
        p->type = typeMatrix;
        p->mat.row = rowNode->cons;
        p->mat.col = colNode->cons;
        p->mat.matrix = malloc(sizeof(nodeType) * p->mat.row );

        for (int i = 0; i < p->mat.row ; i++) {
            p->mat.matrix[i] = malloc(sizeof(double) * p->mat.col);
            for (int j = 0; j < p->mat.col; j++) {
                p->mat.matrix[i][j] = value;
            }
        }
        return p;
    } 
    else{
        error_flag = 1;
        printf("Invalid input. Rows and columns should be an constant value.\n");
        return NULL;
    }
}

// Reshape matrix or vector  -- temp_Identifier = 30
nodeType* reshape_array(nodeType* a, nodeType* new_row, nodeType* new_col){
    nodeType* p = malloc(sizeof(nodeType));
    int new_row_value = new_row->cons;
    int new_col_value = new_col->cons;

    if (new_row->type == typeConstant && new_col->type == typeConstant){

        if (a->type == typeVector){
            p->type = typeMatrix;
            int length = a->vec.length;
            int total_elements = new_row_value * new_col_value;

            if (length == total_elements){
                p->mat.row = new_row_value;
                p->mat.col = new_col_value;
                p->mat.matrix = malloc(sizeof(double*) * new_row_value);

                int k = 0;
                for (int i = 0; i < new_row_value; i++) {
                    p->mat.matrix[i] = malloc(sizeof(double) * new_col_value);
                    for (int j = 0; j < new_col_value; j++) {
                        p->mat.matrix[i][j] = a->vec.vector[k++];
                    }
                }

                return p;
            } else{
                error_flag = 1;
                printf("Invalid reshape dimensions. The total number of elements must remain the same. Given %d, reshape ele: %d\n", length, total_elements);
            } 
        } else if (a->type == typeMatrix){
            p->type = typeMatrix;
            int row = a->mat.row;
            int col = a->mat.col;
            int total_elements = row * col;

            if (total_elements == new_row_value * new_col_value){
                p->mat.row = new_row_value;
                p->mat.col = new_col_value;
                p->mat.matrix = malloc(sizeof(double*) * new_row_value);

                for (int i = 0; i < new_row_value; i++) {
                    p->mat.matrix[i] = malloc(sizeof(double) * new_col_value);
                    for (int j = 0; j < new_col_value; j++) {
                        int old_i = (i * new_col_value + j) / col;
                        int old_j = (i * new_col_value + j) % col;
                        p->mat.matrix[i][j] = a->mat.matrix[old_i][old_j];
                    }
                }

            return p;
            } else{
                error_flag = 1;
                printf("Invalid reshape dimensions. The total number of elements must remain the same. Given %d, reshape ele: %d\n", total_elements, new_row_value * new_col_value);
            }
        } else {
            error_flag = 1;
            printf("Unsupported type for reshape operation.\n");
        }
    } else{
        error_flag = 1;
        printf("Invalid input. Row and Colummns should be integer.\n");
    }
}

// Concatenate matrix horizontally -- temp_Identifier = 21
nodeType* horzat_array(nodeType* matrix1, nodeType* matrix2) {
    if (matrix1->type != typeMatrix || matrix2->type != typeMatrix) {
        error_flag = 1;
        printf("Invalid input types. Only matrices can be concatenated.\n");
    }

    int row1 = matrix1->mat.row;
    int col1 = matrix1->mat.col;
    int row2 = matrix2->mat.row;
    int col2 = matrix2->mat.col;

    // Concatenate horizontally
    if (row1 == row2) {
        nodeType* p = malloc(sizeof(nodeType));
        p->type = typeMatrix;
        p->mat.row = row1;
        p->mat.col = col1 + col2;
        p->mat.matrix = malloc(sizeof(double*) * row1);

        for (int i = 0; i < row1; i++) {
            p->mat.matrix[i] = malloc(sizeof(double) * (col1 + col2));

            for (int j = 0; j < col1; j++) {
                p->mat.matrix[i][j] = matrix1->mat.matrix[i][j];
            }

            for (int j = 0; j < col2; j++) {
                p->mat.matrix[i][col1 + j] = matrix2->mat.matrix[i][j];
            }
        }
        return p;

    } else{
        error_flag = 1;
        printf("Invalid matrices for horizontal concatenation. The number of rows must match a:%d, b:%d.\n",row1,row2);
    }
}

// Concatenate matrix vertically   -- temp_Identifier = 22
nodeType* verzat_array(nodeType* matrix1, nodeType* matrix2) {

    if (matrix1->type != typeMatrix || matrix2->type != typeMatrix) {
        error_flag = 1;
        printf("Invalid input types. Only matrices can be concatenated.\n");
    }

    int row1 = matrix1->mat.row;
    int col1 = matrix1->mat.col;
    int row2 = matrix2->mat.row;
    int col2 = matrix2->mat.col;

    // Concatenate vertically
    if (col1 == col2) {
        nodeType* p = malloc(sizeof(nodeType));
        p->type = typeMatrix;
        p->mat.row = row1 + row2;
        p->mat.col = col1;
        p->mat.matrix = malloc(sizeof(double*) * (row1 + row2));

        for (int i = 0; i < row1; i++) {
            p->mat.matrix[i] = malloc(sizeof(double) * col1);

            for (int j = 0; j < col1; j++) {
                p->mat.matrix[i][j] = matrix1->mat.matrix[i][j];
            }
        }

        for (int i = 0; i < row2; i++) {
            p->mat.matrix[row1 + i] = malloc(sizeof(double) * col1);

            for (int j = 0; j < col1; j++) {
                p->mat.matrix[row1 + i][j] = matrix2->mat.matrix[i][j];
            }
        }

        return p;
    } else{
        error_flag = 1;
        printf("Invalid matrices for vertical concatenation. The number of columns must match a:%d, b:%d.\n",col1,col2);
    }
}

nodeType* linspace(double start, double stop, double num){
    nodeType* p = malloc(sizeof(nodeType));
    p->type = typeVector;
    p->vec.length = num;
    p->vec.vector = malloc(sizeof(double) * num);

    for (int i=0; i< num; i++)
        p->vec.vector[i] = start + (stop-start)/(num-1) * i;

    return p;
}

nodeType* logspace(double start, double stop, double num){
    nodeType* p = malloc(sizeof(nodeType));
    p = linspace(start, stop, num);

    for (int i=0; i< num; i++){
        p->vec.vector[i] = pow(10, p->vec.vector[i]);
    }
    return p;
}

nodeType* transpose_array(nodeType* input){
    nodeType* p = malloc(sizeof(nodeType));
    p->type = typeMatrix;
    
    if (input->type == typeMatrix)  {
        p->mat.row = input->mat.col;
        p->mat.col = input->mat.row;
        p->mat.matrix = malloc(p->mat.row * sizeof(nodeType));
        
        for (int i = 0; i < p->mat.row; i++) {
            p->mat.matrix[i] = malloc(p->mat.col * sizeof(nodeType));
            for(int j=0; j < p->mat.col;j++) {
                p->mat.matrix[i][j] = input->mat.matrix[j][i];
            }
        }
    }
    else if (input->type == typeVector) {
        p->mat.row=input->vec.length;
        p->mat.col=1;
        p->mat.matrix = malloc(p->mat.row * sizeof(nodeType));
        for (int i = 0; i < p->mat.row; i++) {
            p->mat.matrix[i] = malloc(p->mat.col * sizeof(nodeType));
            for(int j=0; j < p->mat.col;j++) {
                p->mat.matrix[i][j] = input->vec.vector[i];
            }
        }
    }
    else {
        error_flag = 1;
        printf("Invalid variable type for transpose function.\n");
    }
    
    return p;
}

void show_datetime() {
    time_t t = time(NULL);
    struct tm tm = *localtime(&t);
    printf("Current datetime: %d-%02d-%02d %02d:%02d:%02d\n", tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday, tm.tm_hour, tm.tm_min, tm.tm_sec);
}

void show_calender(){
    time_t t = time(NULL);
    struct tm tm = *localtime(&t);
    int day_in_month[] = {0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}; 
    char *month[]=
    {
	    " ",
	    "JANUARY",
	    "FEBRUARY",
	    "MARCH",
	    "APRIL",
	    "MAY",
	    "JUNE",
	    "JULY",
	    "AUGUST",
	    "SEPTEMBER",
	    "OCTOBER",
	    "NOVEMBER",
	    "DECEMBER"
    };

    int year = 1900 +tm.tm_year;
    int d1, d2 ,d3;
    int day_num;

    d1 = (year -1)/4;
    d2 = (year -1)/100;
    d3 = (year -1)/400;

    day_num = (year + 1 - d2 + d3) %7;

    if(year%4 == 0 && year%100 != 0 || year%400 == 0)
        day_in_month[2] = 29;
    else
        day_in_month[2] = 28;
    printf("\nYear = %d", year);

    int mon = tm.tm_mon + 1, day;
    printf("\n                 %s", month[mon]);
    printf("\nSun   Mon   Tue   Wed   Thu   Fri   Sat\n");
    
    
    int count = 1;
    for(day = 1; day <= day_in_month[mon]; day++ ){
        if((day+day_num)%7 > 0)
            count ++;
        else
            break;
        day_num = (day_num + day_in_month[mon]) % 7;
    }
    for (int i=0; i<7-count; i++)
        printf("      ");

    day_num = (year + 1 - d2 + d3) %7;
    for(day = 1; day <= day_in_month[mon]; day++ )
    {
        printf("%2d", day);

        if((day+day_num)%7 > 0) 
            printf("    ");
        else                      
            printf("\n");
        day_num = (day_num + day_in_month[mon]) % 7;
    }
    printf("\n");
}