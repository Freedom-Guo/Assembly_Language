//extern void FUN1()
#include<stdio.h>
#pragma inline
#define N 5
extern "C" void avg(struct data*);
extern "C" void rank(struct data*);
struct data{
char Name[10];
int Chinese, Math, English, AVE, RANK ;
}data[N];
void menu();
int main()
{
    int op=1;
    int i=0;
    char ch;
loop:
     menu();
     scanf("%d",&op);
     switch(op){
     case 1:
        for(i=0;i<N;i++){
        printf("please input student%d information:\n",i+1);
        printf("please input name:\n");
        scanf("%s",data[i].Name);
        printf("please input Chinese score:\n");
        scanf("%d",&data[i].Chinese);
        printf("please input Math score:\n");
        scanf("%d",&data[i].Math);
        printf("please input English score:\n");
        scanf("%d",&data[i].English);
     }
     break;
     case 2:
         avg(data);
        break;
     case 3:
         rank(data);
        break;
     case 4:
        printf("Name Chinese Math English Average Rank\n");
        for(i=0;i<5;i++)
            printf("%10s%4d%4d%4d%4d%4d\n",data[i].Name,data[i].Chinese,data[i].Math,data[i].English,data[i].AVE,data[i].RANK);
            break;
     case 5:
         break;
     }
     getchar();
     printf("continue?y/n\n");
     ch=getchar();
     if(ch=='y'||ch=='Y')
        goto loop;
     return 0;
}
void menu()
{
    printf("1 Input students information\n");
    printf("2 Calculate the average\n");
    printf("3 Computing rankings\n");
    printf("4 Print school report\n");
    printf("5 EXIT\n");
    printf("Please select(1-5)\n");
    return;
}

