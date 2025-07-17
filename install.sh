#!/usr/bin/env bash

INSTALL_DIR="/usr/local/bin"

if command -v brew &>/dev/null; then
	echo "Detected Homebrew (brew)..."
	if [[ "$(uname)" == "Darwin" ]]; then
		if ! brew --prefix gnu-getopt >/dev/null 2>&1; then
			echo "gnu-getopt not found, installing via Homebrew..."
			brew install gnu-getopt
		fi
	fi
	if ! command -v shfmt &>/dev/null; then
		echo "shfmt not found, installing via Homebrew..."
		brew install shfmt
	fi
	if ! command -v clang-format &>/dev/null; then
		echo "clang-format not found, installing via Homebrew..."
		brew install clang-format
	fi
	if ! command -v npm &>/dev/null; then
		echo "npm not found, installing Node.js via Homebrew..."
		brew install node
	fi
	if ! command -v pip &>/dev/null; then
		echo "pip not found, installing python via Homebrew..."
		brew install python
	fi
elif command -v apt &>/dev/null; then
	echo "Detected APT..."
	if ! command -v shfmt &>/dev/null || ! command -v clang-format &>/dev/null || ! command -v npm &>/dev/null || ! command -v pip &>/dev/null; then
		echo "Updating package list..."
		sudo apt update
	fi
	if ! command -v shfmt &>/dev/null; then
		echo "shfmt not found, installing via APT..."
		sudo apt install -y shfmt
	fi
	if ! command -v clang-format &>/dev/null; then
		echo "clang-format not found, installing via APT..."
		sudo apt install -y clang-format
	fi
	if ! command -v npm &>/dev/null; then
		echo "npm not found, installing Node.js and npm via APT..."
		sudo apt install -y nodejs npm
	fi
	if ! command -v pip &>/dev/null; then
		echo "pip not found, installing python3-pip via APT..."
		sudo apt install -y python3-pip
	fi
elif command -v pacman &>/dev/null; then
	echo "Detected Pacman..."
	if ! command -v shfmt &>/dev/null || ! command -v clang-format &>/dev/null || ! command -v npm &>/dev/null || ! command -v pip &>/dev/null; then
		echo "Synchronizing package databases..."
		sudo pacman -Sy --noconfirm
	fi
	if ! command -v shfmt &>/dev/null; then
		echo "shfmt not found, installing via Pacman..."
		sudo pacman -S --noconfirm shfmt
	fi
	if ! command -v clang-format &>/dev/null; then
		echo "clang-format not found, installing via Pacman..."
		sudo pacman -S --noconfirm clang-format
	fi
	if ! command -v npm &>/dev/null; then
		echo "npm not found, installing Node.js and npm via Pacman..."
		sudo pacman -S --noconfirm nodejs npm
	fi
	if ! command -v pip &>/dev/null; then
		echo "pip not found, installing python-pip via Pacman..."
		sudo pacman -S --noconfirm python-pip
	fi
else
	echo "Warning: No supported package manager (brew, apt, pacman) detected."
	echo "Please ensure shfmt, clang-format, gnu-getopt (on macOS), npm, and pip are installed manually."
fi

if ! command -v black &>/dev/null; then
	echo "black not found, installing via pip..."
	pip install black
fi

if ! command -v prettier &>/dev/null; then
	echo "prettier not found, installing globally via npm..."
	npm i -g prettier
fi

if [[ ! -d "$INSTALL_DIR" ]]; then
	echo "Directory $INSTALL_DIR does not exist - cannot continue."
	exit 1
fi

cp fm.sh "$INSTALL_DIR/fm"
chmod +x "$INSTALL_DIR/fm"
echo "Installation completed successfully!"
