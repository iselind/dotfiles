autoload -Uz promptinit
promptinit
PROMPT='%m %(?,,[FAIL] )%1~ %# '

# Use vim keybindings
bindkey -v

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
#HISTFILE=~/.zsh_history

# Use modern completion system
fpath=($fpath ~/.zsh/completion)
autoload -U compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

alias killvpn='/usr/local/pulse/pulsesvc -K'
alias ls='ls -F'
alias with_proxy='http_proxy=http://wwwproxy.se.axis.com:3128 https_proxy=http://wwwproxy.se.axis.com:3128'
alias tsse="rdesktop -k sv -g 1152x864 tsse02 -d axis.com > /dev/null 2>&1 &"
alias bt_battery="bluetooth_battery 34:75:63:DA:AA:C5"
alias gomvpkg="GO111MODULE=off gomvpkg"

# Program helper functions

# Function used to "hard reset" networking when Pulse Secure messes up.
pulse_hard_reset() {
    echo "Making a hard reset of routing table and the Pulse Secure service"
    /usr/local/pulse/pulsesvc -K
    killall -9 pulsesvc 2>/dev/null
    sudo ip route flush table main
    sudo service network-manager restart
}

export PYSPARK_PYTHON=python3
export PYSPARK_DRIVER_PYTHON=${PYSPARK_PYTHON}
export LESS=dMQifR
export LESSCHARSET=utf-8
export PATH=/home/patriki/bin:$PATH
export GOPATH=$HOME/go
export GOROOT=/usr/local/go
export PATH=$(yarn global bin):$HOME/.pipinstall/bin:$GOROOT/bin:$GOPATH/bin:/usr/local/go/bin:$HOME/.local/bin:$PATH
export AWS_PROFILE=idd-dev
export GOFLAGS="-tags=aws"
export GOPRIVATE="*.se.axis.com"

sudo df -lh | grep "vg0-home" | awk '{print "Home is " $5 " full" }'

[ -f /var/run/reboot-required ] && echo "System needs to reboot!"

# Kill the bell
xset -b
