./img/boot.img:boot.com main.com a.com b.com c.com d.com test.com
	dd if=boot.com of=./img/boot.img bs=512 count=1 conv=notrunc
	dd if=a.com of=./img/boot.img seek=1 bs=512 count=1 conv=notrunc
	dd if=b.com of=./img/boot.img seek=2 bs=512 count=1 conv=notrunc
	dd if=c.com of=./img/boot.img seek=3 bs=512 count=1 conv=notrunc
	dd if=d.com of=./img/boot.img seek=4 bs=512 count=1 conv=notrunc
	dd if=test.com of=./img/boot.img seek=5 bs=512 count=2 conv=notrunc
	dd if=main.com of=./img/boot.img seek=7 bs=512 count=11 conv=notrunc
test.com:test1.o test2.o
	ld -m elf_i386 -N test2.o test1.o -Ttext 0x100 --oformat binary -o test.com
test1.o:test.c user_io.h
	gcc -fno-pic -c -m16 -march=i386 -masm=intel -ffreestanding -mpreferred-stack-boundary=2 test.c -o test1.o
test2.o:test.asm
	nasm -f elf32 test.asm -o test2.o
os.o:kernal.c myio.h mystring.h process.h
	gcc -fno-pic -c -m16 -march=i386 -masm=intel -ffreestanding -mpreferred-stack-boundary=2 kernal.c -o os.o
main.o:kernal.asm
	nasm -f elf32 kernal.asm -o main.o
main.com:main.o os.o
	ld -m elf_i386 -N main.o os.o -Ttext 0x100 --oformat binary -o main.com
boot.com:boot.asm
	nasm boot.asm -o boot.com
%.com:%.asm
	nasm $< -o $@
clean:
	rm *.com *.o

