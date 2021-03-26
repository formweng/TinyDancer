#include "user_io.h"

int main()
{
    char str[20],ch;
    getchar(&ch);
    newline();
    getstr(str,20-1);
    newline();
    putch(ch);
    newline();
    puts(str);
    newline();
    upper2lower(str);
    puts(str);
    newline();
    return 0;
}