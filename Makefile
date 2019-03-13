.DEFAULT_GOAL = all

EMACS = emacs
ELC   = lift.elc

.SUFFIXES:
.SECONDARY:
.PHONY: all clean

all: $(ELC)

clean:
	rm -f $(ELC)

%.elc: %.el
	$(EMACS) -batch -Q -L . -f batch-byte-compile $<
