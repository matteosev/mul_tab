mul_tab: mul_tab.asm
	nasm mul_tab.asm -f elf64 -g -F dwarf -o mul_tab.o
	ld mul_tab.o -o mul_tab
	rm mul_tab.o
  echo Finished, type "./mul_tab [i]" with i an integer between 1 and 9 to execute.
