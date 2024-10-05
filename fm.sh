# colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

format_bash() {
	local path="$1"

	# reformat a single file
	reformat_file() {
		local file_path="$1"
		if shfmt -w "$file_path"; then
			echo -e "${GREEN}Reformatted:${NC} $file_path"
		else
			echo -e "${RED}Error formatting:${NC} $file_path"
		fi
	}

	# reformat all supported shell script files in a directory
	reformat_shell_scripts() {
		local directory="$1"
		find "$directory" -type d -name "node_modules" -prune -o -type f \( -name "*.sh" -o -name "*.bash" -o -name "*.dash" -o -name "*.ksh" -o -name "*.zsh" \) -print | while read -r file; do
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

format_python() {
	local path="$1"
	if ! command -v black &>/dev/null; then
		echo -e "${RED}Error: black is not installed. Please install black and try again.${NC}"
		return 1
	fi
	if [[ -d "$path" ]]; then
		echo -e "${BLUE}Formatting Python files in directory:${NC} $path"
		black "$path"
	elif [[ -f "$path" && "$path" == *.py ]]; then
		echo -e "${BLUE}Formatting Python file:${NC} $path"
		black "$path"
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
	if [[ -d "$path" ]]; then
		echo -e "${BLUE}Formatting JavaScript/JSON/Markdown files in directory:${NC} $path"
		output=$(prettier --write "$path/**/*.{js,jsx,ts,tsx,json,md,html,css,yml,yaml,graphql,vue,scss,less}" 2>&1)
		if [[ $output == *"No files matching the pattern were found"* ]]; then
			echo "No Prettier supported files found"
		else
			echo "$output"
		fi
	elif [[ -f "$path" && ("$path" == *.js || "$path" == *.json || "$path" == *.md) ]]; then
		echo -e "${BLUE}Formatting file:${NC} $path"
		prettier --write "$path"
	else
		echo -e "${RED}Error: Path '$path' is not a JavaScript, JSON, or Markdown file or directory.${NC}"
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
		if clang-format -i "$file"; then
			echo -e "${GREEN}Formatted:${NC} $file"
		else
			echo -e "${RED}Error formatting:${NC} $file"
		fi
	}

	if [[ -d "$path" ]]; then
		echo -e "${BLUE}Formatting C/C++/Obj-C/Java files in directory:${NC} $path"
		find "$path" -type f \( -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.hpp" -o -name "*.m" -o -name "*.mm" -o -name "*.java" \) -print0 | while IFS= read -r -d '' file; do
			format_file "$file"
		done
	elif [[ -f "$path" ]]; then
		case "$path" in
		*.c | *.cpp | *.h | *.hpp | *.m | *.mm | *.java)
			echo -e "${BLUE}Formatting file:${NC} $path"
			format_file "$path"
			;;
		*)
			echo -e "${RED}Error: File '$path' is not a supported C, C++, Obj-C, or Java file.${NC}"
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
		[[ "$path" == *.js || "$path" == *.json || "$path" == *.md ]]
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
	local path="$1"

	if [[ -z "$path" ]]; then
		echo -e "${RED}Error: Please provide a file or directory path.${NC}"
		echo -e "Usage: $0 <file_or_directory_path>"
		return 1
	fi

	echo -e "${YELLOW}Starting code formatting...${NC}"
	echo

	if [[ -d "$path" ]]; then
		if has_bash_files "$path"; then
			echo -e "${GREEN}Formatting Bash/Zsh files${NC}"
			format_bash "$path"
			echo
		fi

		if has_python_files "$path"; then
			echo -e "${GREEN}Formatting Python files${NC}"
			format_python "$path"
			echo
		fi

		if has_js_json_md_files "$path"; then
			echo -e "${GREEN}Formatting JavaScript/JSON/Markdown files${NC}"
			format_javascript "$path"
			echo
		fi

		if has_clang_files "$path"; then
			echo -e "${GREEN}Formatting C/C++/Obj-C/Java files${NC}"
			format_clang "$path"
			echo
		fi
	elif [[ -f "$path" ]]; then
		case "$path" in
		*.sh | *.bash | *.dash | *.ksh | *.zsh)
			echo -e "${GREEN}Formatting shell script file${NC}"
			format_bash "$path"
			;;
		*.py)
			echo -e "${GREEN}Formatting Python file${NC}"
			format_python "$path"
			;;
		*.js | *.json | *.md)
			echo -e "${GREEN}Formatting JavaScript/JSON/Markdown file${NC}"
			format_javascript "$path"
			;;
		*.c | *.cpp | *.h | *.hpp | *.m | *.mm | *.java)
			echo -e "${GREEN}Formatting C/C++/Obj-C/Java file${NC}"
			format_clang "$path"
			;;
		*)
			echo -e "${RED}Error: Unsupported file type.${NC}"
			return 1
			;;
		esac
	else
		echo -e "${RED}Error: Path '$path' does not exist.${NC}"
		return 1
	fi

	echo -e "${YELLOW}Formatting complete!${NC}"
}

# main function calls
if [ -z "$1" ]; then
	read -p "Use current dir (hit ENTER to continue)? " confirm
	if [[ $confirm =~ ^[Yy]$ || $confirm == "" ]]; then
		main "."
	else
		exit 0
	fi
else
	main "$1"
fi
