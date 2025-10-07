# FM

## Overview

**fm** is a CLI tool currently in early development, designed to format scripts across various projects. This tool offers more control over formatting compared to relying on an IDE. While it's still in development, it's fully usable! If you're interested in contributing, feel free to fork the repo and submit a PR.

## Requirements

- [shfmt](https://github.com/mvdan/sh)
- [black](https://github.com/psf/black)
- [prettier](https://github.com/prettier/prettier)
- [clang-format](https://clang.llvm.org/docs/ClangFormat.html)
- [gofmt](https://pkg.go.dev/cmd/gofmt) _(included with Go)_
- [rustfmt](https://github.com/rust-lang/rustfmt) _(installed with Rustup)_
- [swift-format](https://github.com/swiftlang/swift-format)

The `install.sh` script will attempt to install these for you using your system's package manager.

## Supported Operating Systems

- macOS (Homebrew)
- Debian/Ubuntu (APT)
- RHEL/CentOS (YUM)
- Fedora (DNF)
- openSUSE (Zypper)
- Arch Linux (Pacman)
- Gentoo (Portage)
- Void Linux (XBPS)
- Android/Termux (pkg)

**Note for macOS:** GNU `getopt` is required and will be installed automatically. Add `export PATH="$(brew --prefix gnu-getopt)/bin:$PATH"` to your shell profile if needed.

## Supported File Formats

```bash
.py
.sh
.bash
.dash
.ksh
.js
.jsx
.ts
.tsx
.json
.md
.yml
.yaml
.graphql
.vue
.scss
.less
.c
.cpp
.h
.hpp
.m
.mm
.java
.go
.rs
.swift
```

## Future Formatters

There is consideration for supporting additional languages based on community demand. The formatters that are being heavily considered right now are the following:

- Ruby: [rubocop](https://github.com/rubocop/rubocop)
- PHP: [PHP-CS-Fixer](https://github.com/PHP-CS-Fixer/PHP-CS-Fixer)
- C#: [Csharpier](https://github.com/belav/csharpier)

Support for formatting **HTML** and **CSS** scripts was heavily considered, but no suitable solution exists that meets the project's standards. So, sadly, support for **HTML** and **CSS** will not happen any time soon or in the near and far future.

## Installation

### Quick Install

```bash
# clone the repository and navigate into it
git clone https://github.com/MehmetMHY/fm.git && cd fm

# run the install script
bash install.sh
```

### Custom Install

This is **optional**, but for a more controlled installation where you're prompted for each dependency:

```bash
bash wizard.sh
```

### Uninstall

This is **optional**, but if you want to remove **fm** from your system:

```bash
bash uninstall.sh
```

## Usage

To see all options, use the help flag:

```bash
fm -h
```

### Basic Usage

To format an entire directory:

```bash
fm /path/to/dir
```

To format a single file:

```bash
fm path/to/filename
```

Format current directory by default:

```bash
fm
```

### Advanced Usage

#### Selecting Languages

You can specify which languages to format using the `-l` or `--languages` flag. Provide a comma-separated list of languages.

Available languages: `bash`, `python`, `javascript`, `clang`, `go`, `rust`, `swift`.

```bash
# format only Python and Bash files in the current directory
fm -l python,bash .
```

#### Ignoring Files and Directories

You can ignore specific files or directories using the `-I` or `--ignore` flag. You can use this flag multiple times. It accepts glob patterns.

```bash
# ignore the node_modules and dist directories
fm -I 'node_modules/*' -I 'dist/*' .

# ignore all .log files
fm --ignore '*.log' .
```

#### Dry Run Mode (Check)

To see which files would be changed without actually modifying them, use the `--check` or `-c` flag. This is useful for CI checks or pre-commit hooks.

```bash
# check for files that need formatting
fm --check .
```

#### Interactive Mode

For more control, you can use interactive mode with `--interactive` or `-i`. The script will prompt you for each file before formatting.

```bash
# run in interactive mode
fm -i .
```

You will be prompted with `[y]es, [N]o, [a]ll, [q]uit`.

#### Parallel Processing

To speed up formatting on large projects, you can run the formatter on multiple files in parallel using the `--workers` or `-w` flag.

```bash
# run with 4 parallel workers
fm --workers 4 .
```

#### Disabling `.gitignore`

To format files that are listed in your `.gitignore` file, use the `--no-gitignore` flag.

```bash
# format all files, including those in .gitignore
fm --no-gitignore .
```

## License

This project is licensed under the [GNU General Public License v3.0](./LICENSE).
