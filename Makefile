# Makefile for 20-20-Rule

# Installation prefix
PREFIX ?= /usr/local

# Installation directories
BINDIR = $(PREFIX)/bin
DATADIR = $(PREFIX)/share/20-20-rule
DESKTOPDIR = $(PREFIX)/share/applications
ICONDIR = $(PREFIX)/share/icons/hicolor/128x128/apps

# Files to install
SCRIPT = 20-20-rule.sh
DESKTOP = 20-20-rule.desktop
DATAFILE = ding.mp3
ICON_SVG = 20-20-rule.svg

.PHONY: all install uninstall user-install user-uninstall clean help

all:
	@echo "20-20-Rule installation targets:"
	@echo "  make install         - Install system-wide (requires sudo)"
	@echo "  make uninstall       - Uninstall system-wide (requires sudo)"
	@echo "  make user-install    - Install for current user only"
	@echo "  make user-uninstall  - Uninstall for current user"
	@echo ""
	@echo "Default PREFIX is /usr/local (use PREFIX=/custom/path to override)"

# System-wide installation
install:
	@echo "Installing 20-20-Rule to $(PREFIX)..."
	install -Dm755 $(SCRIPT) $(DESTDIR)$(BINDIR)/20-20-rule
	install -Dm644 $(DATAFILE) $(DESTDIR)$(DATADIR)/$(DATAFILE)
	install -Dm644 $(DESKTOP) $(DESTDIR)$(DESKTOPDIR)/$(DESKTOP)
	install -Dm644 $(ICON_SVG) $(DESTDIR)$(ICONDIR)/20-20-rule.png
	@echo "Installation complete!"
	@echo "Run '20-20-rule' to start the application"
	@echo "Or launch it from your application menu"

# System-wide uninstallation
uninstall:
	@echo "Uninstalling 20-20-Rule from $(PREFIX)..."
	rm -f $(DESTDIR)$(BINDIR)/20-20-rule
	rm -rf $(DESTDIR)$(DATADIR)
	rm -f $(DESTDIR)$(DESKTOPDIR)/$(DESKTOP)
	rm -f $(DESTDIR)$(ICONDIR)/20-20-rule.png
	@echo "Uninstallation complete!"

# User installation
user-install:
	@echo "Installing 20-20-Rule for user..."
	$(MAKE) install PREFIX=$(HOME)/.local
	@echo "User installation complete!"
	@echo "Make sure $(HOME)/.local/bin is in your PATH"
	@echo "Run '20-20-rule' to start the application"

# User uninstallation
user-uninstall:
	@echo "Uninstalling 20-20-Rule for user..."
	$(MAKE) uninstall PREFIX=$(HOME)/.local
	@echo "User uninstallation complete!"

# Clean build artifacts (if any)
clean:
	@echo "Nothing to clean (no build artifacts)"

# Help target
help: all
