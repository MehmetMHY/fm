# fm

## Overview

**fm** is a CLI tool currently in early development, designed to format scripts across various projects. This tool offers more control over formatting compared to relying on an IDE. While it's still in development, it's fully usable! If you're interested in contributing, feel free to fork the repo and submit a PR.

## Supported File Formats

```bash
js
json
md
jsx
html
css
py
sh
```

## Setup Instructions

1. Install [Node.js](https://nodejs.org/en)
2. Install [Python/Pip](https://www.python.org/)
3. Install [shfmt](https://github.com/mvdan/sh) for Bash formatting
4. Install [black](https://github.com/psf/black) for Python formatting
5. Install [Prettier](https://www.npmjs.com/package/prettier) for web-based formats (js, json, etc.)
6. Move the `fm` script to your preferred directory, e.g., your home directory:
   ```bash
   mv $HOME/Downloads/fm/fm.sh $HOME/
   ```
7. Add the following alias to your `.bashrc` or `.zshrc`:
   ```bash
   alias fm="bash $HOME/fm.sh"
   ```
8. Restart your terminal to apply the changes, and you're ready to use **fm**!

## Usage Instructions

To format an entire directory:

```bash
fm .
```

To format a single file:

```bash
fm path/to/filename
```
