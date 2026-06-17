#!/usr/bin/env bash

# fm - A script to format code in various languages
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

# terminal colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# options
declare -a ignore_patterns=()
declare -a languages_to_format=()
DRY_RUN=false
USE_GITIGNORE=true

# determine the number of CPU cores for default workers
if command -v getconf &>/dev/null && getconf _NPROCESSORS_ONLN &>/dev/null; then
	WORKERS=$(getconf _NPROCESSORS_ONLN)
else
	WORKERS=2
	if [[ "$(uname)" == "Linux" ]]; then
		if command -v nproc &>/dev/null; then
			WORKERS=$(nproc)
		fi
	elif [[ "$(uname)" == "Darwin" ]]; then
		if command -v sysctl &>/dev/null; then
			WORKERS=$(sysctl -n hw.ncpu)
		fi
	fi
fi

usage() {
	echo "Usage: $0 [options] <file_or_directory_path>"
	echo
	echo "A script to format code in various languages."
	echo
	echo "Options:"
	echo "  -l, --languages LANGS   Specify comma-separated languages to format (e.g., 'python,bash')."
	echo "                          Available: bash, python, javascript, clang, go, rust, swift. Default: all."
	echo "  -I, --ignore PATTERN    Ignore files or directories matching PATTERN (glob)."
	echo "                          Can be specified multiple times. E.g., -I 'dist/*' -I '*.log'"
	echo "  -c, --check             Run in 'dry run' mode. Print files that would be formatted."
	echo "  -w, --workers NUM       Number of parallel workers to run. Defaults to the number of CPU cores."
	echo "      --no-gitignore      Do not respect .gitignore files."
	echo "  -h, --help              Display this help message and exit."
	echo
	echo "If <file_or_directory_path> is not provided, it defaults to the current directory."
}

# check if the current directory (or target directory) is inside a git repository
in_git_repo() {
	git rev-parse --is-inside-work-tree &>/dev/null
}

# checks if a file is ignored by git (and thus by .gitignore)
is_ignored_by_git() {
	if ! $USE_GITIGNORE; then
		# not ignored
		return 1
	fi
	local file="$1"
	if in_git_repo; then
		git check-ignore -q "$file" 2>/dev/null
		return $?
	else
		return 1
	fi
}

# get all ignored patterns from .gitignore and user arguments
get_all_ignore_patterns() {
	local -a patterns=()
	# add user-provided patterns first
	for p in "${ignore_patterns[@]}"; do
		patterns+=("$p")
	done

	# add patterns from .gitignore
	if $USE_GITIGNORE && in_git_repo; then
		while IFS= read -r line; do
			# add to array, removing trailing slash if it exists
			patterns+=("${line%/}")
		done < <(git ls-files --others --ignored --exclude-standard --directory)
	fi

	# always ignore node_modules
	if ! [[ " ${patterns[*]} " =~ " node_modules " ]]; then
		patterns+=("node_modules")
	fi

	# return a space-separated list of patterns
	echo "${patterns[@]}"
}

is_user_ignored() {
	local file="$1"
	local rel_file

	local -a patterns_local
	if [[ -n "$IGNORE_PATTERNS_STR" ]]; then
		IFS=$'\x1F' read -r -a patterns_local <<<"$IGNORE_PATTERNS_STR"
	fi

	if [[ -n "$resolved_path" && "$file" == "$resolved_path"* ]]; then
		rel_file="${file#$resolved_path/}"
	else
		rel_file="$file"
	fi

	for pattern in "${patterns_local[@]}"; do
		if [[ "$rel_file" == $pattern ]]; then
			return 0
		fi
	done
	return 1
}

# builds find arguments to prune ignored directories
build_prune_args() {
	local path="$1"
	local -a patterns_to_ignore
	read -r -a patterns_to_ignore <<<"$(get_all_ignore_patterns)"

	local -a prune_args=()
	if [ ${#patterns_to_ignore[@]} -gt 0 ]; then
		local -a prune_paths=()
		for pattern in "${patterns_to_ignore[@]}"; do
			if [ ${#prune_paths[@]} -gt 0 ]; then
				prune_paths+=(-o)
			fi
			# use -name for simple names and -path for paths with wildcards
			if [[ "$pattern" == *"/"* ]]; then
				prune_paths+=(-path "$path/$pattern")
			else
				prune_paths+=(-name "$pattern")
			fi
		done
		prune_args+=(\()
		prune_args+=("${prune_paths[@]}")
		prune_args+=(\) -prune)
	fi
	echo "${prune_args[@]}"
}

format_bash() {
	local path="$1"

	# reformat a single file
	reformat_file() {
		local file_path="$1"
		if is_ignored_by_git "$file_path"; then
			echo -e "${YELLOW}Skipping ignored file (git):${NC} $file_path"
			return
		fi
		if is_user_ignored "$file_path"; then
			echo -e "${YELLOW}Skipping ignored file (user):${NC} $file_path"
			return
		fi

		if $DRY_RUN; then
			if ! shfmt -d "$file_path"; then
				echo -e "${YELLOW}Would reformat:${NC} $file_path"
			fi
			return
		fi

		if shfmt -w "$file_path"; then
			echo -e "${GREEN}Reformatted:${NC} $file_path"
		else
			echo -e "${RED}Error formatting:${NC} $file_path"
		fi
	}

	# reformat all supported shell script files in a directory
	reformat_shell_scripts() {
		local directory="$1"
		local -a prune_args
		read -r -a prune_args <<<"$(build_prune_args "$directory")"

		local find_cmd=(find "$directory" "${prune_args[@]}" -o -type f \( -name "*.sh" -o -name "*.bash" -o -name "*.dash" -o -name "*.ksh" -o -name "*.zsh" \) -print0)

		export -f reformat_file is_ignored_by_git is_user_ignored in_git_repo
		export GREEN NC YELLOW RED DRY_RUN resolved_path USE_GITIGNORE
		IGNORE_PATTERNS_STR=$(
			IFS=$'\x1F'
			echo "${ignore_patterns[*]}"
		)
		export IGNORE_PATTERNS_STR
		"${find_cmd[@]}" | xargs -0 -P "$WORKERS" -I{} bash -c 'reformat_file "$1"' _ "{}"
	}

	if ! command -v shfmt &>/dev/null; then
		echo -e "${RED}Error: shfmt is not installed. Please install shfmt and try again.${NC}"
		return 1
	fi

	if [[ -d "$path" ]]; then
		reformat_shell_scripts "$path"
	elif [[ -f "$path" ]]; then
		if [[ "$path" == *.sh || "$path" == *.bash || "$path" == *.dash || "$path" == *.ksh || "$path" == *.zsh ]]; then
			reformat_file "$path"
		else
			echo -e "${RED}Error: File '$path' is not a supported shell script file.${NC}"
			return 1
		fi
	else
		echo -e "${RED}Error: Path '$path' does not exist.${NC}"
		return 1
	fi
}

format_python_file() {
	local file="$1"
	if is_ignored_by_git "$file"; then
		echo -e "${YELLOW}Skipping ignored file (git):${NC} $file"
		return
	fi
	if is_user_ignored "$file"; then
		echo -e "${YELLOW}Skipping ignored file (user):${NC} $file"
		return
	fi

	if $DRY_RUN; then
		if ! black --check --diff "$file"; then
			echo -e "${YELLOW}Would reformat:${NC} $file"
		fi
		return
	fi

	echo -e "${BLUE}Formatting Python file:${NC} $file"
	black "$file"
}

format_python() {
	local path="$1"
	if ! command -v black &>/dev/null; then
		echo -e "${RED}Error: black is not installed. Please install black and try again.${NC}"
		return 1
	fi

	if [[ -d "$path" ]]; then
		echo -e "${BLUE}Formatting Python files in directory:${NC} $path"
		local -a prune_args
		read -r -a prune_args <<<"$(build_prune_args "$path")"

		local find_cmd=(find "$path" "${prune_args[@]}" -o -type f -name "*.py" -print0)

		export -f format_python_file is_ignored_by_git is_user_ignored in_git_repo
		export GREEN NC YELLOW RED BLUE DRY_RUN resolved_path USE_GITIGNORE
		IGNORE_PATTERNS_STR=$(
			IFS=$'\x1F'
			echo "${ignore_patterns[*]}"
		)
		export IGNORE_PATTERNS_STR
		"${find_cmd[@]}" | xargs -0 -P "$WORKERS" -I{} bash -c 'format_python_file "$1"' _ "{}"
	elif [[ -f "$path" && "$path" == *.py ]]; then
		format_python_file "$path"
	else
		echo -e "${RED}Error: Path '$path' is not a Python file or directory.${NC}"
		return 1
	fi
}

format_javascript() {
	local path="$1"
	if ! command -v prettier &>/dev/null; then
		echo -e "${RED}Error: prettier is not installed. Please install prettier and try again.${NC}"
		return 1
	fi

	# function to format a single file
	format_js_file() {
		local file="$1"
		if is_ignored_by_git "$file"; then
			echo -e "${YELLOW}Skipping ignored file (git):${NC} $file"
			return
		fi
		if is_user_ignored "$file"; then
			echo -e "${YELLOW}Skipping ignored file (user):${NC} $file"
			return
		fi

		if $DRY_RUN; then
			if ! prettier --check "$file"; then
				echo -e "${YELLOW}Would reformat:${NC} $file"
			fi
			return
		fi

		prettier --write "$file" --log-level warn
	}

	local prettier_extensions="js,jsx,ts,tsx,json,md,html,css,yml,yaml,graphql,vue,scss,less"

	if [[ -d "$path" ]]; then
		echo -e "${BLUE}Formatting Prettier-supported files in:${NC} $path"

		local -a prune_args
		read -r -a prune_args <<<"$(build_prune_args "$path")"

		local -a find_args=("$path")
		find_args+=("${prune_args[@]}")
		find_args+=(-o)

		local -a name_args=()
		local first=true
		for ext in $(echo "$prettier_extensions" | tr ',' ' '); do
			if $first; then
				name_args+=(-name "*.$ext")
				first=false
			else
				name_args+=(-o -name "*.$ext")
			fi
		done
		find_args+=(\( "${name_args[@]}" \))

		local find_cmd=(find "${find_args[@]}" -print0)

		export -f format_js_file is_ignored_by_git is_user_ignored in_git_repo
		export GREEN NC YELLOW RED BLUE DRY_RUN resolved_path USE_GITIGNORE
		IGNORE_PATTERNS_STR=$(
			IFS=$'\x1F'
			echo "${ignore_patterns[*]}"
		)
		export IGNORE_PATTERNS_STR
		"${find_cmd[@]}" | xargs -0 -P "$WORKERS" -I{} bash -c 'format_js_file "$1"' _ "{}"
	elif [[ -f "$path" ]]; then
		is_supported=false
		for ext in $(echo "$prettier_extensions" | tr ',' ' '); do
			if [[ "$path" == *."$ext" ]]; then
				is_supported=true
				break
			fi
		done
		if $is_supported; then
			echo -e "${BLUE}Formatting file:${NC} $path"
			format_js_file "$path"
		else
			echo -e "${RED}Error: Path '$path' is not a Prettier-supported file or directory.${NC}"
			return 1
		fi
	else
		echo -e "${RED}Error: Path '$path' does not exist.${NC}"
		return 1
	fi
}

format_clang() {
	local path="$1"
	if ! command -v clang-format &>/dev/null; then
		echo -e "${RED}Error: clang-format is not installed. Please install clang-format and try again.${NC}"
		return 1
	fi

	# function to format a single file
	format_file() {
		local file="$1"
		if is_ignored_by_git "$file"; then
			echo -e "${YELLOW}Skipping ignored file (git):${NC} $file"
			return
		fi
		if is_user_ignored "$file"; then
			echo -e "${YELLOW}Skipping ignored file (user):${NC} $file"
			return
		fi

		if $DRY_RUN; then
			if ! clang-format "$file" | diff -q "$file" - >/dev/null; then
				echo -e "${YELLOW}Changes detected in:${NC} $file"
				clang-format "$file" | diff -u "$file" -
			fi
			return
		fi

		if clang-format -i "$file"; then
			echo -e "${GREEN}Formatted:${NC} $file"
		else
			echo -e "${RED}Error formatting:${NC} $file"
		fi
	}

	if [[ -d "$path" ]]; then
		echo -e "${BLUE}Formatting C/C++/Obj-C/Java files in directory:${NC} $path"
		local -a prune_args
		read -r -a prune_args <<<"$(build_prune_args "$path")"

		local find_cmd=(find "$path" "${prune_args[@]}" -o -type f \( -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.hpp" -o -name "*.m" -o -name "*.mm" -o -name "*.java" \) -print0)

		export -f format_file is_ignored_by_git is_user_ignored in_git_repo
		export GREEN NC YELLOW RED DRY_RUN resolved_path USE_GITIGNORE
		IGNORE_PATTERNS_STR=$(
			IFS=$'\x1F'
			echo "${ignore_patterns[*]}"
		)
		export IGNORE_PATTERNS_STR
		"${find_cmd[@]}" | xargs -0 -P "$WORKERS" -I{} bash -c 'format_file "$1"' _ "{}"
	elif [[ -f "$path" ]]; then
		case "$path" in
		*.c | *.cpp | *.h | *.hpp | *.m | *.mm | *.java)
			echo -e "${BLUE}Formatting file:${NC} $path"
			format_file "$path"
			;;
		*)
			echo -e "${RED}Error: File '$path' is not a supported C/C++/Obj-C/Java file.${NC}"
			return 1
			;;
		esac
	else
		echo -e "${RED}Error: Path '$path' does not exist.${NC}"
		return 1
	fi
}

format_go() {
	local path="$1"
	if ! command -v gofmt &>/dev/null; then
		echo -e "${RED}Error: gofmt is not installed. Please install Go and try again.${NC}"
		return 1
	fi

	# function to format a single file
	format_go_file() {
		local file="$1"
		if is_ignored_by_git "$file"; then
			echo -e "${YELLOW}Skipping ignored file (git):${NC} $file"
			return
		fi
		if is_user_ignored "$file"; then
			echo -e "${YELLOW}Skipping ignored file (user):${NC} $file"
			return
		fi

		if $DRY_RUN; then
			if ! gofmt "$file" | diff -q "$file" - >/dev/null; then
				echo -e "${YELLOW}Changes detected in:${NC} $file"
				gofmt "$file" | diff -u "$file" -
			fi
			return
		fi

		if gofmt -w "$file"; then
			echo -e "${GREEN}Formatted:${NC} $file"
		else
			echo -e "${RED}Error formatting:${NC} $file"
		fi
	}

	if [[ -d "$path" ]]; then
		echo -e "${BLUE}Formatting Go files in directory:${NC} $path"
		local -a prune_args
		read -r -a prune_args <<<"$(build_prune_args "$path")"

		local find_cmd=(find "$path" "${prune_args[@]}" -o -type f -name "*.go" -print0)

		export -f format_go_file is_ignored_by_git is_user_ignored in_git_repo
		export GREEN NC YELLOW RED BLUE DRY_RUN resolved_path USE_GITIGNORE
		IGNORE_PATTERNS_STR=$(
			IFS=$'\x1F'
			echo "${ignore_patterns[*]}"
		)
		export IGNORE_PATTERNS_STR
		"${find_cmd[@]}" | xargs -0 -P "$WORKERS" -I{} bash -c 'format_go_file "$1"' _ "{}"
	elif [[ -f "$path" && "$path" == *.go ]]; then
		echo -e "${BLUE}Formatting Go file:${NC} $path"
		format_go_file "$path"
	else
		echo -e "${RED}Error: Path '$path' is not a Go file or directory.${NC}"
		return 1
	fi
}

format_rust() {
	local path="$1"
	if ! command -v rustfmt &>/dev/null; then
		echo -e "${RED}Error: rustfmt is not installed. Please install it with 'rustup component add rustfmt' and try again.${NC}"
		return 1
	fi

	find_cargo_project_root() {
		local dir="$1"
		while [ -n "$dir" ] && [ "$dir" != "/" ]; do
			if [ -f "$dir/Cargo.toml" ]; then
				echo "$dir"
				return 0
			fi
			dir=$(dirname "$dir")
		done
		return 1
	}

	# function to format a single file
	format_rust_file() {
		local file="$1"
		if is_ignored_by_git "$file"; then
			echo -e "${YELLOW}Skipping ignored file (git):${NC} $file"
			return
		fi
		if is_user_ignored "$file"; then
			echo -e "${YELLOW}Skipping ignored file (user):${NC} $file"
			return
		fi

		if $DRY_RUN; then
			if ! rustfmt --check "$file"; then
				echo -e "${YELLOW}Would reformat:${NC} $file"
			fi
			return
		fi

		if rustfmt "$file"; then
			echo -e "${GREEN}Formatted:${NC} $file"
		else
			echo -e "${RED}Error formatting:${NC} $file"
		fi
	}

	if [[ -d "$path" ]]; then
		local cargo_root
		cargo_root=$(find_cargo_project_root "$path")

		if [ -n "$cargo_root" ]; then
			echo -e "${BLUE}Formatting Rust project:${NC} $cargo_root"
			if ! command -v cargo &>/dev/null; then
				echo -e "${RED}Error: cargo is not installed. Please install Rust and try again.${NC}"
				return 1
			fi
			(
				cd "$cargo_root" || return
				if $DRY_RUN; then
					if ! cargo fmt -- --check; then
						echo -e "${YELLOW}Would reformat files in project:${NC} $cargo_root"
					fi
					return
				fi

				if cargo fmt; then
					echo -e "${GREEN}Formatted project:${NC} $cargo_root"
				else
					echo -e "${RED}Error formatting project:${NC} $cargo_root"
				fi
			)
		else
			echo -e "${BLUE}Formatting Rust files in directory:${NC} $path"
			local -a prune_args
			read -r -a prune_args <<<"$(build_prune_args "$path")"

			local find_cmd=(find "$path" "${prune_args[@]}" -o -type f -name "*.rs" -print0)

			export -f format_rust_file is_ignored_by_git is_user_ignored in_git_repo
			export GREEN NC YELLOW RED BLUE DRY_RUN resolved_path USE_GITIGNORE
			# Serialize array with unit separator (Bash can't export arrays)
			IGNORE_PATTERNS_STR=$(
				IFS=$'\x1F'
				echo "${ignore_patterns[*]}"
			)
			export IGNORE_PATTERNS_STR
			"${find_cmd[@]}" | xargs -0 -P "$WORKERS" -I{} bash -c 'format_rust_file "$1"' _ "{}"
		fi
	elif [[ -f "$path" && "$path" == *.rs ]]; then
		echo -e "${BLUE}Formatting Rust file:${NC} $path"
		format_rust_file "$path"
	else
		echo -e "${RED}Error: Path '$path' is not a Rust file or directory.${NC}"
		return 1
	fi
}

format_swift() {
	local path="$1"
	if ! command -v swift-format &>/dev/null; then
		echo -e "${RED}Error: swift-format is not installed. Please install it and try again.${NC}"
		echo -e "${YELLOW}On macOS, you can use 'brew install swift-format'. For other systems, please see the official installation instructions.${NC}"
		return 1
	fi

	# function to format a single file
	format_swift_file() {
		local file="$1"
		if is_ignored_by_git "$file"; then
			echo -e "${YELLOW}Skipping ignored file (git):${NC} $file"
			return
		fi
		if is_user_ignored "$file"; then
			echo -e "${YELLOW}Skipping ignored file (user):${NC} $file"
			return
		fi

		if $DRY_RUN; then
			if ! swift-format lint --strict "$file" >/dev/null 2>&1; then
				echo -e "${YELLOW}Would reformat:${NC} $file"
			fi
			return
		fi

		if swift-format --in-place "$file"; then
			echo -e "${GREEN}Formatted:${NC} $file"
		else
			echo -e "${RED}Error formatting:${NC} $file"
		fi
	}

	if [[ -d "$path" ]]; then
		echo -e "${BLUE}Formatting Swift files in directory:${NC} $path"
		local -a prune_args
		read -r -a prune_args <<<"$(build_prune_args "$path")"

		local find_cmd=(find "$path" "${prune_args[@]}" -o -type f -name "*.swift" -print0)

		export -f format_swift_file is_ignored_by_git is_user_ignored in_git_repo
		export GREEN NC YELLOW RED BLUE DRY_RUN resolved_path USE_GITIGNORE
		IGNORE_PATTERNS_STR=$(
			IFS=$'\x1F'
			echo "${ignore_patterns[*]}"
		)
		export IGNORE_PATTERNS_STR
		"${find_cmd[@]}" | xargs -0 -P "$WORKERS" -I{} bash -c 'format_swift_file "$1"' _ "{}"
	elif [[ -f "$path" && "$path" == *.swift ]]; then
		echo -e "${BLUE}Formatting Swift file:${NC} $path"
		format_swift_file "$path"
	else
		echo -e "${RED}Error: Path '$path' is not a Swift file or directory.${NC}"
		return 1
	fi
}

has_bash_files() {
	local path="$1"
	if [[ -d "$path" ]]; then
		[[ -n $(find "$path" -type f \( -name "*.sh" -o -name "*.bash" -o -name "*.dash" -o -name "*.ksh" -o -name "*.zsh" \) -print -quit) ]]
	elif [[ -f "$path" ]]; then
		[[ "$path" == *.sh || "$path" == *.bash || "$path" == *.dash || "$path" == *.ksh || "$path" == *.zsh ]]
	else
		return 1
	fi
}

has_python_files() {
	local path="$1"
	if [[ -d "$path" ]]; then
		[[ -n $(find "$path" -type f -name "*.py" -print -quit) ]]
	elif [[ -f "$path" ]]; then
		[[ "$path" == *.py ]]
	else
		return 1
	fi
}

has_js_json_md_files() {
	local path="$1"
	if [[ -d "$path" ]]; then
		[[ -n $(find "$path" -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" -o -name "*.json" -o -name "*.md" -o -name "*.html" -o -name "*.css" -o -name "*.yml" -o -name "*.yaml" -o -name "*.graphql" -o -name "*.vue" -o -name "*.scss" -o -name "*.less" \) -print -quit) ]]
	elif [[ -f "$path" ]]; then
		local is_supported=false
		local prettier_extensions="js,jsx,ts,tsx,json,md,html,css,yml,yaml,graphql,vue,scss,less"
		for ext in $(echo "$prettier_extensions" | tr ',' ' '); do
			if [[ "$path" == *."$ext" ]]; then
				is_supported=true
				break
			fi
		done
		$is_supported
	else
		return 1
	fi
}

has_clang_files() {
	local path="$1"
	if [[ -d "$path" ]]; then
		[[ -n $(find "$path" -type f \( -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.hpp" -o -name "*.m" -o -name "*.mm" -o -name "*.java" \) -print -quit) ]]
	elif [[ -f "$path" ]]; then
		[[ "$path" == *.c || "$path" == *.cpp || "$path" == *.h || "$path" == *.hpp || "$path" == *.m || "$path" == *.mm || "$path" == *.java ]]
	else
		return 1
	fi
}

has_go_files() {
	local path="$1"
	if [[ -d "$path" ]]; then
		[[ -n $(find "$path" -type f -name "*.go" -print -quit) ]]
	elif [[ -f "$path" ]]; then
		[[ "$path" == *.go ]]
	else
		return 1
	fi
}

has_rust_files() {
	local path="$1"
	if [[ -d "$path" ]]; then
		[[ -n $(find "$path" -type f -name "*.rs" -print -quit) ]]
	elif [[ -f "$path" ]]; then
		[[ "$path" == *.rs ]]
	else
		return 1
	fi
}

has_swift_files() {
	local path="$1"
	if [[ -d "$path" ]]; then
		[[ -n $(find "$path" -type f -name "*.swift" -print -quit) ]]
	elif [[ -f "$path" ]]; then
		[[ "$path" == *.swift ]]
	else
		return 1
	fi
}

main() {
	local GETOPT_CMD="getopt"

	$GETOPT_CMD --test >/dev/null 2>&1
	if [[ $? -ne 4 ]]; then
		if [[ "$(uname)" == "Darwin" ]] && command -v brew &>/dev/null; then
			local brew_getopt
			brew_getopt="$(brew --prefix gnu-getopt 2>/dev/null)/bin/getopt"
			if [[ -x "$brew_getopt" ]]; then
				$brew_getopt --test >/dev/null 2>&1
				if [[ $? -eq 4 ]]; then
					GETOPT_CMD="$brew_getopt"
				fi
			fi
		fi
	fi

	$GETOPT_CMD --test >/dev/null 2>&1
	if [[ $? -ne 4 ]]; then
		echo -e "${RED}Error: GNU getopt is not available or not in your PATH.${NC}" >&2
		echo "This script uses GNU getopt to parse command-line options." >&2
		if [[ "$(uname)" == "Darwin" ]]; then
			echo "On macOS, you can install it with 'brew install gnu-getopt'." >&2
			echo "Then, add it to your PATH by adding the following line to your ~/.zshrc or ~/.bash_profile:" >&2
			echo 'export PATH="$(brew --prefix gnu-getopt)/bin:$PATH"' >&2
		fi
		return 1
	fi

	local options
	options=$($GETOPT_CMD -o hcl:I:w: --long help,check,languages:,ignore:,workers:,no-gitignore -n "$0" -- "$@")
	if [ $? -ne 0 ]; then
		usage
		return 1
	fi

	eval set -- "$options"

	while true; do
		case "$1" in
		-h | --help)
			usage
			return 0
			;;
		-c | --check)
			DRY_RUN=true
			shift
			;;
		-w | --workers)
			WORKERS="$2"
			shift 2
			;;
		-l | --languages)
			IFS=',' read -r -a languages_to_format <<<"$2"
			shift 2
			;;
		-I | --ignore)
			ignore_patterns+=("$2")
			shift 2
			;;
		--no-gitignore)
			USE_GITIGNORE=false
			shift
			;;
		--)
			shift
			break
			;;
		*)
			echo "Internal error!"
			exit 1
			;;
		esac
	done

	IGNORE_PATTERNS_STR=$(
		IFS=$'\x1F'
		echo "${ignore_patterns[*]}"
	)
	export IGNORE_PATTERNS_STR

	local path="$1"

	if ! [[ "$WORKERS" =~ ^[1-9][0-9]*$ ]]; then
		echo -e "${RED}Error: --workers must be a positive integer.${NC}"
		return 1
	fi

	if [[ -z "$path" ]]; then
		read -p "No path provided. Use current dir (hit ENTER to continue)? " confirm
		if [[ $confirm =~ ^[Yy]$ || $confirm == "" ]]; then
			path="."
		else
			echo -e "${RED}Operation cancelled!${NC}"
			exit 0
		fi
	fi

	local resolved_path
	resolved_path=$(realpath "$path" 2>/dev/null)
	if [[ $? -ne 0 ]]; then
		echo -e "${RED}Error: Unable to resolve path '$path'.${NC}"
		return 1
	fi

	# prompt user when the target directory is the root "/" directory
	if [[ "$resolved_path" == "/" ]]; then
		echo -e "${RED}WARNING: You are about to run formatting on the entire root directory '/'. This could be dangerous!${NC}"
		read -p "Are you ABSOLUTELY sure? (type 'YES' to continue): " confirm
		if [[ "$confirm" != "YES" ]]; then
			echo -e "${RED}Operation cancelled!${NC}"
			return 1
		fi
	elif [[ "$resolved_path" == "$HOME" ]]; then
		echo -e "${RED}WARNING: You are about to run formatting on your home directory '$HOME'. This could be very large and potentially unwanted!${NC}"
		read -p "Are you sure? (y/N): " confirm
		if [[ ! $confirm =~ ^[Yy]$ ]]; then
			echo -e "${RED}Operation cancelled!${NC}"
			return 1
		fi
	fi

	echo -e "${YELLOW}Starting code formatting with $WORKERS worker(s)...${NC}"
	echo

	local run_all=true
	if [ ${#languages_to_format[@]} -gt 0 ]; then
		run_all=false
	fi

	should_run() {
		if $run_all; then return 0; fi
		for lang in "${languages_to_format[@]}"; do
			if [[ "$lang" == "$1" ]]; then
				return 0
			fi
		done
		return 1
	}

	if [[ -d "$resolved_path" ]]; then
		# format directories by checking for each file type
		if should_run "bash" && has_bash_files "$resolved_path"; then
			echo -e "${GREEN}Formatting Bash/Zsh files${NC}"
			format_bash "$resolved_path"
			echo
		fi

		if should_run "python" && has_python_files "$resolved_path"; then
			echo -e "${GREEN}Formatting Python files${NC}"
			format_python "$resolved_path"
			echo
		fi

		if should_run "javascript" && has_js_json_md_files "$resolved_path"; then
			echo -e "${GREEN}Formatting JavaScript/JSON/Markdown files${NC}"
			format_javascript "$resolved_path"
			echo
		fi

		if should_run "clang" && has_clang_files "$resolved_path"; then
			echo -e "${GREEN}Formatting C/C++/Obj-C/Java files${NC}"
			format_clang "$resolved_path"
			echo
		fi

		if should_run "go" && has_go_files "$resolved_path"; then
			echo -e "${GREEN}Formatting Go files${NC}"
			format_go "$resolved_path"
			echo
		fi

		if should_run "rust" && has_rust_files "$resolved_path"; then
			echo -e "${GREEN}Formatting Rust files${NC}"
			format_rust "$resolved_path"
			echo
		fi

		if should_run "swift" && has_swift_files "$resolved_path"; then
			echo -e "${GREEN}Formatting Swift files${NC}"
			format_swift "$resolved_path"
			echo
		fi
	elif [[ -f "$resolved_path" ]]; then
		# format a single file based on its extension
		case "$resolved_path" in
		*.sh | *.bash | *.dash | *.ksh | *.zsh)
			if should_run "bash"; then
				echo -e "${GREEN}Formatting shell script file${NC}"
				format_bash "$resolved_path"
			else
				echo -e "${YELLOW}Skipping: 'bash' not in the languages to format.${NC}"
			fi
			;;
		*.py)
			if should_run "python"; then
				echo -e "${GREEN}Formatting Python file${NC}"
				format_python "$resolved_path"
			else
				echo -e "${YELLOW}Skipping: 'python' not in the languages to format.${NC}"
			fi
			;;
		*.go)
			if should_run "go"; then
				echo -e "${GREEN}Formatting Go file${NC}"
				format_go "$resolved_path"
			else
				echo -e "${YELLOW}Skipping: 'go' not in the languages to format.${NC}"
			fi
			;;
		*.rs)
			if should_run "rust"; then
				echo -e "${GREEN}Formatting Rust file${NC}"
				format_rust "$resolved_path"
			else
				echo -e "${YELLOW}Skipping: 'rust' not in the languages to format.${NC}"
			fi
			;;
		*.swift)
			if should_run "swift"; then
				echo -e "${GREEN}Formatting Swift file${NC}"
				format_swift "$resolved_path"
			else
				echo -e "${YELLOW}Skipping: 'swift' not in the languages to format.${NC}"
			fi
			;;
		*)
			is_js=false
			prettier_extensions="js,jsx,ts,tsx,json,md,html,css,yml,yaml,graphql,vue,scss,less"
			for ext in $(echo "$prettier_extensions" | tr ',' ' '); do
				if [[ "$resolved_path" == *."$ext" ]]; then
					is_js=true
					break
				fi
			done

			is_clang=false
			if ! $is_js; then
				clang_extensions="c,cpp,h,hpp,m,mm,java"
				for ext in $(echo "$clang_extensions" | tr ',' ' '); do
					if [[ "$resolved_path" == *."$ext" ]]; then
						is_clang=true
						break
					fi
				done
			fi

			if $is_js; then
				if should_run "javascript"; then
					echo -e "${GREEN}Formatting Prettier-supported file${NC}"
					format_javascript "$resolved_path"
				else
					echo -e "${YELLOW}Skipping: 'javascript' not in the languages to format.${NC}"
				fi
			elif $is_clang; then
				if should_run "clang"; then
					echo -e "${GREEN}Formatting C/C++/Obj-C/Java file${NC}"
					format_clang "$resolved_path"
				else
					echo -e "${YELLOW}Skipping: 'clang' not in the languages to format.${NC}"
				fi
			else
				echo -e "${RED}Error: Unsupported file type.${NC}"
				return 1
			fi
			;;
		esac
	else
		echo -e "${RED}Error: Path '$resolved_path' does not exist.${NC}"
		return 1
	fi

	echo -e "${YELLOW}Formatting complete!${NC}"
}

# main function calls
main "$@"
