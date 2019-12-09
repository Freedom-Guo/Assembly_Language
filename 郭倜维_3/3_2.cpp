#include <stdio.h>
int strcmp(char*str1,char*str2);
int main(void)
{
   char str1[10],str2[10];
   int i,j;
   printf ("Please input str1:");
   scanf ("%s",&str1);
   printf ("Please input str2:");
   scanf ("%s",&str2);
   i=strcmp(str1,str2); 
    if(!i)
        printf ("The two strings are equal!");
	else
        printf ("The two strings are not equal!");
    return 0;
}
int strcmp(char*str1,char*str2)
{
	int j=0,flag;
	while (str1[j]==str2[j])
	{
		j++;
        if (str1[j]=='\0'||str2[j]=='\0')
           break;
	}
    if (str1[j]=='\0'&&str2[j]=='\0')
       flag=0;
    else
	    flag=1;
	return flag;
}

