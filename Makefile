all: evolution
	valgrind ./evolution Hello,\ World! 20

evolution: evolution.o population.o candidate.o util.o
	ld evolution.o population.o candidate.o util.o -o evolution

evolution.o: evolution.asm
	nasm -f elf64 evolution.asm -o evolution.o

population.o: population.asm
	nasm -f elf64 population.asm -o population.o

candidate.o: candidate.asm
	nasm -f elf64 candidate.asm -o candidate.o

util.o: util.asm
	nasm -f elf64 util.asm -o util.o

clean:
	rm -rf evolution evolution.o population.o candidate.o util.o
