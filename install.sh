#!/usr/bin/env bash

# install.sh - Installation script for fm code formatter
# Supports automatic mode (default) and interactive wizard mode (-w/--wizard)
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

# parse command line arguments
WIZARD_MODE=false
while [[ $# -gt 0 ]]; do
	case "$1" in
	-w | --wizard)
		WIZARD_MODE=true
		shift
		;;
	-h | --help)
		echo "Usage: $0 [OPTIONS]"
		echo "Options:"
		echo "  -w, --wizard    Enable interactive mode (prompt for each dependency)"
		echo "  -h, --help      Show this help message"
		exit 0
		;;
	*)
		echo "Unknown option: $1"
		echo "Use -h or --help for usage information"
		exit 1
		;;
	esac
done

# interactive prompt functions
ask_to_install() {
	if [[ "$WIZARD_MODE" == true ]]; then
		read -p "Do you want to install $1 ($2)? [y/N] " choice
		case "$choice" in
		y | Y) return 0 ;;
		*)
			echo "Skipping installation of $1"
			return 1
			;;
		esac
	fi
	return 0
}

ask_to_update() {
	if [[ "$WIZARD_MODE" == true ]]; then
		read -p "Do you want to update $1 ($2)? [y/N] " choice
		case "$choice" in
		y | Y) return 0 ;;
		*)
			echo "Skipping update of $1"
			return 1
			;;
		esac
	fi
	return 0
}

# Pip3 install helper function
safe_pip_install() {
	local package="$1"
	local upgrade_flag=""
	if [[ "$2" == "--upgrade" ]]; then
		upgrade_flag="--upgrade"
	fi

	if ! command -v pip3 &>/dev/null; then
		echo "Error: pip3 not found. Cannot install $package."
		return 1
	fi

	pip3 install $upgrade_flag "$package"
	return $?
}

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
	if command -v pip3 &>/dev/null; then
		echo "Upgrading pip..."
		pip3 install --upgrade pip
	fi
else
	IS_UPDATE=false
fi

if [[ -n "$PREFIX" ]] && command -v pkg &>/dev/null; then
	echo "Detected Termux pkg..."
	if [[ "$WIZARD_MODE" == true ]]; then
		echo "Updating package list..."
		pkg update
	fi
	if [[ "$IS_UPDATE" == true ]]; then
		if command -v shfmt &>/dev/null; then
			if ask_to_update "shfmt" "shell scripts"; then
				echo "Updating shfmt via pkg..."
				pkg upgrade -y shfmt
			fi
		fi
		if command -v clang-format &>/dev/null; then
			if ask_to_update "clang-format" "c, c++, java, etc"; then
				echo "Updating clang via pkg..."
				pkg upgrade -y clang
			fi
		fi
		if command -v npm &>/dev/null; then
			if ask_to_update "npm" "js ecosystem"; then
				echo "Updating Node.js and npm via pkg..."
				pkg upgrade -y nodejs
			fi
		fi
	else
		if [[ "$WIZARD_MODE" == false ]]; then
			if ! command -v shfmt &>/dev/null || ! command -v clang-format &>/dev/null || ! command -v npm &>/dev/null || ! command -v pip &>/dev/null; then
				echo "Updating package list..."
				pkg update
			fi
		fi
		if [[ "$WIZARD_MODE" == true ]]; then
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
		else
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
	fi
elif command -v brew &>/dev/null; then
	echo "Detected Homebrew (brew)..."
	if [[ "$WIZARD_MODE" == true ]] && [[ "$IS_UPDATE" == false ]]; then
		: # No package list update needed for brew in wizard mode (handled implicitly)
	fi
	if [[ "$IS_UPDATE" == true ]]; then
		if command -v shfmt &>/dev/null; then
			if ask_to_update "shfmt" "shell scripts"; then
				echo "Updating shfmt via Homebrew..."
				brew upgrade shfmt
			fi
		fi
		if command -v clang-format &>/dev/null; then
			if ask_to_update "clang-format" "c, c++, java, etc"; then
				echo "Updating clang-format via Homebrew..."
				brew upgrade clang-format
			fi
		fi
		if command -v swift-format &>/dev/null; then
			if ask_to_update "swift-format" "swift"; then
				echo "Updating swift-format via Homebrew..."
				brew upgrade swift-format
			fi
		fi
		if command -v black &>/dev/null; then
			if ask_to_update "black" "python"; then
				echo "Updating black..."
				safe_pip_install black --upgrade
			fi
		fi
	else
		if [[ "$(uname)" == "Darwin" ]]; then
			if [[ "$WIZARD_MODE" == true ]]; then
				if ask_to_install "gnu-getopt" "core functions"; then
					echo "Installing gnu-getopt via Homebrew..."
					brew install gnu-getopt
				fi
			else
				if ! brew --prefix gnu-getopt >/dev/null 2>&1; then
					echo "gnu-getopt not found, installing via Homebrew..."
					brew install gnu-getopt
				fi
			fi
		fi
		if [[ "$WIZARD_MODE" == true ]]; then
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
		else
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
	fi
elif command -v apt &>/dev/null; then
	echo "Detected APT..."
	if [[ "$WIZARD_MODE" == true ]]; then
		echo "Updating package list..."
		sudo apt update
	fi
	if [[ "$IS_UPDATE" == true ]]; then
		if command -v shfmt &>/dev/null; then
			if ask_to_update "shfmt" "shell scripts"; then
				echo "Updating shfmt via APT..."
				sudo apt install --only-upgrade -y shfmt
			fi
		fi
		if command -v clang-format &>/dev/null; then
			if ask_to_update "clang-format" "c, c++, java, etc"; then
				echo "Updating clang-format via APT..."
				sudo apt install --only-upgrade -y clang-format
			fi
		fi
	else
		if [[ "$WIZARD_MODE" == false ]]; then
			if ! command -v shfmt &>/dev/null || ! command -v clang-format &>/dev/null || ! command -v npm &>/dev/null || ! command -v pip &>/dev/null; then
				echo "Updating package list..."
				sudo apt update
			fi
		fi
		if [[ "$WIZARD_MODE" == true ]]; then
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
		else
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
	fi
elif command -v pacman &>/dev/null; then
	echo "Detected Pacman..."
	if [[ "$WIZARD_MODE" == true ]]; then
		echo "Synchronizing package databases..."
		sudo pacman -Sy --noconfirm
	fi
	if [[ "$IS_UPDATE" == true ]]; then
		if command -v shfmt &>/dev/null; then
			if ask_to_update "shfmt" "shell scripts"; then
				echo "Updating shfmt via Pacman..."
				sudo pacman -S --noconfirm shfmt
			fi
		fi
		if command -v clang-format &>/dev/null; then
			if ask_to_update "clang-format" "c, c++, java, etc"; then
				echo "Updating clang-format via Pacman..."
				sudo pacman -S --noconfirm clang-format
			fi
		fi
		if command -v black &>/dev/null; then
			if ask_to_update "black" "python"; then
				echo "Updating black..."
				safe_pip_install black --upgrade
			fi
		fi
	else
		if [[ "$WIZARD_MODE" == false ]]; then
			if ! command -v shfmt &>/dev/null || ! command -v clang-format &>/dev/null || ! command -v npm &>/dev/null || ! command -v black &>/dev/null; then
				echo "Synchronizing package databases..."
				sudo pacman -Sy --noconfirm
			fi
		fi
		if [[ "$WIZARD_MODE" == true ]]; then
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
		else
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
	fi
elif command -v yum &>/dev/null; then
	echo "Detected YUM..."
	if [[ "$WIZARD_MODE" == true ]]; then
		echo "Updating package list..."
		sudo yum update -y
	fi
	if [[ "$IS_UPDATE" == true ]]; then
		if command -v clang-format &>/dev/null; then
			if ask_to_update "clang-format" "c, c++, java, etc"; then
				echo "Updating clang-format via YUM..."
				sudo yum update -y clang-tools-extra
			fi
		fi
		if command -v black &>/dev/null; then
			if ask_to_update "black" "python"; then
				echo "Updating black..."
				safe_pip_install black --upgrade
			fi
		fi
	else
		if [[ "$WIZARD_MODE" == false ]]; then
			if ! command -v shfmt &>/dev/null || ! command -v clang-format &>/dev/null || ! command -v npm &>/dev/null || ! command -v pip &>/dev/null; then
				echo "Updating package list..."
				sudo yum update -y
			fi
		fi
		if [[ "$WIZARD_MODE" == true ]]; then
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
		else
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
	fi
elif command -v dnf &>/dev/null; then
	echo "Detected DNF..."
	if [[ "$WIZARD_MODE" == true ]]; then
		echo "Updating package list..."
		sudo dnf update -y
	fi
	if [[ "$IS_UPDATE" == true ]]; then
		if command -v clang-format &>/dev/null; then
			if ask_to_update "clang-format" "c, c++, java, etc"; then
				echo "Updating clang-format via DNF..."
				sudo dnf update -y clang-tools-extra
			fi
		fi
		if command -v black &>/dev/null; then
			if ask_to_update "black" "python"; then
				echo "Updating black..."
				safe_pip_install black --upgrade
			fi
		fi
	else
		if [[ "$WIZARD_MODE" == false ]]; then
			if ! command -v shfmt &>/dev/null || ! command -v clang-format &>/dev/null || ! command -v npm &>/dev/null || ! command -v pip &>/dev/null; then
				echo "Updating package list..."
				sudo dnf update -y
			fi
		fi
		if [[ "$WIZARD_MODE" == true ]]; then
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
		else
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
	fi
elif command -v zypper &>/dev/null; then
	echo "Detected Zypper..."
	if [[ "$WIZARD_MODE" == true ]]; then
		echo "Refreshing repositories..."
		sudo zypper refresh
	fi
	if [[ "$IS_UPDATE" == true ]]; then
		if command -v clang-format &>/dev/null; then
			if ask_to_update "clang-format" "c, c++, java, etc"; then
				echo "Updating clang-format via Zypper..."
				sudo zypper update -y clang-tools
			fi
		fi
		if command -v black &>/dev/null; then
			if ask_to_update "black" "python"; then
				echo "Updating black..."
				safe_pip_install black --upgrade
			fi
		fi
	else
		if [[ "$WIZARD_MODE" == false ]]; then
			if ! command -v shfmt &>/dev/null || ! command -v clang-format &>/dev/null || ! command -v npm &>/dev/null || ! command -v pip &>/dev/null; then
				echo "Refreshing repositories..."
				sudo zypper refresh
			fi
		fi
		if [[ "$WIZARD_MODE" == true ]]; then
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
		else
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
	fi
elif command -v emerge &>/dev/null; then
	echo "Detected Portage..."
	if [[ "$IS_UPDATE" == true ]]; then
		if command -v clang-format &>/dev/null; then
			if ask_to_update "clang-format" "c, c++, java, etc"; then
				echo "Updating clang-format via Portage..."
				sudo emerge --ask=n --update sys-devel/clang
			fi
		fi
		if command -v black &>/dev/null; then
			if ask_to_update "black" "python"; then
				echo "Updating black..."
				safe_pip_install black --upgrade
			fi
		fi
	else
		if [[ "$WIZARD_MODE" == true ]]; then
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
	fi
elif command -v xbps-install &>/dev/null; then
	echo "Detected XBPS..."
	if [[ "$WIZARD_MODE" == true ]]; then
		echo "Synchronizing repositories..."
		sudo xbps-install -S
	fi
	if [[ "$IS_UPDATE" == true ]]; then
		if command -v clang-format &>/dev/null; then
			if ask_to_update "clang-format" "c, c++, java, etc"; then
				echo "Updating clang-format via XBPS..."
				sudo xbps-install -yu clang-tools-extra
			fi
		fi
		if command -v black &>/dev/null; then
			if ask_to_update "black" "python"; then
				echo "Updating black..."
				safe_pip_install black --upgrade
			fi
		fi
	else
		if [[ "$WIZARD_MODE" == false ]]; then
			if ! command -v shfmt &>/dev/null || ! command -v clang-format &>/dev/null || ! command -v npm &>/dev/null || ! command -v pip &>/dev/null; then
				echo "Synchronizing repositories..."
				sudo xbps-install -S
			fi
		fi
		if [[ "$WIZARD_MODE" == true ]]; then
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
	fi
else
	echo "Warning: No supported package manager (brew, apt, pkg, pacman, yum, dnf, zypper, emerge, xbps-install) detected."
	echo "Please ensure all dependencies are installed manually."
fi

if [[ "$IS_UPDATE" == false ]]; then
	if [[ "$WIZARD_MODE" == true ]]; then
		if ask_to_install "rustfmt" "rust"; then
			if command -v rustup &>/dev/null; then
				echo "Found rustup, attempting to install rustfmt component..."
				rustup component add rustfmt
			else
				echo "Warning: rustup not found. To format Rust code, please install Rust and rustup from https://rustup.rs/"
			fi
		fi
	else
		if ! command -v rustfmt &>/dev/null; then
			echo "rustfmt not found."
			if command -v rustup &>/dev/null; then
				echo "Found rustup, attempting to install rustfmt component..."
				rustup component add rustfmt
			else
				echo "Warning: rustup not found. To format Rust code, please install Rust and rustup from https://rustup.rs/"
			fi
		fi
	fi

	if [[ "$WIZARD_MODE" == true ]]; then
		if ask_to_install "swift-format" "swift"; then
			if [[ "$(uname)" == "Darwin" ]] && command -v brew &>/dev/null; then
				echo "Attempting to install swift-format via Homebrew..."
				brew install swift-format
			else
				echo "Warning: swift-format is not installed. Please install it manually to format Swift code."
			fi
		fi
	else
		if ! command -v swift-format &>/dev/null; then
			echo "swift-format not found."
			if [[ "$(uname)" == "Darwin" ]] && command -v brew &>/dev/null; then
				echo "Attempting to install swift-format via Homebrew..."
				brew install swift-format
			else
				echo "Warning: swift-format is not installed. Please install it manually to format Swift code."
			fi
		fi
	fi

	if [[ "$WIZARD_MODE" == true ]]; then
		if ask_to_install "black" "python"; then
			echo "Installing black..."
			safe_pip_install black
		fi
	else
		if ! command -v black &>/dev/null; then
			echo "black not found, installing..."
			safe_pip_install black
		fi
	fi

	if [[ "$WIZARD_MODE" == true ]]; then
		if ask_to_install "prettier" "web languages"; then
			echo "Installing prettier globally via npm..."
			npm i -g prettier
		fi
	else
		if ! command -v prettier &>/dev/null; then
			echo "prettier not found, installing globally via npm..."
			npm i -g prettier
		fi
	fi
else
	if command -v rustfmt &>/dev/null; then
		if ask_to_update "rustfmt" "rust"; then
			echo "Updating rustfmt via rustup..."
			rustup update
		fi
	fi

	if command -v prettier &>/dev/null; then
		if ask_to_update "prettier" "web languages"; then
			echo "Updating prettier globally via npm..."
			npm i -g prettier
		fi
	fi

	if command -v black &>/dev/null; then
		if ask_to_update "black" "python"; then
			echo "Updating black..."
			safe_pip_install black --upgrade
		fi
	fi
fi

if [[ ! -d "$INSTALL_DIR" ]]; then
	echo "Directory $INSTALL_DIR does not exist - cannot continue."
	exit 1
fi

cp fm.sh "$INSTALL_DIR/fm"
chmod +x "$INSTALL_DIR/fm"
echo "Installation completed successfully!"
