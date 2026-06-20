.PHONY: all prepare toolchain kernel iso

all: prepare toolchain kernel iso

prepare:
	@echo "Checking environment variables..."
	@test -n "$(LYCHEEOS)" || (echo "LYCHEEOS not set" && exit 1)
	mkdir -pv $(LYCHEEOS) $(SOURCES) $(TOOLS)
	@echo "Directory structure created."

toolchain: prepare
	@echo "Starting Phase 1: Toolchain Build..."
	bash toolchain/build-binutils.sh
	bash toolchain/build-gcc.sh
	bash toolchain/build-musl.sh
	@echo "Phase 1 Complete."

kernel: toolchain
	@echo "Starting Phase 2: Kernel Build..."
	bash kernel/build.sh
	@echo "Phase 2 Complete."

iso: kernel
	@echo "Starting Phase 10: ISO Build..."
	bash iso/build-iso.sh
	@echo "ISO Build Complete."
