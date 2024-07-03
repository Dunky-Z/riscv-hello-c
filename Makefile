CROSS_COMPILE ?= riscv64-unknown-elf-

AR         = $(CROSS_COMPILE)ar
OBJDUMP := $(CROSS_COMPILE)objdump

CCFLAGS             = -mcmodel=medany -ffunction-sections -fdata-sections -g 
LDFLAGS            = -nostartfiles -nostdlib -nostdinc -static -lgcc \
                     -Wl,--nmagic -Wl,--gc-sections 


# tool macros
CC := $(CROSS_COMPILE)gcc
DBGFLAGS := -g
CCOBJFLAGS := $(CCFLAGS) -c -O0

# path macros
BIN_PATH := bin
OBJ_PATH := obj
SRC_PATH := src
DBG_PATH := debug
LOG_PATH := log

# compile macros
TARGET_NAME := hello
TARGET := $(BIN_PATH)/$(TARGET_NAME)
TARGET_DEBUG := $(DBG_PATH)/$(TARGET_NAME)

# src files & obj files
SRC := $(foreach x, $(SRC_PATH), $(wildcard $(addprefix $(x)/*,.c*)))
OBJ := $(addprefix $(OBJ_PATH)/, $(addsuffix .o, $(notdir $(basename $(SRC)))))
OBJ_DEBUG := $(addprefix $(DBG_PATH)/, $(addsuffix .o, $(notdir $(basename $(SRC)))))

# clean files list
DISTCLEAN_LIST := $(OBJ) \
                  $(OBJ_DEBUG)
CLEAN_LIST := $(TARGET) \
			  $(TARGET_DEBUG) \
			  $(DISTCLEAN_LIST)

QEMU 		  ?= /home/user/develop/qemu/build/qemu-riscv64

# -d: print logs, you can use qemu-riscv64 -d --help for more details
# -D <filename>: write logs to file
QEMU_PARAM    ?= -d in_asm,exec,cpu,strace -D $(LOG_PATH)/$(TARGET_NAME).log

# default rule
default: makedir all

# non-phony targets
$(TARGET): $(OBJ)
	$(CC) $(CCFLAGS) -o $@ $(OBJ)

$(OBJ_PATH)/%.o: $(SRC_PATH)/%.c*
	$(CC) $(CCOBJFLAGS) -o $@ $<

$(DBG_PATH)/%.o: $(SRC_PATH)/%.c*
	$(CC) $(CCOBJFLAGS) $(DBGFLAGS) -o $@ $<

$(TARGET_DEBUG): $(OBJ_DEBUG)
	$(CC) $(CCFLAGS) $(DBGFLAGS) $(OBJ_DEBUG) -o $@

# phony rules
.PHONY: makedir
makedir:
	@mkdir -p $(BIN_PATH) $(OBJ_PATH) $(DBG_PATH) $(SRC_PATH) $(LOG_PATH)

.PHONY: all 
all: $(TARGET)

.PHONY: debug
debug: $(TARGET_DEBUG)

.PHONY: clean
clean:
	@echo CLEAN $(CLEAN_LIST)
	@rm -f $(CLEAN_LIST)

.PHONY: distclean
distclean:
	@echo CLEAN $(CLEAN_LIST)
	@rm -f $(DISTCLEAN_LIST)

.PHONY: all
all: $(TARGET)

.PHONY: dump
dump: $(TARGET)
	$(OBJDUMP) -d $(TARGET) > $(DBG_PATH)/$(TARGET_NAME).dump
	
.PHONY: run

run: all makedir
	$(QEMU) $(QEMU_PARAM) $(TARGET)