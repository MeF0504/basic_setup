#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void show_help(void)
{
    printf("usage: divisor_rate number [-v]\n");
    printf("\n");
    printf("calculate the ratio of the divisor.");
    printf("\n");
    printf("positional arguments:\n");
    printf("  number\tnumber to calculate the divisor.\n");
    printf("optional arguments:\n");
    printf("  -v\t\tshow all divisors.\n");
}

int main(int argc, char* argv[])
{
    if (argc < 2) {
        show_help();
        return 0;
    }
    int num = atoi(argv[1]);
    char verbose = 0;
    if (argc >= 3) {
        if (strcmp(argv[2], "-v\0") == 0) {
            verbose = 1;
        }
    }

    int sum = 0;
    if (num <= 0) {
        printf("invalid input.\n");
        return 0;
    }
    /* printf("%d\n", num); */
    for (int n = 1; n < num; n++) {
        if (num%n == 0) {
            if (verbose == 1) {
                printf("%d\n", n);
            }
            sum += 1;
        }
    }
    printf("divisor rate: %.1f%%\n", (double)sum/num*100);
    return 0;
}
