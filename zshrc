
autoload -Uz promptinit
promptinit
PROMPT='%(?,,[FAIL] )%1~ %# '

# Use vim keybindings
bindkey -v

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
#HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
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

fpath=(~/.zsh/completion $fpath)

alias iu='iputility eth0'
alias wiu='watch -n10 "iputility eth0 | sort"'
alias ls='ls -F'
alias proxy='http_proxy=http://wwwproxy.se.axis.com:3128 https_proxy=http://wwwproxy.se.axis.com:3128'
alias tsse="rdesktop -k sv -g 1152x864 tsse02 -d axis.com > /dev/null 2>&1 &"
alias patch="patch -N --ignore-whitespace"
alias pylint="pylint -r n"
alias t32="op proot /usr/local/t32/bin/pc_linux64/t32mips-qt &"
alias docker="op proot adocker"
alias vim='proxy /usr/bin/vim'
alias docker-jessie="adocker chroot artifacts.se.axis.com/axis/debian-axis-dev:jessie -v /n/axis_releases/oe:/home/patriki/oe -v /n/oe:/n/oe -p 5342-5344:5342-5344/tcp -e DISPLAY=$DISPLAY"
alias docker-jenkins-wheezy="adocker chroot artifacts.se.axis.com/axis/debian-jenkins-slave:wheezy -v /n/oe:/n/oe -e DISPLAY=$DISPLAY"
alias docker-jenkins-jessie="adocker chroot artifacts.se.axis.com/axis/debian-jenkins-slave:jessie -v /n/oe:/n/oe -e DISPLAY=$DISPLAY"
alias docker-wheezy="adocker chroot artifacts.se.axis.com/axis/debian-axis-dev:wheezy -e DISPLAY=$DISPLAY"
alias kubectl="http_proxy=http://wwwproxy.se.axis.com:3128 https_proxy=http://wwwproxy.se.axis.com:3128 $HOME/projekt/aws/environment/compiled_deploy/_deploytools/kubectl"

prepare_jenkins() {
    source /n/gerrit/jenkins/jenkins.sh
}

# Some helper functions
source /home/patriki/vapix_lib/streaming.sh
source /home/patriki/vapix_lib/aux.sh
source /home/patriki/vapix_lib/cam-control.sh

# Program helper functions

nmap() {
    /usr/bin/nmap `fixip $1`
}

telnet() {
    /usr/bin/telnet `fixip $1`
}

myssh() {
    ip=`fixip $1`
    enable_ssh $1
    sleep 1
    /usr/bin/ssh "root@$ip"
}

ftp() {
    ip=`fixip $1`
    /usr/bin/ftp "ftp://root:pass@$ip"
}

# Nice to have functions

get_unit_repo() {
    if [ -z "$1" ]
    then
        echo "Missing parameter"
        return 1
    fi
    reponame="$1"
    if [ -d "$reponame" ]
    then
        echo "The folder '$reponame' already exist"
    else
        git clone "ssh://patriki@gittools.se.axis.com:29418/products-camera-$1"

    fi
}

flash() {
   file_for_flash="fimage"
   echo "$# arguments passed"
   if [ $# -gt 1 ]
   then
       file_for_flash=$2
   else
       file_for_flash=$(find_fimage)
   fi

   if [ $(echo $file_for_flash | wc -l) -ne 1 ] || [ "$file_for_flash" = "" ]
   then
       # Found more than one potential, or none
       echo "Please specify the fimage file"
       return 1
   fi

   echo "Flashing $file_for_flash..."
   sleep 5
   echo

   wait_for_unit $1

   curl --proxy "" -F"file=@$file_for_flash" -F"uploadFile=Upgrade" -u root:pass --anyauth "http://192.168.0.$1/axis-cgi/firmwareupgrade.cgi?type=factorydefault"
   sleep 10
   wait_for_unit $1
}

# Unit control functions

send_onvif() {
    ip=`fixip $1`
    curl --noproxy \* -X POST -d @"$2" "http://root:pass@$ip/onvif/device_service" --header "Content-Type:text/xml" | xmllint --format -
}

send_onvif_digest() {
    ip=`fixip $1`
    curl --digest --noproxy \* -X POST -d @"$2" "http://root:pass@$ip/onvif/device_service" --header "Content-Type:text/xml" | xmllint --format -
}

send_onvif_anyauth() {
    ip=`fixip $1`
    curl --anyauth --noproxy \* -X POST -d @"$2" "http://root:pass@$ip/onvif/device_service" --header "Content-Type:text/xml" | xmllint --format -
}

get_syslog() {
    ip=`fixip $1`
    wget --no-proxy -O /dev/stdout "http://root:pass@$ip/axis-cgi/admin/systemlog.cgi"
}

build_acap-4() {
    ip=`fixip $1`
    create-package.sh artpec-4 && eap-install.sh "$ip" pass remove && eap-install.sh "$ip" pass install && eap-install.sh "$ip" pass start
}

fix_touch() {
    xinput set-prop 8 274 0 65534 0 36000
}

rebuild() {
    make -C "$1" clean && make -C "$1" install
}

# Set Standby, suspend, and off for display to 20 minutes
xset dpms 1200 1200 1200

export T32SYS=/usr/local/t32
export T32TMP=$HOME/.t32_tmp
export T32ID=T32
export LESS=dMqifR
export LESSCHARSET=utf-8
export PATH=/home/patriki/bin:$PATH
export GOPATH=$HOME/go
export GOROOT=/usr/local/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin:/usr/local/go/bin:/usr/local/node-v6.10.3-linux-x64/bin:/home/patriki/.local/bin:$HOME/projekt/aws/environment/compiled_deploy/_deploytools
#export PATH=/usr/local/opt/Python-3.5.2/bin:$PATH
op proot df -h | grep "vg0-home" | awk '{print "Home is " $5 " full" }'

if [ $commands[kubectl] ]; then
    source <(kubectl completion zsh)
fi

. ~/projekt/aws/environment/aws-account.sh

[ -f /var/run/reboot-required ] && echo "System needs to reboot!"
cd ~
