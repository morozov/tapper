Tapper.scl: Tapper.trd
	trd2scl Tapper.trd Tapper.scl

# The compressed screen is created by Laser Compact v5.2
# and cannot be generated at the build time
# see https://spectrumcomputing.co.uk/?cat=96&id=21446
Tapper.trd: boot.$$B hob/screenz.$$C data.$$C
# Create a temporary file first in order to make sure the target file
# gets created only after the entire job has succeeded
	$(eval TMPFILE=$(shell tempfile))

	createtrd $(TMPFILE)
	hobeta2trd boot.\$$B $(TMPFILE)
	hobeta2trd hob/screenz.\$$C $(TMPFILE)
	hobeta2trd data.\$$C $(TMPFILE)

# Write the correct length to the first file (offset 13)
# The length is 1 (boot) + 16 (loading screen) + 156 (data) = 173
# Got to use the the octal notation since it's the only format of binary data POSIX printf understands
# https://pubs.opengroup.org/onlinepubs/9699919799/utilities/printf.html#tag_20_94_13
	printf '\255' | dd of=$(TMPFILE) bs=1 seek=13 conv=notrunc status=none

# Remove two other files (fill 2×16 bytes starting offset 16 with zeroes)
	dd if=/dev/zero of=$(TMPFILE) bs=1 seek=16 count=32 conv=notrunc status=none

# Rename the temporary file to target name
	mv $(TMPFILE) Tapper.trd

Tapper.tap.zip:
	wget http://www.worldofspectrum.org/pub/sinclair/games/t/Tapper.tap.zip

TAPPER.TAP: Tapper.tap.zip
	unzip -u Tapper.tap.zip && touch TAPPER.TAP

headless.000: TAPPER.TAP
	tapto0 -f TAPPER.TAP

headless.bin: headless.000
	0tobin headless.000

data.bin: headless.bin
	tail -c +8917 headless.bin > data.bin

data.000: data.bin
	binto0 data.bin 3

data.$$C: data.000
	0tohob data.000

boot.bin: src/boot.asm
	pasmo --bin src/boot.asm boot.bin

boot.bas: src/boot.bas boot.bin
# Replace the __LOADER__ placeholder with the machine codes with bytes represented as {XX}
	sed "s/__LOADER__/$(shell hexdump -ve '1/1 "{%02x}"' boot.bin)/" src/boot.bas > boot.bas

boot.tap: boot.bas
	bas2tap -sboot -a10 boot.bas boot.tap

boot.000: boot.tap
	tapto0 -f boot.tap

boot.$$B: boot.000
	0tohob boot.000

clean:
	rm -f \
		*.000 \
		*.\$$B \
		*.\$$C \
		*.bas \
		*.bin \
		*.tap \
		*.TAP \
		*.trd
