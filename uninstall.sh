#!/usr/bin/env bash

INSTALL_DIR="/usr/local/bin"

if [[ -f "$INSTALL_DIR/fm" ]]; then
	rm "$INSTALL_DIR/fm"
	echo "Uninstallation of 'fm' script from $INSTALL_DIR completed successfully!"
	echo "Note: This script does not uninstall dependencies (e.g., shfmt, black, prettier, clang-format) that may have been installed."
	echo "Please remove them manually using your system's package manager if they are no longer needed."
else
	echo "fm is not installed in $INSTALL_DIR"
fi
