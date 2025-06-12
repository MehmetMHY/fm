# create export directory if it doesn't exist
if [ ! -d "./tests/" ]; then
	mkdir -p "./tests/"
fi

# python: https://github.com/Textualize/rich
git clone https://github.com/Textualize/rich.git ./tests/one/

# javascript: https://github.com/date-fns/date-fns
git clone https://github.com/date-fns/date-fns.git ./tests/two/

# typescript: https://github.com/DefinitelyTyped/DefinitelyTyped
git clone https://github.com/DefinitelyTyped/DefinitelyTyped.git ./tests/three/

# c++: https://github.com/fmtlib/fmt
git clone https://github.com/fmtlib/fmt.git ./tests/four/

# rust: https://github.com/BurntSushi/ripgrep
git clone https://github.com/BurntSushi/ripgrep.git ./tests/five/

# shell/bash: https://github.com/ohmyzsh/ohmyzsh
git clone https://github.com/ohmyzsh/ohmyzsh.git ./tests/six/

# java: https://github.com/spring-projects/spring-boot
git clone https://github.com/spring-projects/spring-boot.git ./tests/seven/

# hugo/markdown: https://github.com/schnerring/hugo-theme-gruvbox
git clone https://github.com/schnerring/hugo-theme-gruvbox.git ./tests/eight/

# hugo/markdown: https://github.com/CaiJimmy/hugo-theme-stack
git clone https://github.com/CaiJimmy/hugo-theme-stack.git ./tests/nine/
