# create export directory if it doesn't exist
if [ ! -d "./tests/" ]; then
	mkdir -p "./tests/"
fi

# Python: https://github.com/Textualize/rich
git clone https://github.com/Textualize/rich.git ./tests/one/

# JavaScript: https://github.com/date-fns/date-fns
git clone https://github.com/date-fns/date-fns.git ./tests/two/

# TypeScript: https://github.com/DefinitelyTyped/DefinitelyTyped
git clone https://github.com/DefinitelyTyped/DefinitelyTyped.git ./tests/three/

# C++: https://github.com/fmtlib/fmt
git clone https://github.com/fmtlib/fmt.git ./tests/four/

# Rust: https://github.com/BurntSushi/ripgrep
git clone https://github.com/BurntSushi/ripgrep.git ./tests/five/

# Shell/Bash: https://github.com/ohmyzsh/ohmyzsh
git clone https://github.com/ohmyzsh/ohmyzsh.git ./tests/six/

# Java: https://github.com/spring-projects/spring-boot
git clone https://github.com/spring-projects/spring-boot.git ./tests/seven/

# Hugo/Markdown: https://github.com/schnerring/hugo-theme-gruvbox
git clone https://github.com/schnerring/hugo-theme-gruvbox.git ./tests/eight/

# Hugo/Markdown: https://github.com/CaiJimmy/hugo-theme-stack
git clone https://github.com/CaiJimmy/hugo-theme-stack.git ./tests/nine/
