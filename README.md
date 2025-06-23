<p align="center">
    <img width="250" src="./logo.png">
</p>

## Overview

**fm** is a CLI tool currently in early development, designed to format scripts across various projects. This tool offers more control over formatting compared to relying on an IDE. While it's still in development, it's fully usable! If you're interested in contributing, feel free to fork the repo and submit a PR.

## Requirements

- `shfmt`
- `black`
- `prettier`
- `clang-format`

The `setup.sh` script will attempt to install these for you using `brew`, `pip`, and `npm`.

### macOS Users

On macOS, this script requires GNU `getopt`. The setup script will install it for you using Homebrew. You will then need to add it to your `PATH`. The `fm` script will guide you if your `PATH` is not correctly configured.

To do this, first install `getopt` with Homebrew with this command:

```bash
brew install gnu-getopt
```

Then, add the following line to your `~/.zshrc` or `~/.bash_profile`:

```bash
export PATH="$(brew --prefix gnu-getopt)/bin:$PATH"
```

Finally, make sure to source your `~/.zshrc` or `~/.bash_profile`, which ever one you edited.

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
.html
.css
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
```

## Installation

1. Clone the repository and go into it:

   ```bash
   git clone https://github.com/MehmetMHY/fm.git
   cd fm
   ```

2. Run the main setup script to install and/or update **fm**:

   ```bash
   # run this command
   bash setup.sh -i

   # (optional) if the command above fails, run this command:
   sudo bash setup.sh -i
   ```

3. (optional) Uninstall **fm**, if you desire, by running the main script with the following parameter:

   ```bash
   # run this command
   bash setup.sh -r

   # (optional) if the command above fails, run this command:
   sudo bash setup.sh -r
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

Available languages: `bash`, `python`, `javascript`, `clang`.

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

## Additional Information

### Formatters (Deep Dive)

#### [shfmt](https://github.com/mvdan/sh)

The shfmt formatter is used to format shell scripts. In fm, it's used to format **.sh**, **.bash**, **.dash**, and **.ksh** files. To install shfmt, check out their [GitHub Repo](https://github.com/mvdan/sh) or install it using [HomeBrew](https://brew.sh/):

```bash
brew install shfmt
```

#### [black](https://github.com/psf/black)

The black formatter is used to format python scripts. In fm, it's only used to format **.py** files. To install it, you need [Python & Pip](https://www.python.org/) then you can install it using pip:

```bash
pip install black
```

#### [Prettier](https://www.npmjs.com/package/prettier)

The Prettier formatter is used to format "JavaScript Based Projects". In fm, it's used to format **js**, **jsx**, **ts**, **tsx**, **json**, **md**, **html**, **css**, **yml**, **yaml**, **graphql**, **vue**, **scss**, and **less** files. To install it, you need [NodeJS](https://nodejs.org/en) then you can install it using npm:

```bash
npm i -g prettier
```

#### [ClangFormat](https://clang.llvm.org/docs/ClangFormat.html)

The ClangFormat formatter is used to format C, C++, Obj-C, Java, JavaScript, and TypeScript scripts. In fm, it's used to format **c**, **cpp**, **h**, **hpp**, **m**, **mm**, and **java** files. To install it, you can check out their [docs](https://clang.llvm.org/docs/ClangFormat.html) or install it using [HomeBrew](https://brew.sh/):

```bash
brew install clang-format
```

## Testing and Benchmarking

For testing, debugging, or benchmarking `fm`, a helper script is provided at `assets/clone.sh`. This script clones a number of popular, open-source repositories into a `tests/` directory at the project root. These repositories contain a wide variety of languages and file structures, making them an ideal test bed. The cloned repositories are not tracked by Git.

To download the test repositories, you must first `cd` into the `assets` directory before running the script:

```bash
cd assets/
bash clone.sh
```

This will create a `tests/` directory in the project's root, populated with the test repositories. You can then run `fm` on this directory to test its performance and accuracy.
