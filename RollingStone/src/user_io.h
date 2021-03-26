void putch(char c)
{
    asm volatile("int 0x21"
                :
                : "a"(0x00), "b"(c)
                :
				);
}
char getchar(char *c)
{
    asm volatile("int 0x21"
                :
                : "a"(0x01), "b"(c)
                :
				);
    if(*c!='\r')putch(*c);
    return *c;
}
void puts(char *str)
{
    while(*str)
    {
        putch(*str);
        str++;
    }
}
void getstr(char *str,int max_len)
{
    int count=0;
    while(count<max_len-1)
    {
        getchar(str+count);
        if(*(str+count)=='\r') break;
        count++;
    }
    *(str+count)=0;
}
void upper2lower(char *str)
{
    asm volatile("int 0x21"
                :
                : "a"(0x02), "b"(str)
                :
				);
}
void newline()
{
    asm volatile("int 0x21"
                :
                : "a"(0x03)
                :
				);
}