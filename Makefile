DESTDIR ?=
UBINDIR ?= /usr/bin
.PHONY: build install
build:
	lazbuild --build-mode=Release pageant.lpi

install: build
	install -d $(DESTDIR)/$(UBINDIR)
	install -m 0755 pageant $(DESTDIR)/$(UBINDIR)/
