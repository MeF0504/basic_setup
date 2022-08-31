#include <stdio.h>
#include <stdlib.h>

void show_help(void)
{
    printf("usage: drate number\n");
    printf("\n");
    printf("calculate the ratio of the divisor.");
    printf("\n");
    printf("positional arguments:\n");
    printf("  number\tnumber to calculate the divisor.\n");
}

int main(int argc, char* argv[])
{
    if (argc < 2) {
        show_help();
        return 0;
    }
    int num = atoi(argv[1]);
    int sum = 0;
    if (num <= 0) {
        printf("invalid input.\n");
        return 0;
    }
    /* printf("%d\n", num); */
    for (int n = 1; n < num; n++) {
        if (num%n == 0) {
            /* printf("%d\n", n); */
            sum += 1;
        }
    }
    printf("divisor rate: %.1f%%\n", (double)sum/num*100);
    return 0;
}
