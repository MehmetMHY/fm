#!/usr/bin/env bash

INSTALL_DIR="/usr/local/bin"

usage() {
	echo "Options:"
	echo "  -h : list all options"
	echo "  -i : install fm (as in the original script)"
	echo "  -r : uninstall fm by removing the copied file"
}

install_fm() {
	if ! command -v brew &>/dev/null; then
		echo "Error: Homebrew ('brew') is not installed. Install it from https://brew.sh/"
		exit 1
	fi
	if [[ "$(uname)" == "Darwin" ]]; then
		# Check if gnu-getopt is installed via brew. The fm script will guide the user to add it to their PATH.
		if ! brew --prefix gnu-getopt >/dev/null 2>&1; then
			echo "gnu-getopt not found, installing via Homebrew..."
			brew install gnu-getopt
		fi
	fi
	if ! command -v pip &>/dev/null; then
		echo "Error: pip is not installed. Learn to install it from https://packaging.python.org/en/latest/tutorials/installing-packages/"
		exit 1
	fi
	if ! command -v npm &>/dev/null; then
		echo "Error: npm is not installed. Install it from https://nodejs.org/en/download"
		exit 1
	fi
	if ! command -v shfmt &>/dev/null; then
		echo "shfmt not found, installing via Homebrew..."
		brew install shfmt
	fi
	if ! command -v black &>/dev/null; then
		echo "black not found, installing via pip..."
		pip install black
	fi
	if ! command -v prettier &>/dev/null; then
		echo "prettier not found, installing globally via npm..."
		npm i -g prettier
	fi
	if ! command -v clang-format &>/dev/null; then
		echo "clang-format not found, installing via Homebrew..."
		brew install clang-format
	fi
	if [[ ! -d "$INSTALL_DIR" ]]; then
		echo "Directory $INSTALL_DIR does not exist - cannot continue."
		exit 1
	fi
	cp fm.sh "$INSTALL_DIR/fm"
	chmod +x "$INSTALL_DIR/fm"
	echo "Installation completed successfully!"
}

uninstall_fm() {
	if [[ -f "$INSTALL_DIR/fm" ]]; then
		rm "$INSTALL_DIR/fm"
		echo "Uninstallation completed successfully!"
	else
		echo "fm is not installed in $INSTALL_DIR"
	fi
}

if [ $# -eq 0 ]; then
	usage
	exit 1
fi

while getopts "hir" opt; do
	case $opt in
	h)
		usage
		exit 0
		;;
	i)
		install_fm
		exit 0
		;;
	r)
		uninstall_fm
		exit 0
		;;
	*)
		usage
		exit 1
		;;
	esac
done
