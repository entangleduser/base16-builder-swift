
CURRENT_DATE=$(shell date +"%Y-%m-%d")
BUILD_FOLDER=Build
PREFIX=/usr/local

SWIFT_BUILD_FLAGS=-c release --build-path $(BUILD_FOLDER)

EXECUTABLE=$(shell swift build $(SWIFT_BUILD_FLAGS) --show-bin-path)/builder
BINARIES_FOLDER=$(PREFIX)/bin
INSTALL_PATH=$(BINARIES_FOLDER)/builder

build:
	@echo
	@echo ---- Compiling:
	@echo ======================================
	swift build $(SWIFT_BUILD_FLAGS)
	cp $(EXECUTABLE) .
clean:
	@echo
	@echo ---- Cleaning up:
	@echo ======================================
	rm -Rf $(BUILD_FOLDER)
	rm -f default.profraw
	rm -f builder
init: build
	@echo
	@echo ---- Initializing:
	@echo ======================================
	./builder init
update: build
	@echo
	@echo ---- Updating:
	@echo ======================================
	./builder update
#install: build
#	@echo
#	@echo ---- Installing:
#	@echo ======================================
#	install -d $(BINARIES_FOLDER)
#	install ./builder $(BINARIES_FOLDER)
#
#uninstall:
#	@echo
#	@echo ---- Uninstalling:
#	@echo ======================================
#	rm -f $(INSTALL_PATH)
