echo "Building file $1.tap"

z80asm "$1.s" -o "$1.bin"
bin2tap "$1.bin" -o "$1.tap" -b
