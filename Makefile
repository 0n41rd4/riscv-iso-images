CD_RISCV64=cd-boot-images-riscv64/usr/share/cd-boot-images-riscv64
RISCV64_TEST_IMG=plucky-live-server-riscv64.img

# Default target
all:
	sudo CD_RISCV64=$(CD_RISCV64) RISCV64_TEST_IMG=$(RISCV64_TEST_IMG) ./script.sh

# Prepare target
prepare: $(CD_RISCV64) $(RISCV64_TEST_IMG)

# Extract cd-boot-images-riscv64
$(CD_RISCV64): cd-boot-images-riscv64.deb
	mkdir -p cd-boot-images-riscv64
	dpkg-deb -x cd-boot-images-riscv64.deb cd-boot-images-riscv64

# Download cd-boot-images-riscv64.deb
cd-boot-images-riscv64.deb:
	wget -O $@ "https://launchpad.net/ubuntu/+source/cd-boot-images-riscv64/15/+build/29116560/+files/cd-boot-images-riscv64_15_all.deb"

# Extract plucky-live-server-riscv64.img
$(RISCV64_TEST_IMG): plucky-live-server-riscv64.img.gz
	gzip -dk $<

# Download plucky-live-server-riscv64.img.gz
plucky-live-server-riscv64.img.gz:
	wget -O $@ "https://cdimage.ubuntu.com/ubuntu-server/daily-live/current/plucky-live-server-riscv64.img.gz"

# Clean disk images
cleaniso:
	rm -f hybrid.iso

# Clean all
clean:
	rm -f hybrid.iso
	rm -rf cd-boot-images-riscv64 cd-boot-images-riscv64.deb
	rm -f plucky-live-server-riscv64.img plucky-live-server-riscv64.img.gz

.PHONY: all clean cleaniso prepare
