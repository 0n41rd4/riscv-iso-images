RISCV64_TEST_IMG=plucky-live-server-riscv64.img
GRUB_DIR=grub-efi-riscv64-unsigned
U_BOOT_SIFIVE=u-boot-sifive

# Default target
all:
	sudo GRUB_DIR=$(GRUB_DIR) RISCV64_TEST_IMG=$(RISCV64_TEST_IMG) U_BOOT_SIFIVE=$(U_BOOT_SIFIVE) ./script_plucky.sh

# Prepare target
prepare: $(GRUB_DIR) $(RISCV64_TEST_IMG) $(U_BOOT_SIFIVE)

# Extract grub-efi-riscv64-unsigned.deb
$(GRUB_DIR): grub-efi-riscv64-unsigned.deb
	mkdir -p grub-efi-riscv64-unsigned
	dpkg-deb -x grub-efi-riscv64-unsigned.deb grub-efi-riscv64-unsigned

# Download grub-efi-riscv64-unsigned.deb
grub-efi-riscv64-unsigned.deb:
	wget -O $@ "http://launchpadlibrarian.net/758737234/grub-efi-riscv64-unsigned_2.12-5ubuntu7_riscv64.deb"

# Extract plucky-live-server-riscv64.img
$(RISCV64_TEST_IMG): plucky-live-server-riscv64.img.gz
	gzip -dk $<

# Download plucky-live-server-riscv64.img.gz
plucky-live-server-riscv64.img.gz:
	wget -O $@ "https://cdimage.ubuntu.com/ubuntu-server/daily-live/current/plucky-live-server-riscv64.img.gz"

# Extract u-boot-sifive.deb
$(U_BOOT_SIFIVE): u-boot-sifive.deb
	mkdir -p u-boot-sifive
	dpkg-deb -x u-boot-sifive.deb u-boot-sifive

# Download u-boot-sifive.deb
u-boot-sifive.deb:
	wget -O $@ "http://launchpadlibrarian.net/772357645/u-boot-sifive_2024.01+dfsg-5ubuntu3_riscv64.deb"

# Clean disk images
cleaniso:
	rm -f plucky_riscv.iso

# Clean all
clean:
	rm -f plucky_riscv.iso
	rm -rf grub-efi-riscv64-unsigned grub-efi-riscv64-unsigned.deb
	rm -rf u-boot-sifive u-boot-sifive.deb
	rm -f plucky-live-server-riscv64.img plucky-live-server-riscv64.img.gz

.PHONY: all clean cleaniso prepare
