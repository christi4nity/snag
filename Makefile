PREFIX ?= /usr/local

build:
	swift build -c release

install: build
	install -d $(PREFIX)/bin
	install .build/release/Snag $(PREFIX)/bin/snag

uninstall:
	rm -f $(PREFIX)/bin/snag

clean:
	swift package clean

.PHONY: build install uninstall clean
