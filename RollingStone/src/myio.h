#ifndef _MYIO_H_
#define _MYIO_H_

#include "header.h"

extern void CLS();
extern uint16 getchar();//返回输入的扫描码和ascii码（高，低）
extern uint16 GetCursor();
extern void SetCursor(uint8 r,uint8 c);
extern void ReadFloopy_4par(uint8 c,uint8 h,uint8 s,uint8 num);
extern void ShowChar(uint16 offset,const char c,uint8 color);
extern void ScrollUp(uint8 num_r);

__attribute__((regparm(2)))
void PrintChar(const char c,uint8 color)
{
    uint16 pos=GetCursor();
    uint16 y=pos>>8;
    uint16 x=pos&0x00ff;
    if(c!=ENTER&&c!='\n')
    {
        uint16 offset=(y*80+x)*2;
        ShowChar(offset,c,color);
    }
    x++;
    if(x==MAX_X||c==ENTER||c=='\n')
    {
        x=0;
        y++;
    }
    if(y==MAX_Y)
    {
        ScrollUp(1);
        y--;
    }
    SetCursor(y,x);
    return ;
}

__attribute__((regparm(2)))
void PrintStr(const char *str, uint8 color){
	while(*str){
		PrintChar(*str,color);
		++str;
	}
    return ;
}

__attribute__((regparm(2)))
void PrintNum(uint16 num, uint8 color){
	char temp[16];
	uint16 i = 0;
	do{
		temp[i] = num % 10;
		num /= 10;
		++i;
	}while(num > 0);

	for (short j = i - 1;j > -1;--j){
		PrintChar(temp[j] + '0', color);
	}
    return ;
}

__attribute__((regparm(2)))
void ReadFloopy(uint16 lba,uint8 num)
{
    uint8 c,h,s;
    s=lba%18+1;
    h=(lba-s+1)/18%80;
    c=(lba-s+1-18*h)/(18*80);
    ReadFloopy_4par(c,h,s,num);
    return ;
}

__attribute__((regparm(2)))
void getstr(char *str,uint16 max_len)
{
	uint16 offset=0;
	char c=0;
	while(offset<max_len)
	{
		c=getchar();
		PrintChar(c,WHITE);
		if(c==ENTER) break;
		*(str+offset)=c;
		offset++;
	}
	*(str+offset)=0;
    return ;
}



#endif