asm(".code16gcc\n");

#include "myio.h"
#include "mystring.h"
#include "process.h"

// extern void CallUserPrg();

const char *PATH_INFO = "rollingstone_v2 > ";
const char *HELP_INFO = "\
Commands:\n\
ls             List the programs\n\
cls            Clear Screen\n\
[keys]         Run the programs serially\n\
run [keys]     Run the programs parallely\n";
const char *LS_INFO = "\
Please enter the key to Run the Program\n\n\
  key      name      pos\n\
   a       a.com      2\n\
   b       b.com      3\n\
   c       c.com      4\n\
   d       d.com      5\n\
   e       test.com   7\n";
// const char *COUNTER_INFO1="Please enter the string : ";
// const char *COUNTER_INFO2="Please enter the key : ";
// const char *COUNTER_INFO3="The num of key in the string is : ";




// void counter()
// {
//     char str[MAX_LEN+1];
//     char key;
//     PrintStr(COUNTER_INFO1,WHITE);
//     getstr(str,MAX_LEN);
//     PrintStr(COUNTER_INFO2,WHITE);
//     key=getchar();
//     PrintChar(key,WHITE);
//     PrintChar('\n',WHITE);
//     uint16 num=count(str,key);
//     PrintStr(COUNTER_INFO3,WHITE);
//     PrintNum(num,GREEN);
//     PrintChar('\n',WHITE);
// }

void shell()
{
    char command_buf[20];
    uint16 cls=0;
    toBatch=0;
    while(1)
    {
        if(shellmode)
        {
            if(cls)
            {
                CLS();
                cls=0;
            }
            if(toBatch>0)
            {
                shellmode=0;
                toBatch--;
                cls=1;
                StartAProc(BatchList[BatchOffset++],1);
                continue;
            }
            PrintStr(PATH_INFO,CYAN);
            getstr(command_buf,19);
            if(strcmp("cls",command_buf,infin)==0)
            {
                CLS();
            }
            else if(strcmp("help",command_buf,infin)==0)
            {
                PrintStr(HELP_INFO,GREEN);
            }
            else if(strcmp("ls",command_buf,infin)==0)
            {
                PrintStr(LS_INFO,WHITE);
            }
            else if(strcmp("run",command_buf,3)==0&&Is_CharStr(command_buf+4)==0)
            {//先初步设计为无参数
                shellmode=0;
                cls=1;
                uint16 offset=4;
                while(command_buf[offset])
                {
                    StartAProc(command_buf[offset++]-'a'+1,1);
                }
                
            }
            else if(Is_CharStr(command_buf)==0)//批处理预处理
            {
                uint16 offset=0;
                while(command_buf[offset]&&offset<BatchSize)
                {
                    BatchList[offset]=command_buf[offset]-'a'+1;
                    offset++;
                }
                BatchOffset=0;
                toBatch=offset;
            }
            else
            {
                PrintStr("Bad command! You can type 'help' to know more\n",RED);
            }
        }
    }
}

int main()
{  
    // PCB ker_PCB;
    // proc_ptr=&ker_PCB;
    // shell();
    // PrintStr(HELP_INFO,BLUE);
    proc_ptr->state=ready;
    for(int i=1;i<PCBListsize;i++) PCBList[i].state=blocked;
    asm volatile("sti");
    shell();
    // userprgseg=0x2000;
    // ReadFloopy(1,1);
    // userprgseg=0x3000;
    // ReadFloopy(2,1);
    // userprgseg=0x4000;
    // ReadFloopy(3,1);
    // userprgseg=0x5000;
    // ReadFloopy(4,1);

    // PCBinitial(0x2000,0x0100,1);
    
    // asm volatile("int 0x08;int 0x08;int 0x08;int 0x08");
    // PCBinitial(0x3000,0x0100,2);
    
    // PCBinitial(0x4000,0x0100,3);
    
    // PCBinitial(0x5000,0x0100,4);
    // PCBList[0].state=blocked;
	return 0;
} 
