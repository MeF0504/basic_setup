#define VAR 1

#include <stdio.h>

int g_var = 1;

// comment
typedef struct {
    int var;
    char is_one;
} var_struct;

int main()
{
    var_struct test_var; // {{{
    test_var.var = VAR; // }}}
    if (test_var.var == 1) {
        test_var.is_one = 1;
    } else {
        test_var.is_one = 0;
    }
    if (test_var.is_one == 1) {
        printf("Hello, World!!\n");
    } else {
        return 0;
    }
}

