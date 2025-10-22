#!/usr/bin/env bash

# uninstall.sh - Uninstallation script for fm code formatter
# Copyright (C) 2025 Mehmet Yilmaz
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

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
