.DEFAULT_GOAL := all

NVCC = nvcc

TARGETS = naive$(EXEEXT) stride$(EXEEXT) sequential$(EXEEXT) first_add$(EXEEXT) \
	unroll$(EXEEXT) multiple$(EXEEXT)

all: $(TARGETS)

SRC_COMMON = timer.c

DISTFILES += $(SRC_COMMON) $(DEPS_COMMON)

naive$(EXEEXT): naive.cu $(SRC_COMMON) $(DEPS_COMMON)
	$(NVCC) naive.cu $(SRC_COMMON) -o $@

stride$(EXEEXT): stride.cu $(SRC_COMMON) $(DEPS_COMMON)
	$(NVCC) stride.cu $(SRC_COMMON) -o $@

sequential$(EXEEXT): sequential.cu $(SRC_COMMON) $(DEPS_COMMON)
	$(NVCC) sequential.cu $(SRC_COMMON) -o $@

first_add$(EXEEXT): first_add.cu $(SRC_COMMON) $(DEPS_COMMON)
	$(NVCC) first_add.cu $(SRC_COMMON) -o $@

unroll$(EXEEXT): unroll.cu $(SRC_COMMON) $(DEPS_COMMON)
	$(NVCC) unroll.cu $(SRC_COMMON) -o $@

multiple$(EXEEXT): multiple.cu $(SRC_COMMON) $(DEPS_COMMON)
	$(NVCC) multiple.cu $(SRC_COMMON) -o $@
	
transpose$(EXEEXT) : transpose.cu $(SRC_COMMON) $(DEPS_COMMON)
	$(NVCC) transpose.cu $(SRC_COMMON) -o $@

clean:
	rm -f $(TARGETS)

clean-all:
	rm -f $(TARGETS) *.e* *.o*
