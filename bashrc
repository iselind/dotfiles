# Only run for interactive bash shells
if [[ $- != *i* ]]; then
	return 0 2>/dev/null || exit 0
fi

# Prompt: show host, working dir, and mark failed last command
PS1='$(if [ $? -ne 0 ]; then echo "[FAIL] "; fi)\h:\w\$ '

# Use vim keybindings (like `bindkey -v` in zsh)
set -o vi

# History
HISTSIZE=1000
HISTFILESIZE=1000
HISTFILE=~/.bash_history

# Enable system bash completions if available
if [ -f /etc/bash_completion ]; then
	# shellcheck disable=SC1091
	. /etc/bash_completion
fi

# Terminfo / LS colors
eval "$(dircolors -b)"

# Aliases
alias killvpn='/usr/local/pulse/pulsesvc -K'
alias ls='ls -F'
alias with_proxy='http_proxy=http://wwwproxy.se.axis.com:3128 https_proxy=http://wwwproxy.se.axis.com:3128'
alias tsse="rdesktop -k sv -g 1152x864 tsse02 -d axis.com > /dev/null 2>&1 &"
alias bt_battery="bluetooth_battery 34:75:63:DA:AA:C5"
alias gomvpkg="GO111MODULE=off gomvpkg"

# Functions
pulse_hard_reset() {
	echo "Making a hard reset of routing table and the Pulse Secure service"
	/usr/local/pulse/pulsesvc -K
	killall -9 pulsesvc 2>/dev/null
	sudo ip route flush table main
	sudo service network-manager restart
}

# Environment
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

# Notices
sudo df -lh | grep "vg0-home" | awk '{print "Home is " $5 " full" }'
[ -f /var/run/reboot-required ] && echo "System needs to reboot!"

# Kill the bell
xset -b

# ripgrep->fzf->vim helper (adapted)
rfv() {
	RELOAD='reload:rg --column --color=always --smart-case {q} || :'
	OPENER='if [[ $FZF_SELECT_COUNT -eq 0 ]]; then
						vim {1} +{2}
					else
						vim +cw -q {+f}
					fi'
	fzf --disabled --ansi --multi \
			--bind "start:$RELOAD" --bind "change:$RELOAD" \
			--bind "enter:become:$OPENER" \
			--bind "ctrl-o:execute:$OPENER" \
			--bind 'alt-a:select-all,alt-d:deselect-all,ctrl-/:toggle-preview' \
			--delimiter : \
			--preview 'batcat --style=full --color=always --highlight-line {2} {1}' \
			--preview-window '~4,+{2}+4/3,<80(up)' \
			--query "$*"
}
