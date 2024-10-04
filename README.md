# fm

## Overview

**fm** is a CLI tool currently in early development, designed to format scripts across various projects. This tool offers more control over formatting compared to relying on an IDE. While it's still in development, it's fully usable! If you're interested in contributing, feel free to fork the repo and submit a PR.

## Supported File Formats

```bash
.py
.sh
.zsh
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

## Formatters

### [shfmt](https://github.com/mvdan/sh)

The shfmt formatter is used to format shell scripts. In fm, it's used to format **.zsh** and **.sh** files. To install shfmt, check out their [GitHub Repo](https://github.com/mvdan/sh) or install it using [HomeBrew](https://brew.sh/):

```bash
brew install shfmt
```

### [black](https://github.com/psf/black)

The black formatter is used to format python scripts. In fm, it's only used to format **.py** files. To install it, you need [Python & Pip](https://www.python.org/) then you can install it using pip:

```bash
pip install black
```

### [Prettier](https://www.npmjs.com/package/prettier)

The Prettier formatter is used to format "JavaScript Based Projects". In fm, it's used to format **js**, **jsx**, **ts**, **tsx**, **json**, **md**, **html**, **css**, **yml**, **yaml**, **graphql**, **vue**, **scss**, and **less** files. To install it, you need [NodeJS](https://nodejs.org/en) then you can install it using npm:

```bash
npm i -g prettier
```

### [ClangFormat](https://clang.llvm.org/docs/ClangFormat.html)

The ClangFormat formatter is used to format C, C++, Obj-C, Java, JavaScript, and TypeScript scripts. In fm, it's used to format **c**, **cpp**, **h**, **hpp**, **m**, **mm**, and **java** files. To install it, you can check out their [docs](https://clang.llvm.org/docs/ClangFormat.html) or install it using [HomeBrew](https://brew.sh/):

```bash
brew install clang-format
```

## Setup Instructions

1. Install all the **Formatters** (listed above)
2. Move the `fm` script to your preferred directory, e.g., your home directory:
   ```bash
   mv $HOME/Downloads/fm/fm.sh $HOME/
   ```
3. Add the following alias to your `.bashrc` or `.zshrc`:
   ```bash
   alias fm="bash $HOME/fm.sh"
   ```
4. Restart your terminal to apply the changes, and you're ready to use **fm**!

## Usage Instructions

To format an entire directory:

```bash
fm /path/to/dir
```

To format a single file:

```bash
fm path/to/filename
```

Format current directory by default

```bash
fm
```
