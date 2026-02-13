APP_NAME = Snag.app
APP_DIR = $(APP_NAME)/Contents
PREFIX ?= /Applications

build:
	swift build -c release
	mkdir -p $(APP_DIR)/MacOS
	cp .build/release/Snag $(APP_DIR)/MacOS/Snag
	cp Sources/Snag/Info.plist $(APP_DIR)/Info.plist
	mkdir -p $(APP_DIR)/Resources
	cp Sources/Snag/Resources/AppIcon.icns $(APP_DIR)/Resources/AppIcon.icns

install: build
	cp -r $(APP_NAME) $(PREFIX)/$(APP_NAME)

uninstall:
	rm -rf $(PREFIX)/$(APP_NAME)

clean:
	swift package clean
	rm -rf $(APP_NAME)

.PHONY: build install uninstall clean
