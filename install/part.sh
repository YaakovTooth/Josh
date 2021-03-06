#!/bin/sh
#
#  (curl -fsSL https://goo.gl/1MBc9t | sh) && exec zsh
#  (wget -qO - https://goo.gl/1MBc9t | sh) && exec zsh
# (fetch -qo - https://goo.gl/1MBc9t | sh) && exec zsh
#

ZSH="~/.josh"
ZSH=`sh -c "echo $ZSH"`
ZSH=`realpath $ZSH`
export ZSH="$ZSH"

JOSH="$ZSH/custom/plugins/josh"
export JOSH="$JOSH"

echo " * josh directory: $JOSH"

CURRENT_DATE=`date "+%Y%m%d_%H%M%S"`
CUSTOM_PLUGINS_DIR=$ZSH/custom/plugins

HOME_DIR="~"
HOME_DIR=`sh -c "echo $HOME_DIR"`
HOME_DIR=`realpath $HOME_DIR`

BACKUP_JOSH_DIR="$ZSH-$CURRENT_DATE"
BACKUP_RC_FILE="$HOME_DIR/.zshrc-$CURRENT_DATE"
GREP_IGNORE_FILE="$HOME_DIR/.ignore"
LOCAL_BIN_DIR="$HOME_DIR/.local/bin"


# select content fetcher
if [ -n "$READ_URI" ]; then
    echo " * using: $READ_URI"

elif [ `which curl` ]; then
    READ_URI="`which curl` -fsSL"
    echo " * using curl: $READ_URI"

elif [ `which wget` ]; then
    READ_URI="`which wget` -qO -"
    echo " * using wget: $READ_URI"

elif [ `which fetch` ]; then
    READ_URI="`which fetch` -qo - "
    echo " * using fetch: $READ_URI"

else
    echo ' - please, install curl or wget :-\'
fi

if [ `which git` ]; then
    echo " * using git: `which git`"
    if [ -n "$VERBOSE" ]; then
        GIT_CLONE="`which git` clone --depth 1"
    else
        GIT_CLONE="`which git` clone --quiet --depth 1"
    fi
else
    echo ' - git must be installed! :-\'
    return 1
fi

if [ -f ~/.zshrc ]; then
    echo " + exists zshrc, backup: $BACKUP_RC_FILE"
    cp -L ~/.zshrc $BACKUP_RC_FILE
    if [ $? -gt 0 ]; then
        echo ' - backup failed!'
        return 1
    fi
    rm ~/.zshrc
fi

if [ -d $ZSH ]; then
    echo " + exists josh, backup: $BACKUP_JOSH_DIR"
    mv $ZSH $BACKUP_JOSH_DIR
fi

if [ -d $JOSH ]; then
    rm -rf $JOSH
fi

echo " + deploy oh-my-zsh: $ZSH"
($READ_URI 'https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh' | sed 's/^ *chsh/#/g' | sh)
if [ $? -gt 0 ]; then
    echo ' - failed oh-my-zsh!'
    return 1
fi

mkdir -p $JOSH
echo " + deploy josh: $JOSH"
$GIT_CLONE https://github.com/YaakovTooth/Josh.git $JOSH
if [ $? -gt 0 ]; then
    echo ' - failed josh!'
    return 1
fi

echo " + third-party extensions: $CUSTOM_PLUGINS_DIR"
(
    $GIT_CLONE https://github.com/chrissicool/zsh-256color $CUSTOM_PLUGINS_DIR/zsh-256color && \
    $GIT_CLONE https://github.com/djui/alias-tips.git $CUSTOM_PLUGINS_DIR/alias-tips && \
    $GIT_CLONE https://github.com/felixgravila/zsh-abbr-path.git $CUSTOM_PLUGINS_DIR/zsh-abbr-path && \
    $GIT_CLONE https://github.com/horosgrisa/mysql-colorize $CUSTOM_PLUGINS_DIR/mysql-colorize && \
    $GIT_CLONE https://github.com/mafredri/zsh-async.git $CUSTOM_PLUGINS_DIR/zsh-async && \
    $GIT_CLONE https://github.com/supercrabtree/k $CUSTOM_PLUGINS_DIR/k && \
    $GIT_CLONE https://github.com/TamCore/autoupdate-oh-my-zsh-plugins $CUSTOM_PLUGINS_DIR/autoupdate && \
    $GIT_CLONE https://github.com/zsh-users/zsh-syntax-highlighting.git $CUSTOM_PLUGINS_DIR/zsh-syntax-highlighting && \
    $GIT_CLONE https://github.com/trapd00r/zsh-syntax-highlighting-filetypes.git $CUSTOM_PLUGINS_DIR/zsh-syntax-highlighting-filetypes && \
    $GIT_CLONE https://github.com/seletskiy/zsh-fuzzy-search-and-edit.git $CUSTOM_PLUGINS_DIR/zsh-fuzzy-search-and-edit && \
    # $GIT_CLONE https://github.com/zdharma/fast-syntax-highlighting.git $CUSTOM_PLUGINS_DIR/fast-syntax-highlighting && \
    $GIT_CLONE https://github.com/zdharma/history-search-multi-word.git $CUSTOM_PLUGINS_DIR/history-search-multi-word && \
    $GIT_CLONE https://github.com/zlsun/solarized-man.git $CUSTOM_PLUGINS_DIR/solarized-man && \
    $GIT_CLONE https://github.com/zsh-users/zsh-autosuggestions $CUSTOM_PLUGINS_DIR/zsh-autosuggestions && \
    $GIT_CLONE https://github.com/zsh-users/zsh-completions $CUSTOM_PLUGINS_DIR/zsh-completions && \
    $GIT_CLONE https://github.com/mollifier/anyframe.git $CUSTOM_PLUGINS_DIR/anyframe && \
    $GIT_CLONE https://github.com/so-fancy/diff-so-fancy.git $CUSTOM_PLUGINS_DIR/diff-so-fancy && \
    $GIT_CLONE https://github.com/b4b4r07/emoji-cli $CUSTOM_PLUGINS_DIR/emoji-cli && \
    $GIT_CLONE https://github.com/wfxr/forgit.git $CUSTOM_PLUGINS_DIR/forgit && \
    $GIT_CLONE https://github.com/hlissner/zsh-autopair.git $CUSTOM_PLUGINS_DIR/zsh-autopair && \
    $GIT_CLONE https://github.com/leophys/zsh-plugin-fzf-finder.git $CUSTOM_PLUGINS_DIR/zsh-plugin-fzf-finder && \
    $GIT_CLONE --recursive https://github.com/joel-porquet/zsh-dircolors-solarized.git $CUSTOM_PLUGINS_DIR/zsh-dircolors-solarized
)
if [ $? -gt 0 ]; then
    echo ' - failed extensions!'
    return 1
fi

if [ `which fzf` ]; then
    echo " * using fzf: `which fzf`"
else
    echo " + deploy fzf: $LOCAL_BIN_DIR/fzf"
    if [ ! -d $LOCAL_BIN_DIR ]; then
        mkdir -p $LOCAL_BIN_DIR
    else
        if [ -f $LOCAL_BIN_DIR/fzf ]; then
            rm $LOCAL_BIN_DIR/fzf
        fi
    fi

    tempdir=`mktemp -d`
    rm -rf $tempdir
    $GIT_CLONE https://github.com/junegunn/fzf.git $tempdir && $tempdir/install --completion --key-bindings --update-rc --bin && cp -f $tempdir/bin/fzf $LOCAL_BIN_DIR/fzf && rm -rf $tempdir
    if [ $? -gt 0 ]; then
        echo " + failed fzf: $LOCAL_BIN_DIR/fzf"
    fi

    $READ_URI https://beyondgrep.com/ack-v3.4.0 > ~/$LOCAL_BIN_DIR/ack && chmod 750 ~/$LOCAL_BIN_DIR/*
    if [ $? -gt 0 ]; then
        echo " + failed ack: $LOCAL_BIN_DIR/ack"
    fi
fi

if [ -e ~/.zshrc ]; then
    echo ' + create links: ~/.zshrc, etc'
    rm ~/.zshrc
fi

ln -s $JOSH/.zshrc ~/.zshrc && ln -s ../plugins/josh/themes/josh.zsh-theme $ZSH/custom/themes/josh.zsh-theme
if [ $? -gt 0 ]; then
    echo ' - failed links!'
    return 1
fi

git config --global color.ui auto
git config --global color.branch auto
git config --global color.diff auto
git config --global color.interactive auto
git config --global color.status auto
git config --global color.grep auto
git config --global color.pager true
git config --global color.decorate auto
git config --global color.showbranch auto
if [ -n "$(uname | grep -i freebsd)" ]; then
    git config --global core.pager "delta --commit-style plain --file-style plain --hunk-style plain --highlight-removed"
else
    git config --global core.pager "delta --commit-style='yellow ul' --commit-decoration-style='' --file-style='cyan ul' --file-decoration-style='' --hunk-style normal --zero-style='dim syntax' --24-bit-color='always' --minus-style='syntax #330000' --plus-style='syntax #002200' --file-modified-label='M' --file-removed-label='D' --file-added-label='A' --file-renamed-label='R' --line-numbers-left-format='{nm:^4}' --line-numbers-minus-style='#aa2222' --line-numbers-zero-style='#505055' --line-numbers-plus-style='#229922' --line-numbers --navigate"
fi

if [ $BACKUP_JOSH_DIR ]; then
    if [ -d $BACKUP_JOSH_DIR ]; then
        echo " * backup removed: $BACKUP_JOSH_DIR"
        rm -rf $BACKUP_JOSH_DIR
    fi
fi

if [ -f "$HOME_DIR/.nanorc" ]; then
    # https://github.com/scopatz/nanorc
    echo " * nano config: $HOME_DIR/.nanorc"
else
    if [ -n "$(uname | grep -i freebsd)" ]; then
        if [ -d /usr/local/share/nano/ ]; then
            find /usr/local/share/nano/ -iname "*.nanorc" -exec echo include {} \; >> $HOME_DIR/.nanorc
            echo " + nano config: $HOME_DIR/.nanorc"
        fi
    elif [ -n "$(uname | grep -i linux)" ]; then
        if [ -d /usr/share/nano/ ]; then
            find /usr/share/nano/ -iname "*.nanorc" -exec echo include {} \; >> $HOME_DIR/.nanorc
            echo " + nano config: $HOME_DIR/.nanorc"
        fi
    fi
fi

if [ -f "$GREP_IGNORE_FILE" ]; then
    echo " * grep config: $GREP_IGNORE_FILE"
else
    echo '*.js' >> $GREP_IGNORE_FILE
    echo '*.min.css' >> $GREP_IGNORE_FILE
    echo '*.po' >> $GREP_IGNORE_FILE
    echo '*.pyc' >> $GREP_IGNORE_FILE
    echo '*.svg' >> $GREP_IGNORE_FILE
    echo '.eggs/' >> $GREP_IGNORE_FILE
    echo '.git/' >> $GREP_IGNORE_FILE
    echo '__snapshots__/' >> $GREP_IGNORE_FILE
    echo 'lib/python*/site-packages/' >> $GREP_IGNORE_FILE
    echo 'node_modules/' >> $GREP_IGNORE_FILE
    echo " + nano config: $GREP_IGNORE_FILE"
fi

cd ~
echo ' + oh my josh!'
