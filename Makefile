DESTDIR ?=
USRDIR ?= usr
UBINDIR ?= ${USRDIR}/bin
LAZBUILD_OPTS ?= --lazarusdir=/usr/share/lazarus/ --build-mode=Release

.PHONY: build install deps

deps:
	lazbuild $(LAZBUILD_OPTS) --add-package $(shell pwd)/components/VirtualTreeViewV5/Source/virtualtreeview_package.lpk

build: deps
	lazbuild $(LAZBUILD_OPTS) pageant.lpi

install:
	install -d $(DESTDIR)/$(UBINDIR)
	install -d $(DESTDIR)/$(USRDIR)/share/icons/hicolor/scalable/apps/
	install -d $(DESTDIR)/$(USRDIR)/share/applications/
	install desktop/pageant.png $(DESTDIR)/$(USRDIR)/share/icons/hicolor/scalable/apps/
	install desktop/pageant.desktop $(DESTDIR)/$(USRDIR)/share/applications/
	install -m 0755 pageant $(DESTDIR)/$(UBINDIR)/
