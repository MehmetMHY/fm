#!/usr/bin/env bash

# Set install directory based on environment
if [[ -n "$PREFIX" ]] && command -v pkg &>/dev/null; then
	INSTALL_DIR="$PREFIX/bin" # Termux uses $PREFIX/bin
else
	INSTALL_DIR="/usr/local/bin"
fi

if [[ -n "$PREFIX" ]] && command -v pkg &>/dev/null; then
	echo "Detected Termux pkg..."
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
elif command -v brew &>/dev/null; then
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
elif command -v yum &>/dev/null; then
	echo "Detected YUM..."
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
elif command -v dnf &>/dev/null; then
	echo "Detected DNF..."
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
elif command -v zypper &>/dev/null; then
	echo "Detected Zypper..."
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
elif command -v emerge &>/dev/null; then
	echo "Detected Portage..."
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
elif command -v xbps-install &>/dev/null; then
	echo "Detected XBPS..."
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
else
	echo "Warning: No supported package manager (brew, apt, pkg, pacman, yum, dnf, zypper, emerge, xbps-install) detected."
	echo "Please ensure all dependencies are installed manually."
fi

if ! command -v black &>/dev/null; then
	echo "black not found, installing via pip..."
	pip install --break-system-packages black
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
