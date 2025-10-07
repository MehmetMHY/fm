#!/usr/bin/env bash
# wizard.sh - Interactive installation wizard for fm code formatter
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

ask_to_install() {
	read -p "Do you want to install $1 ($2)? [y/N] " choice
	case "$choice" in
	y | Y) return 0 ;;
	*)
		echo "Skipping installation of $1"
		return 1
		;;
	esac
}

if [[ -n "$PREFIX" ]] && command -v pkg &>/dev/null; then
	# NOTE: Termux uses $PREFIX/bin/
	INSTALL_DIR="$PREFIX/bin"
else
	INSTALL_DIR="/usr/local/bin"
fi

if [[ -n "$PREFIX" ]] && command -v pkg &>/dev/null; then
	echo "Detected Termux pkg..."
	echo "Updating package list..."
	pkg update
	if ask_to_install "shfmt" "shell scripts"; then
		echo "Installing shfmt via pkg..."
		pkg install -y shfmt
	fi
	if ask_to_install "clang-format" "c, c++, java, etc"; then
		echo "Installing clang-format via pkg..."
		pkg install -y clang
	fi
	if ask_to_install "npm" "js ecosystem"; then
		echo "Installing Node.js and npm via pkg..."
		pkg install -y nodejs
	fi
	if ask_to_install "pip" "py ecosystem"; then
		echo "Installing python via pkg..."
		pkg install -y python
	fi
elif command -v brew &>/dev/null; then
	echo "Detected Homebrew (brew)..."
	if [[ "$(uname)" == "Darwin" ]]; then
		if ask_to_install "gnu-getopt" "core functions"; then
			echo "Installing gnu-getopt via Homebrew..."
			brew install gnu-getopt
		fi
	fi
	if ask_to_install "shfmt" "shell scripts"; then
		echo "Installing shfmt via Homebrew..."
		brew install shfmt
	fi
	if ask_to_install "clang-format" "c, c++, java, etc"; then
		echo "Installing clang-format via Homebrew..."
		brew install clang-format
	fi
	if ask_to_install "npm" "js ecosystem"; then
		echo "Installing Node.js via Homebrew..."
		brew install node
	fi
	if ask_to_install "pip" "py ecosystem"; then
		echo "Installing python via Homebrew..."
		brew install python
	fi
elif command -v apt &>/dev/null; then
	echo "Detected APT..."
	echo "Updating package list..."
	sudo apt update
	if ask_to_install "shfmt" "shell scripts"; then
		echo "Installing shfmt via APT..."
		sudo apt install -y shfmt
	fi
	if ask_to_install "clang-format" "c, c++, java, etc"; then
		echo "Installing clang-format via APT..."
		sudo apt install -y clang-format
	fi
	if ask_to_install "npm" "js ecosystem"; then
		echo "Installing Node.js and npm via APT..."
		sudo apt install -y nodejs npm
	fi
	if ask_to_install "pip" "py ecosystem"; then
		echo "Installing python3-pip via APT..."
		sudo apt install -y python3-pip
	fi
elif command -v pacman &>/dev/null; then
	echo "Detected Pacman..."
	echo "Synchronizing package databases..."
	sudo pacman -Sy --noconfirm
	if ask_to_install "shfmt" "shell scripts"; then
		echo "Installing shfmt via Pacman..."
		sudo pacman -S --noconfirm shfmt
	fi
	if ask_to_install "clang-format" "c, c++, java, etc"; then
		echo "Installing clang-format via Pacman..."
		sudo pacman -S --noconfirm clang-format
	fi
	if ask_to_install "npm" "js ecosystem"; then
		echo "Installing Node.js and npm via Pacman..."
		sudo pacman -S --noconfirm nodejs npm
	fi
	if ask_to_install "black" "python"; then
		echo "Installing black via Pacman..."
		sudo pacman -S --noconfirm python-black
	fi
elif command -v yum &>/dev/null; then
	echo "Detected YUM..."
	echo "Updating package list..."
	sudo yum update -y
	if ask_to_install "clang-format" "c, c++, java, etc"; then
		echo "Installing clang-format via YUM..."
		sudo yum install -y clang-tools-extra
	fi
	if ask_to_install "npm" "js ecosystem"; then
		echo "Installing Node.js and npm via YUM..."
		sudo yum install -y nodejs npm
	fi
	if ask_to_install "pip" "py ecosystem"; then
		echo "Installing python3-pip via YUM..."
		sudo yum install -y python3-pip
	fi
elif command -v dnf &>/dev/null; then
	echo "Detected DNF..."
	echo "Updating package list..."
	sudo dnf update -y
	if ask_to_install "clang-format" "c, c++, java, etc"; then
		echo "Installing clang-format via DNF..."
		sudo dnf install -y clang-tools-extra
	fi
	if ask_to_install "npm" "js ecosystem"; then
		echo "Installing Node.js and npm via DNF..."
		sudo dnf install -y nodejs npm
	fi
	if ask_to_install "pip" "py ecosystem"; then
		echo "Installing python3-pip via DNF..."
		sudo dnf install -y python3-pip
	fi
elif command -v zypper &>/dev/null; then
	echo "Detected Zypper..."
	echo "Refreshing repositories..."
	sudo zypper refresh
	if ask_to_install "clang-format" "c, c++, java, etc"; then
		echo "Installing clang-format via Zypper..."
		sudo zypper install -y clang-tools
	fi
	if ask_to_install "npm" "js ecosystem"; then
		echo "Installing Node.js and npm via Zypper..."
		sudo zypper install -y nodejs-default npm
	fi
	if ask_to_install "pip" "py ecosystem"; then
		echo "Installing python3-pip via Zypper..."
		sudo zypper install -y python3-pip
	fi
elif command -v emerge &>/dev/null; then
	echo "Detected Portage..."
	if ask_to_install "clang-format" "c, c++, java, etc"; then
		echo "Installing clang-format via Portage..."
		sudo emerge --ask=n sys-devel/clang
	fi
	if ask_to_install "npm" "js ecosystem"; then
		echo "Installing Node.js via Portage..."
		sudo emerge --ask=n net-libs/nodejs
	fi
	if ask_to_install "pip" "py ecosystem"; then
		echo "Installing pip via Portage..."
		sudo emerge --ask=n dev-python/pip
	fi
elif command -v xbps-install &>/dev/null; then
	echo "Detected XBPS..."
	echo "Synchronizing repositories..."
	sudo xbps-install -S
	if ask_to_install "clang-format" "c, c++, java, etc"; then
		echo "Installing clang-format via XBPS..."
		sudo xbps-install -y clang-tools-extra
	fi
	if ask_to_install "npm" "js ecosystem"; then
		echo "Installing Node.js and npm via XBPS..."
		sudo xbps-install -y nodejs
	fi
	if ask_to_install "pip" "py ecosystem"; then
		echo "Installing python3-pip via XBPS..."
		sudo xbps-install -y python3-pip
	fi
else
	echo "Warning: No supported package manager (brew, apt, pkg, pacman, yum, dnf, zypper, emerge, xbps-install) detected."
	echo "Please ensure all dependencies are installed manually."
fi

if ask_to_install "rustfmt" "rust"; then
	if command -v rustup &>/dev/null; then
		echo "Found rustup, attempting to install rustfmt component..."
		rustup component add rustfmt
	else
		echo "Warning: rustup not found. To format Rust code, please install Rust and rustup from https://rustup.rs/"
	fi
fi

if ask_to_install "swift-format" "swift"; then
	if [[ "$(uname)" == "Darwin" ]] && command -v brew &>/dev/null; then
		echo "Attempting to install swift-format via Homebrew..."
		brew install swift-format
	else
		echo "Warning: swift-format is not installed. Please install it manually to format Swift code."
	fi
fi

if ask_to_install "black" "python"; then
	echo "Installing black via pip..."
	pip install --break-system-packages black
fi

if ask_to_install "prettier" "web languages"; then
	echo "Installing prettier globally via npm..."
	npm i -g prettier
fi

if [[ ! -d "$INSTALL_DIR" ]]; then
	echo "Directory $INSTALL_DIR does not exist - cannot continue."
	exit 1
fi

cp fm.sh "$INSTALL_DIR/fm"
chmod +x "$INSTALL_DIR/fm"
echo "Installation completed successfully!"
