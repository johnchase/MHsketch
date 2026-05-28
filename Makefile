TARGET := jem
BUILD_DIR := build

MPICXX ?= mpicxx
MPIEXEC ?= mpiexec
NP ?= 1
OMP_NUM_THREADS ?= 1

UNAME_S := $(shell uname -s)
HOMEBREW_PREFIX ?= $(shell brew --prefix 2>/dev/null)

ksize ?= 15
KSIZE ?= $(ksize)

SOURCES := src/main.cpp src/JEM.cpp src/input_reading.cpp src/timers.cpp
OBJECTS := $(SOURCES:src/%.cpp=$(BUILD_DIR)/%.o)

ifeq ($(UNAME_S),Darwin)
ifneq ($(wildcard $(HOMEBREW_PREFIX)/opt/libomp),)
OMPFLAGS ?= -Xpreprocessor -fopenmp
EXTRA_CPPFLAGS ?= -I$(HOMEBREW_PREFIX)/opt/libomp/include
EXTRA_LDFLAGS ?= -L$(HOMEBREW_PREFIX)/opt/libomp/lib
EXTRA_LDLIBS ?= -lomp
endif
endif

OMPFLAGS ?= -fopenmp
EXTRA_CPPFLAGS ?=
EXTRA_CXXFLAGS ?=
EXTRA_LDFLAGS ?=
EXTRA_LDLIBS ?=

CXXSTD ?= -std=gnu++14
OPTFLAGS ?= -O3
WARNFLAGS ?= -Wall -Wextra

MH_CPPFLAGS := -Iincludes -DWINDW_SIZE=$(KSIZE) $(EXTRA_CPPFLAGS)
MH_CXXFLAGS := $(OPTFLAGS) $(CXXSTD) $(WARNFLAGS) $(OMPFLAGS) $(EXTRA_CXXFLAGS)
MH_LDFLAGS := $(OMPFLAGS) $(EXTRA_LDFLAGS)
MH_LDLIBS := $(EXTRA_LDLIBS)

DATA_DIR := Test Input
CONST_DIR := $(DATA_DIR)/Constants for LCH
RUN_ARGS ?= -c "$(DATA_DIR)/Minia_Contigs_EColi.fa" \
	-r "$(DATA_DIR)/LongReads_EColi.fa" \
	-a "$(CONST_DIR)/A.txt" \
	-b "$(CONST_DIR)/B.txt" \
	-p "$(CONST_DIR)/Prime.txt" \
	-l 1000 \
	-t 30 \
	-m minimizer \
	-w 10

.PHONY: all clean run-example print-config

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(MPICXX) $(OBJECTS) $(MH_LDFLAGS) $(MH_LDLIBS) -o $@

$(BUILD_DIR)/%.o: src/%.cpp
	@mkdir -p $(dir $@)
	$(MPICXX) $(MH_CPPFLAGS) $(MH_CXXFLAGS) -c $< -o $@

run-example: $(TARGET)
	OMP_NUM_THREADS=$(OMP_NUM_THREADS) $(MPIEXEC) -np $(NP) ./$(TARGET) $(RUN_ARGS)

print-config:
	@echo "MPICXX=$(MPICXX)"
	@echo "MPIEXEC=$(MPIEXEC)"
	@echo "KSIZE=$(KSIZE)"
	@echo "OMP_NUM_THREADS=$(OMP_NUM_THREADS)"
	@echo "NP=$(NP)"
	@echo "RUN_ARGS=$(RUN_ARGS)"

clean:
	$(RM) -r $(BUILD_DIR) $(TARGET) Mp1_all_mn_out_*.log
