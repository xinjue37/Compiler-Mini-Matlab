
typedef struct STNode{
    char   name[10];
    struct STNode* nextSymbol;
}SymbolTable;

typedef enum { 
    typeConstant, typeVector, typeMatrix 
} nodeEnum;

/* 1. vectors */
typedef struct {
    double *vector;                  
    int length;
} vecNodeType;

/* 2. matrix */
typedef struct {
    double **matrix;;                  
    int row;
    int col;
} matNodeType;

typedef struct nodeTypeTag {
    nodeEnum type;              /* specific type of node */

    union {                     // Only can be 1 type for a node
        double cons;
        vecNodeType vec;
        matNodeType mat;
    };
} nodeType;