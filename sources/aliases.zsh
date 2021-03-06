alias cpdir='rsync --archive --links --times'

alias mv='mv'
alias ln='ln'
alias cp='cp -iR'
alias rm='rm'
alias ps='ps'
alias tt='tail -f -n 100'
alias tate='truncate -s 0'

alias ag='ag -C1 --noaffinity --path-to-ignore ~/.ignore --stats --smart-case --width 140'

local RIPGREP_OPTS='--context 1 --context-separator "" --require-git --stats --text --ignore-file ~/.ignore --max-columns 140 --max-columns-preview --max-filesize 1M --color always --colors "match:fg:yellow" --colors "path:fg:red"'

alias rf="rg --smart-case $RIPGREP_OPTS"
alias rg="rg --case-sensitive --fixed-strings --word-regexp $RIPGREP_OPTS"
alias rfs="rf --sort path"

alias ri="$JOSH_GREP -rnH --exclude '*.js' --exclude '*.min.css' --exclude '.git/' --exclude 'node_modules/' --exclude 'lib/python*/site-packages/' --exclude '__snapshots__/' --exclude '.eggs/' --exclude '*.pyc' --exclude '*.po' --exclude '*.svg' --color=auto"

alias sed="$JOSH_SED"
alias grep="$JOSH_GREP --line-buffered"
alias delta="$JOSH_DELTA"
alias realpath="$JOSH_REALPATH"

alias -g I='| grep -i'
alias -g E='| grep -iv'
alias -g LL="2>&1 | less"
alias -g CA="2>&1 | cat -A"
alias -g NE="2> /dev/null"
alias -g NUL="> /dev/null 2>&1"
alias -g GL="awk '{\$1=\$1};1' | sed -z 's/\n/ /g' | awk '{\$1=\$1};1'"

alias -g E_INFO="| grep -v '\[INFO\]'"
alias -g E_DEBUG="| grep -v '\[DEBUG\]'"
alias -g E_WARNING="| grep -v '\[WARNING\]'"

alias -g CC="| ccze"

alias ls="$JOSH_LS -vaAF --color"

svc() {
    service $*
}

fchmod() {
    find $2 -type f -not -perm $1 -exec chmod $1 {} \;
}

dchmod() {
    find $2 -type d -not -perm $1 -exec chmod $1 {} \;
}

rchgrp() {
    find $2 ( -not -group $1 ) -print -exec chgrp $1 {} ;
}

lst() {
    tree -F -f -i | grep -v '[/]$' I $*
}

look() {
    find . -type f | xargs -n 1 grep -nHi "$*"
}

lg() {
    la $2 | grep -i "$*"
}
function mkcd {
    mkdir "$*" && cd "$*"
}

function mktp {
    local tempdir=`mktemp -d`
    mkdir -p "$tempdir" && cd "$tempdir"
}

kimport() {
    gpg --recv-key $1 && gpg --export $1 | apt-key add -
}

w() {
    sh -c "$READ_URI \"http://cheat.sh/`urlencode $@`\""
}

q() {
    sh -c "$READ_URI \"http://cheat.sh/~`urlencode $@`\""
}

commit () {
    RBUFFER=`sh -c "$READ_URI http://whatthecommit.com/index.txt"`${RBUFFER}
    zle end-of-line
}

last-dir() {
    local $directory="${1:-.}"
    find $directory -type d -printf "%T@ %p\n" | sort -n | cut -d' ' -f 2- | tail -n 1
}

alias http='http --verify no'

function agent {
    eval `ssh-agent` && ssh-add
}

function sget {
    wget --no-check-certificate -O- $* &> /dev/null
}

function nget {
    wget --no-check-certificate -O/dev/null $*
}

function run_show() {
    local cmd="$*"
    echo " -> $cmd"
    eval ${cmd} 1>&2
}

function run_silent() {
    local cmd="$*"
    echo " -> $cmd"
    eval ${cmd} 1>/dev/null 2>/dev/null
}

function run_hide() {
    local cmd="$*"
    eval ${cmd} 1>/dev/null 2>/dev/null
}
