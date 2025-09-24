#!/usr/bin/env bash

if [[ -n "$PREFIX" ]] && command -v pkg &>/dev/null; then
	INSTALL_DIR="$PREFIX/bin"
else
	INSTALL_DIR="/usr/local/bin"
fi

if [[ -f "$INSTALL_DIR/fm" ]]; then
	rm "$INSTALL_DIR/fm"
	echo "Uninstallation of 'fm' script from $INSTALL_DIR completed successfully!"
	echo "Note: This script does not uninstall dependencies (e.g., shfmt, black, prettier, clang-format, gnu-getopt, rustfmt, swift-format) that may have been installed."
	echo "Please remove them manually using your system's package manager (e.g., brew, apt, pacman, pkg, yum, dnf, zypper, emerge, xbps-install) if they are no longer needed."
else
	echo "fm is not installed in $INSTALL_DIR"
fi
