#!/usr/bin/env bash

INSTALL_DIR="/usr/local/bin"

if ! command -v brew &>/dev/null; then
	echo "Error: Homebrew ('brew') is not installed. Install it from https://brew.sh/"
	exit 1
fi

if [[ "$(uname)" == "Darwin" ]]; then
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
