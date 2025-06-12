#!/usr/bin/env bash

# terminal colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# options
declare -a ignore_patterns=()
declare -a languages_to_format=()

usage() {
	echo "Usage: $0 [options] <file_or_directory_path>"
	echo
	echo "A script to format code in various languages."
	echo
	echo "Options:"
	echo "  -l, --languages LANGS   Specify comma-separated languages to format (e.g., 'python,bash')."
	echo "                          Available: bash, python, javascript, clang. Default: all."
	echo "  -I, --ignore PATTERN    Ignore files or directories matching PATTERN (glob)."
	echo "                          Can be specified multiple times. E.g., -I 'dist/*' -I '*.log'"
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
	local file="$1"
	if in_git_repo; then
		git check-ignore -q "$file" 2>/dev/null
		return $?
	else
		return 1
	fi
}

is_user_ignored() {
	local file="$1"
	local rel_file

	if [[ -n "$resolved_path" && "$file" == "$resolved_path"* ]]; then
		rel_file="${file#$resolved_path/}"
	else
		rel_file="$file"
	fi

	for pattern in "${ignore_patterns[@]}"; do
		if [[ "$rel_file" == $pattern ]]; then
			return 0
		fi
	done
	return 1
}

# builds find arguments to prune ignored directories
build_prune_args() {
	local path="$1"
	local -a prune_args=()

	# also prune node_modules by default
	local -a all_patterns=("node_modules")
	for p in "${ignore_patterns[@]}"; do
		all_patterns+=("$p")
	done

	if [ ${#all_patterns[@]} -gt 0 ]; then
		local -a prune_paths=()
		for pattern in "${all_patterns[@]}"; do
			if [ ${#prune_paths[@]} -gt 0 ]; then
				prune_paths+=(-o)
			fi
			if [[ "$pattern" == "node_modules" ]]; then
				prune_paths+=(-name "node_modules")
			else
				prune_paths+=(-path "$path/$pattern")
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

		find "$directory" "${prune_args[@]}" -o -type f \( -name "*.sh" -o -name "*.bash" -o -name "*.dash" -o -name "*.ksh" -o -name "*.zsh" \) -print0 |
			while IFS= read -r -d '' file; do
				reformat_file "$file"
			done
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

		find "$path" "${prune_args[@]}" -o -type f -name "*.py" -print0 |
			while IFS= read -r -d '' file; do
				format_python_file "$file"
			done
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

	# Function to format a single file
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
		find_args+=(\()
		find_args+=("${name_args[@]}")
		find_args+=(\))

		find "${find_args[@]}" -print0 |
			while IFS= read -r -d '' file; do
				format_js_file "$file"
			done
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

		find "$path" "${prune_args[@]}" -o -type f \( -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.hpp" -o -name "*.m" -o -name "*.mm" -o -name "*.java" \) -print0 |
			while IFS= read -r -d '' file; do
				format_file "$file"
			done
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

main() {
	# Test for GNU getopt
	getopt --test >/dev/null 2>&1
	if [[ $? -ne 4 ]]; then
		echo -e "${RED}Error: GNU getopt is not available or not in your PATH.${NC}" >&2
		echo "This script uses GNU getopt to parse command-line options." >&2
		if [[ $(uname) == "Darwin" ]]; then
			echo "On macOS, you can install it with 'brew install gnu-getopt'." >&2
			echo "Then, add it to your PATH by adding the following line to your ~/.zshrc or ~/.bash_profile:" >&2
			echo 'export PATH="$(brew --prefix gnu-getopt)/bin:$PATH"' >&2
		fi
		return 1
	fi

	local options
	options=$(getopt -o hl:I: --long help,languages:,ignore: -n "$0" -- "$@")
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
		-l | --languages)
			IFS=',' read -r -a languages_to_format <<<"$2"
			shift 2
			;;
		-I | --ignore)
			ignore_patterns+=("$2")
			shift 2
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

	local path="$1"

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

	echo -e "${YELLOW}Starting code formatting...${NC}"
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
