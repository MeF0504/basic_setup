#define LEN 5

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

typedef struct {
    int res;
    int skip;
} res_contin;

void set_string(char** txt)
{
    FILE* file = fopen("four_strings.txt", "r");
    /* FILE* file; */
    /* errno_t err; */
    /* err = fopen_s(file, "four_strings.txt", "r"); */
    /* if (err != 0) { */
    /*     printf("failed to open four_strings.txt"); */
    /* } */
    char cp_txt[100][LEN];    // 4文字+終端文字
    char* cpcp_txt;
    // Dynamic address
    cpcp_txt = (char*)malloc(sizeof(char)*LEN);

    int len = 0;
    while (fscanf(file, "%s", cp_txt[len]) != EOF) {
        len++;
    }
    fclose(file);
    srand((unsigned int)time(NULL)); // 乱数seed生成
    int idx = rand()%len;
    strcpy(cpcp_txt, cp_txt[idx]);
    *txt = cpcp_txt;
}

int main(int argc, char* argv[])
{
    char* txt;
    char in_txt[LEN];
    char c;
    res_contin res;
    set_string(&txt);
    /* printf("%s\n", txt); */
    while (1){
        res.res = 0;
        printf("%d letters:\n", LEN-1);
        scanf("%4s", in_txt);
        printf("----\n");
        for (int i=0; i < LEN-1; i++) {
            if (in_txt[i] == txt[i]) {
                printf("o");
                res.res++;
            } else {
                res.skip = 0;
                for (int j=0; j < LEN-1; j++) {
                    if (in_txt[i] == txt[j]) {
                        printf("~");
                        res.skip = 1;
                        break;
                    }
                }
                if (res.skip != 1) {
                    printf("x");
                }
            }
        }
        printf("\n");
        if (res.res >= LEN-1) {
            printf("Great!\n");
            break;
        }
    }
    free(txt);
    return 0;
}

