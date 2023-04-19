DESTDIR ?=
UBINDIR ?= /usr/bin
LAZBUILD_OPTS ?= --lazarusdir=/usr/share/lazarus/ --build-mode=Release

.PHONY: build install
build:
	lazbuild $(LAZBUILD_OPTS_OPTS) pageant.lpi

install: build
	install -d $(DESTDIR)/$(UBINDIR)
	install -m 0755 pageant $(DESTDIR)/$(UBINDIR)/
