CC      := gcc
CPLUS   := g++
CHMOD   := chmod 755
CCFLAGS := 
LDFLAGS :=

TARGETS:= instrumented_coverage uninstrumented_coverage coverage coverage_bitfield coverage_bitmap coverage_bitset coverage_nanoseconds coverage_seconds coverage_strftime
MAINS  := $(TARGETS)
DEPS   := cmark.h cmark_bitfield.h cmark_bitmap.h cmark_bitset.h cmark_nanoseconds.h cmark_seconds.h cmark_strftime.h

.PHONY: all clean

all: $(TARGETS)

clean:
	rm -f $(TARGETS)

coverage_bitset: coverage_bitset.c cmark_bitset.h
	$(CPLUS) -o coverage_bitset $(CCFLAGS) $(LDFLAGS) coverage_bitset.c
	$(CHMOD) coverage_bitset

run_instrumented_coverage: instrumented_coverage
	./instrumented_coverage --test_all

run_uninstrumented_coverage: uninstrumented_coverage
	./uninstrumented_coverage --test_all

run_coverage: coverage
	./coverage --test_all

run_coverage_bitfield: coverage_bitfield
	./coverage_bitfield --test_all

run_coverage_bitmap: coverage_bitmap
	./coverage_bitmap --test_all

run_coverage_bitset: coverage_bitset
	./coverage_bitset --test_all

run_coverage_nanoseconds: coverage_nanoseconds
	./coverage_nanoseconds --test_all

run_coverage_seconds: coverage_seconds
	./coverage_seconds --test_all

run_coverage_strftime: coverage_strftime
	./coverage_strftime --test_all
