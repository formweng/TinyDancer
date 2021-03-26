#ifndef _PROCESS_H_
#define _PROCESS_H_

#include "header.h"
#define PCBListsize 5
#define BatchSize 10

extern uint16 userprgseg;
extern uint16 pro_end;

enum STATE
{
   blocked=0x00, //阻塞,先用作空闲
   ready,  //就绪
   run,    //运行
};

typedef struct PCB//改为PCB
{
    uint16 pc,cs,psw,ss,sp;
    uint16 ax,bx,cx,dx,si,di,bp,es,ds;
    char name[8];
    uint16 PID;
    uint16 state;
}PCB;

PCB PCBList[PCBListsize];
PCB *proc_ptr=&PCBList[0];
uint16 shellmode=1;//0表示在并行执行用户程序，1表示可以轮换到shell时显示信息接受命令
uint16 BatchList[BatchSize];
uint16 toBatch=0;
uint16 BatchOffset=0;//在运行的程序数

void schedule()
{
    uint16 cur_proc=proc_ptr-PCBList;
    uint16 temp=cur_proc;
    if(pro_end)
    {
        PCBList[cur_proc].state=blocked;
        pro_end=0;
    }
    else 
    {
        PCBList[cur_proc].state=ready;
    }

    for(int i=1;i<PCBListsize+1;i++)
    {
        if(PCBList[(cur_proc+i)%PCBListsize].state==ready)
        {
            cur_proc=(cur_proc+i)%PCBListsize;
            break;
        }
    }
    if(cur_proc==temp) 
    {
        shellmode=1;//只有shell在运行
    }
    proc_ptr=&PCBList[cur_proc];
    PCBList[cur_proc].state=run;
}
// 进行这个实验之后，可以把callpro取消掉，要跳到用户程序/地洞用户程序，只需要通过PCB的恢复，也就是说初始化号PCB即可
void PCBinitial(uint16 _cs,uint16 _pc,uint16 index)
{
    asm volatile("cli");
    PCBList[index].ax=0;
    PCBList[index].bx=0;
    PCBList[index].cx=0;
    PCBList[index].dx=0;
    PCBList[index].si=0;
    PCBList[index].di=0;
    PCBList[index].bp=0;
    PCBList[index].sp=0;
    PCBList[index].es=_cs;
    PCBList[index].cs=_cs;
    PCBList[index].ss=_cs;
    PCBList[index].ds=_cs;
    PCBList[index].pc=_pc;
    PCBList[index].psw=512;
    PCBList[index].state=ready;
    asm volatile("sti");
}
int FindEmptyPCB()
{
    for(int i=0;i<PCBListsize+1;i++)
    {
        if(PCBList[i].state==blocked) return i;
    }
    return -1;
}
void StartAProc(uint16 s_pro,uint16 s_num)//用户程序的起始扇区和扇区数
{
    int index=FindEmptyPCB();
    if(index==-1) PrintStr("there is no more empty PCB!\n",RED);
    else
    {
        userprgseg=0x1000*(index+1);
        ReadFloopy(s_pro,s_num);
        PCBinitial(userprgseg,0x100,index);
    }
    
}

#endif