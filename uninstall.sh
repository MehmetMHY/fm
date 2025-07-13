#!/usr/bin/env bash

INSTALL_DIR="/usr/local/bin"

if [[ -f "$INSTALL_DIR/fm" ]]; then
	rm "$INSTALL_DIR/fm"
	echo "Uninstallation completed successfully!"
else
	echo "fm is not installed in $INSTALL_DIR"
fi
