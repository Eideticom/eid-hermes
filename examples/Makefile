SRCS = $(wildcard *.c)
PROGS = $(patsubst %.c,%,$(SRCS))

CFLAGS := -g -Og -Wall -I../src/include
LDFLAGS := -g

.PHONY: all clean

ifneq ($(V), 1)
    Q=@
else
    NQ=:
endif

all: $(PROGS)

%: %.c
	@$(NQ) echo "  CC       $@"
	$(Q)$(CC) $(CFLAGS) -o $@ $<

.PHONY: clean
clean:
	$(Q)rm -f $(PROGS)
