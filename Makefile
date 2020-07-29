# Put the filename of the output binary here
TARGET = dreamroq-player.elf

# List all of your C files here, but change the extension to ".o"
OBJS = dreamroq-player.o dreamroqlib.o
OBJS += libdcmc/timer.o
OBJS += romdisk.o

#AICA Audio Driver
KOS_CFLAGS += -I. -Ilibdcmc/
OBJS += libdcmc/snd_stream.o
OBJS += libdcmc/snddrv.o

all: rm-elf $(TARGET)

include $(KOS_BASE)/Makefile.rules

clean:
	-rm -f $(TARGET) $(OBJS)

rm-elf:
	-rm -f $(TARGET)

romdisk.img:
	$(KOS_GENROMFS) -f $@ -d romdisk -v

romdisk.o: romdisk.img
	$(KOS_BASE)/utils/bin2o/bin2o romdisk.img romdisk romdisk.o


# If you don't need a ROMDISK, then remove "romdisk.o" from the next few
# lines. Also change the -l arguments to include everything you need,
# such as -lmp3, etc.. these will need to go _before_ $(KOS_LIBS)
$(TARGET): $(OBJS)
	$(KOS_CC) $(KOS_CFLAGS) $(KOS_LDFLAGS) -o $(TARGET) $(KOS_START) \
		$(OBJS) $(OBJEXTRA) $(KOS_LIBS)

run: $(TARGET)
	$(KOS_LOADER) $(TARGET)

dist:
	rm -f $(OBJS) romdisk.o romdisk.img
	$(KOS_STRIP) $(TARGET)

cdi: $(TARGET)
	sh-elf-objcopy -R .stack -O binary $(TARGET) output.bin
	$(KOS_BASE)/utils/scramble/scramble output.bin 1ST_READ.BIN
	@mkisofs -C 0,11702 -V DreamROQ_R2 -G IP.BIN -r -J -l -o ../DreamROQ_R2.iso .
	@$(KOS_BASE)/utils/cdi4dc/cdi4dc ../DreamROQ_R2.iso ../DreamROQ_R2.cdi -d > cdi4dc.log
	reicast ../DreamROQ_R2.cdi
