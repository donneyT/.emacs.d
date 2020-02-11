# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

export PATH=/usr/local/bin:$PATH
export PATH=/usr/local/openresty/nginx/sbin:$PATH


alias ll="ls -hG -al"
alias grep='grep --color=auto'
alias mcd='_mcd(){ mkdir -p "$1"; cd "$1"; };_mcd'
alias cll='_cll(){ cd "$1"; ll; };_cll'
alias backup='_backup(){ cp "$1"{,.bak}; };_backup'
alias md5check='_md5check(){ md5sum "$1" | grep "$2"; };_md5check'
alias makescript="fc -rnl | head -1 >"
alias genpasswd="strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 30 | tr -d '\n'; echo"
alias histg="history | grep"
alias ..='cd ..'
alias ...='cd ../..'

#System info
alias cmount="mount | column -t"
alias tree="ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'"
sbs(){ du -b --max-depth 1 | sort -nr | perl -pe 's{([0-9]+)}{sprintf "%.1f%s", $1>=2**30? ($1/2**30, "G"): $1>=2**20? ($1/2**20, "M"): $1>=2**10? ($1/2**10, "K"): ($1, "")}e';}
alias intercept="sudo strace -ff -e trace=write -e write=1,2 -p"
alias meminfo='free -m -l -t'
alias psgrep="ps aux | grep"
alias ps?="pgrep"

#Network
alias listen="lsof -P -i -n"
alias port='_port(){ lsof -nP -iTCP:"$1" -sTCP:LISTEN; };_port'
alias ipinfo="curl ifconfig.me"

#Other
function file_exist() {
    if [ ! $# -gt 0 ]; then
        echo "usage [need filename]"
        return
    fi
    if [ -e ${filename} ];then
        echo "$1 文件存在"
    else
        echo  "$1 文件不存在"
    fi
}


function extract() {

    if [ -f $1 ] ; then

        case $1 in

            *.tar.bz2)   tar xjf $1     ;;

            *.tar.gz)    tar xzf $1     ;;

            *.bz2)       bunzip2 $1     ;;

            *.rar)       unrar e $1     ;;

            *.gz)        gunzip $1      ;;

            *.tar)       tar xf $1      ;;

            *.tbz2)      tar xjf $1     ;;

            *.tgz)       tar xzf $1     ;;

            *.zip)       unzip $1       ;;

            *.Z)         uncompress $1  ;;

            *.7z)        7z x $1        ;;

            *)     echo "'$1' cannot be extracted extract()" ;;

        esac

    else

        echo "'$1' is not a valid file"

    fi
}

[ $(uname -s | grep -c CYGWIN) -eq 1 ] && OS_NAME="CYGWIN" || OS_NAME=`uname -s`
function pclip() {
    if [ $OS_NAME == CYGWIN ]; then
        putclip $@;
    elif [ $OS_NAME == Darwin ]; then
        pbcopy $@;
    elif [ ! $DESKTOP_SESSION ]; then
	return
    else
        if [ -x /usr/bin/xsel ]; then
            xsel -ib $@;
        else
            if [ -x /usr/bin/xclip ]; then
                xclip -selection c $@;
            else
                echo "Neither xsel or xclip is installed!"
            fi
        fi
    fi
}

# search the file and pop up dialog, then put the full path in clipboard
function baseff()
{
    local fullpath=$*
    local filename=${fullpath##*/} # remove "/" from the beginning
    filename=${filename##*./} # remove  ".../" from the beginning
    # Only the filename without path is needed
    # filename should be reasonable
    local cli=`find . -not -iwholename '*/vendor/*' -not -iwholename '*/bower_components/*' -not -iwholename '*/node_modules/*' -not -iwholename '*/target/*' -not -iwholename '*.svn*' -not -iwholename '*.git*' -not -iwholename '*.sass-cache*' -not -iwholename '*.hg*' -type f -path '*'${filename}'*' -print | percol`
    # convert relative path to full path
    echo $(cd $(dirname $cli); pwd)/$(basename $cli)
}

function ff()
{
    local cli=`baseff $*`
    #echo ${cli} | sed 's%^'${HOME}'%~%'
    #echo -n ${cli}  | sed 's%^'${HOME}'%~%' | pclip
    echo ${cli}
    echo -n ${cli} | pclip
}

function cf()
{
    local cli=`baseff $*`
    local p=`cygpath -w $cli`
    echo ${p}
    echo -n ${p} | pclip;
}


function h () {
    # reverse history, pick up one line, remove new line characters and put it into clipboard
    if [ -z "$1" ]; then
        history | sed '1!G;h;$!d' | percol | sed -n 's/^ *[0-9][0-9]* *\(.*\)$/\1/p'| tr -d '\n' | pclip
    else
        history | grep "$1" | sed '1!G;h;$!d' | percol | sed -n 's/^ *[0-9][0-9]* *\(.*\)$/\1/p'| tr -d '\n' | pclip
    fi
}


function ppgrep() {
    if [[ $1 == "" ]]; then
        PERCOL=percol
    else
        PERCOL="percol --query $1"
    fi
    ps aux | eval $PERCOL | awk '{ print $2 }'
}

function ppkill() {
    if [[ $1 =~ ^- ]]; then
        QUERY=""            # options only
    else
        QUERY=$1            # with a query
        [[ $# > 0 ]] && shift
    fi
    ppgrep $QUERY | xargs kill $*
}


