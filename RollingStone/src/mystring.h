#ifndef _MYSTRING_H_
#define _MYSTRING_H_
#include "header.h"

#define infin 65535

__attribute__((regparm(2)))
uint16 count(const char* str,char key)//字符串中出现多少个key
{
    uint16 num=0;
    while(*str)
    {
        if(*str==key) num++;
        str++;
    }
    return num;
}

__attribute__((regparm(3)))
uint16 strcmp(const char *str1,const char *str2,uint16 size)
{
    uint16 flag=0;
    uint16 offset=0;
    while(*(str1+offset)&&offset<size)
    {
        if(*(str1+offset)!=*(str2+offset))
        {
            flag=1;
            break;
        }
        offset++;
    }
    return flag;
}

__attribute__((regparm(1)))
uint16 Is_CharStr(const char *str)//判断是否都是合法的用户程序key
{
    uint16 flag=0;
    while(*str)
    {
        if(*str<'a'||*str>'e') 
        {
            flag=1;
            break;
        }
        str++;
    }
    return flag;
}
#endif