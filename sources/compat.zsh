export JOSH_DELTA=`which delta`

if [[ "$OSTYPE" == "freebsd"* ]]; then

    export JOSH_LS='/usr/local/bin/gnuls'
    export JOSH_SED='/usr/local/bin/gsed'
    export JOSH_GREP='/usr/local/bin/grep'
    export JOSH_REALPATH='/usr/local/bin/grealpath'

    export OS_TYPE="BSD"
    export DELTA="delta --commit-style plain --file-style plain --hunk-style plain --highlight-removed"

else
    export JOSH_LS=`which ls`
    export JOSH_SED=`which sed`
    export JOSH_GREP=`which grep`
    export JOSH_REALPATH=`which realpath`

    export OS_TYPE="LINUX"
    export DELTA="delta --commit-style='yellow ul' --commit-decoration-style='' --file-style='cyan ul' --file-decoration-style='' --hunk-style normal --zero-style='dim syntax' --24-bit-color='always' --minus-style='syntax #330000' --plus-style='syntax #002200' --file-modified-label='M' --file-removed-label='D' --file-added-label='A' --file-renamed-label='R' --line-numbers-left-format='{nm:^4}' --line-numbers-minus-style='#aa2222' --line-numbers-zero-style='#505055' --line-numbers-plus-style='#229922' --line-numbers --navigate"
fi

alias ls="$JOSH_LS -vaAF --color"
alias ri="$JOSH_GREP -rnH --color=auto"

alias sed="$JOSH_SED"
alias grep="$JOSH_GREP"
alias delta="$JOSH_DELTA"
alias realpath="$JOSH_REALPATH"

if [ -n "$(uname -v | grep -i debian)" ]; then
    alias fd='fdfind'
fi
