#!/usr/bin/env bash

# install.sh - Installation script for fm code formatter
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

# handle Ctrl+C to kill all child processes
trap 'kill $(jobs -p) 2>/dev/null; exit 130' INT

# set install directory based on environment
if [[ -n "$PREFIX" ]] && command -v pkg &>/dev/null; then
	# termux uses $PREFIX/bin
	INSTALL_DIR="$PREFIX/bin"
else
	INSTALL_DIR="/usr/local/bin"
fi

if command -v fm &>/dev/null; then
	IS_UPDATE=true
	echo "fm is already installed, updating installed dependencies..."
else
	IS_UPDATE=false
fi

if [[ -n "$PREFIX" ]] && command -v pkg &>/dev/null; then
	echo "Detected Termux pkg..."
	if [[ "$IS_UPDATE" == true ]]; then
		if command -v shfmt &>/dev/null; then
			echo "Updating shfmt via pkg..."
			pkg upgrade -y shfmt
		fi
		if command -v clang-format &>/dev/null; then
			echo "Updating clang via pkg..."
			pkg upgrade -y clang
		fi
		if command -v npm &>/dev/null; then
			echo "Updating Node.js and npm via pkg..."
			pkg upgrade -y nodejs
		fi
	else
		if ! command -v shfmt &>/dev/null || ! command -v clang-format &>/dev/null || ! command -v npm &>/dev/null || ! command -v pip &>/dev/null; then
			echo "Updating package list..."
			pkg update
		fi
		if ! command -v shfmt &>/dev/null; then
			echo "shfmt not found, installing via pkg..."
			pkg install -y shfmt
		fi
		if ! command -v clang-format &>/dev/null; then
			echo "clang-format not found, installing via pkg..."
			pkg install -y clang
		fi
		if ! command -v npm &>/dev/null; then
			echo "npm not found, installing Node.js and npm via pkg..."
			pkg install -y nodejs
		fi
		if ! command -v pip &>/dev/null; then
			echo "pip not found, installing python via pkg..."
			pkg install -y python
		fi
	fi
elif command -v brew &>/dev/null; then
	echo "Detected Homebrew (brew)..."
	if [[ "$IS_UPDATE" == true ]]; then
		if command -v shfmt &>/dev/null; then
			echo "Updating shfmt via Homebrew..."
			brew upgrade shfmt
		fi
		if command -v clang-format &>/dev/null; then
			echo "Updating clang-format via Homebrew..."
			brew upgrade clang-format
		fi
		if command -v swift-format &>/dev/null; then
			echo "Updating swift-format via Homebrew..."
			brew upgrade swift-format
		fi
		if command -v black &>/dev/null; then
			echo "Updating black via pip..."
			pip install --upgrade --break-system-packages black
		fi
	else
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
	fi
elif command -v apt &>/dev/null; then
	echo "Detected APT..."
	if [[ "$IS_UPDATE" == true ]]; then
		if command -v shfmt &>/dev/null; then
			echo "Updating shfmt via APT..."
			sudo apt install --only-upgrade -y shfmt
		fi
		if command -v clang-format &>/dev/null; then
			echo "Updating clang-format via APT..."
			sudo apt install --only-upgrade -y clang-format
		fi
	else
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
	fi
elif command -v pacman &>/dev/null; then
	echo "Detected Pacman..."
	if [[ "$IS_UPDATE" == true ]]; then
		if command -v shfmt &>/dev/null; then
			echo "Updating shfmt via Pacman..."
			sudo pacman -S --noconfirm shfmt
		fi
		if command -v clang-format &>/dev/null; then
			echo "Updating clang-format via Pacman..."
			sudo pacman -S --noconfirm clang-format
		fi
		if command -v black &>/dev/null; then
			echo "Updating black via pip..."
			pip install --upgrade --break-system-packages black
		fi
	else
		if ! command -v shfmt &>/dev/null || ! command -v clang-format &>/dev/null || ! command -v npm &>/dev/null || ! command -v black &>/dev/null; then
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
		if ! command -v black &>/dev/null; then
			echo "black not found, installing via Pacman..."
			sudo pacman -S --noconfirm python-black
		fi
	fi
elif command -v yum &>/dev/null; then
	echo "Detected YUM..."
	if [[ "$IS_UPDATE" == true ]]; then
		if command -v clang-format &>/dev/null; then
			echo "Updating clang-format via YUM..."
			sudo yum update -y clang-tools-extra
		fi
		if command -v black &>/dev/null; then
			echo "Updating black via pip..."
			pip install --upgrade --break-system-packages black
		fi
	else
		if ! command -v shfmt &>/dev/null || ! command -v clang-format &>/dev/null || ! command -v npm &>/dev/null || ! command -v pip &>/dev/null; then
			echo "Updating package list..."
			sudo yum update -y
		fi
		if ! command -v clang-format &>/dev/null; then
			echo "clang-format not found, installing via YUM..."
			sudo yum install -y clang-tools-extra
		fi
		if ! command -v npm &>/dev/null; then
			echo "npm not found, installing Node.js and npm via YUM..."
			sudo yum install -y nodejs npm
		fi
		if ! command -v pip &>/dev/null; then
			echo "pip not found, installing python3-pip via YUM..."
			sudo yum install -y python3-pip
		fi
	fi
elif command -v dnf &>/dev/null; then
	echo "Detected DNF..."
	if [[ "$IS_UPDATE" == true ]]; then
		if command -v clang-format &>/dev/null; then
			echo "Updating clang-format via DNF..."
			sudo dnf update -y clang-tools-extra
		fi
		if command -v black &>/dev/null; then
			echo "Updating black via pip..."
			pip install --upgrade --break-system-packages black
		fi
	else
		if ! command -v shfmt &>/dev/null || ! command -v clang-format &>/dev/null || ! command -v npm &>/dev/null || ! command -v pip &>/dev/null; then
			echo "Updating package list..."
			sudo dnf update -y
		fi
		if ! command -v clang-format &>/dev/null; then
			echo "clang-format not found, installing via DNF..."
			sudo dnf install -y clang-tools-extra
		fi
		if ! command -v npm &>/dev/null; then
			echo "npm not found, installing Node.js and npm via DNF..."
			sudo dnf install -y nodejs npm
		fi
		if ! command -v pip &>/dev/null; then
			echo "pip not found, installing python3-pip via DNF..."
			sudo dnf install -y python3-pip
		fi
	fi
elif command -v zypper &>/dev/null; then
	echo "Detected Zypper..."
	if [[ "$IS_UPDATE" == true ]]; then
		if command -v clang-format &>/dev/null; then
			echo "Updating clang-format via Zypper..."
			sudo zypper update -y clang-tools
		fi
		if command -v black &>/dev/null; then
			echo "Updating black via pip..."
			pip install --upgrade --break-system-packages black
		fi
	else
		if ! command -v shfmt &>/dev/null || ! command -v clang-format &>/dev/null || ! command -v npm &>/dev/null || ! command -v pip &>/dev/null; then
			echo "Refreshing repositories..."
			sudo zypper refresh
		fi
		if ! command -v clang-format &>/dev/null; then
			echo "clang-format not found, installing via Zypper..."
			sudo zypper install -y clang-tools
		fi
		if ! command -v npm &>/dev/null; then
			echo "npm not found, installing Node.js and npm via Zypper..."
			sudo zypper install -y nodejs-default npm
		fi
		if ! command -v pip &>/dev/null; then
			echo "pip not found, installing python3-pip via Zypper..."
			sudo zypper install -y python3-pip
		fi
	fi
elif command -v emerge &>/dev/null; then
	echo "Detected Portage..."
	if [[ "$IS_UPDATE" == true ]]; then
		if command -v clang-format &>/dev/null; then
			echo "Updating clang-format via Portage..."
			sudo emerge --ask=n --update sys-devel/clang
		fi
		if command -v black &>/dev/null; then
			echo "Updating black via pip..."
			pip install --upgrade --break-system-packages black
		fi
	else
		if ! command -v clang-format &>/dev/null; then
			echo "clang-format not found, installing via Portage..."
			sudo emerge --ask=n sys-devel/clang
		fi
		if ! command -v npm &>/dev/null; then
			echo "npm not found, installing Node.js via Portage..."
			sudo emerge --ask=n net-libs/nodejs
		fi
		if ! command -v pip &>/dev/null; then
			echo "pip not found, installing pip via Portage..."
			sudo emerge --ask=n dev-python/pip
		fi
	fi
elif command -v xbps-install &>/dev/null; then
	echo "Detected XBPS..."
	if [[ "$IS_UPDATE" == true ]]; then
		if command -v clang-format &>/dev/null; then
			echo "Updating clang-format via XBPS..."
			sudo xbps-install -yu clang-tools-extra
		fi
		if command -v black &>/dev/null; then
			echo "Updating black via pip..."
			pip install --upgrade --break-system-packages black
		fi
	else
		if ! command -v shfmt &>/dev/null || ! command -v clang-format &>/dev/null || ! command -v npm &>/dev/null || ! command -v pip &>/dev/null; then
			echo "Synchronizing repositories..."
			sudo xbps-install -S
		fi
		if ! command -v clang-format &>/dev/null; then
			echo "clang-format not found, installing via XBPS..."
			sudo xbps-install -y clang-tools-extra
		fi
		if ! command -v npm &>/dev/null; then
			echo "npm not found, installing Node.js and npm via XBPS..."
			sudo xbps-install -y nodejs
		fi
		if ! command -v pip &>/dev/null; then
			echo "pip not found, installing python3-pip via XBPS..."
			sudo xbps-install -y python3-pip
		fi
	fi
else
	echo "Warning: No supported package manager (brew, apt, pkg, pacman, yum, dnf, zypper, emerge, xbps-install) detected."
	echo "Please ensure all dependencies are installed manually."
fi

if [[ "$IS_UPDATE" == false ]]; then
	if ! command -v rustfmt &>/dev/null; then
		echo "rustfmt not found."
		if command -v rustup &>/dev/null; then
			echo "Found rustup, attempting to install rustfmt component..."
			rustup component add rustfmt
		else
			echo "Warning: rustup not found. To format Rust code, please install Rust and rustup from https://rustup.rs/"
		fi
	fi

	if ! command -v swift-format &>/dev/null; then
		echo "swift-format not found."
		if [[ "$(uname)" == "Darwin" ]] && command -v brew &>/dev/null; then
			echo "Attempting to install swift-format via Homebrew..."
			brew install swift-format
		else
			echo "Warning: swift-format is not installed. Please install it manually to format Swift code."
		fi
	fi

	if ! command -v black &>/dev/null; then
		echo "black not found, installing via pip..."
		pip install --break-system-packages black
	fi

	if ! command -v prettier &>/dev/null; then
		echo "prettier not found, installing globally via npm..."
		npm i -g prettier
	fi
else
	if command -v rustfmt &>/dev/null; then
		echo "Updating rustfmt via rustup..."
		rustup update
	fi

	if command -v prettier &>/dev/null; then
		echo "Updating prettier globally via npm..."
		npm i -g prettier
	fi

	if command -v black &>/dev/null; then
		echo "Updating black via pip..."
		pip install --upgrade --break-system-packages black
	fi
fi

if [[ ! -d "$INSTALL_DIR" ]]; then
	echo "Directory $INSTALL_DIR does not exist - cannot continue."
	exit 1
fi

cp fm.sh "$INSTALL_DIR/fm"
chmod +x "$INSTALL_DIR/fm"
echo "Installation completed successfully!"
