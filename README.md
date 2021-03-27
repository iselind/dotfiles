# dotfiles
My dotfiles

To clone with all the submodules, do
```bash
git clone --recurse-submodules https://github.com/iselind/dotfiles
```

To install the configuration files, run
``` bash
ln -s ${PWD}/vim ~/.vim
ln -s ${PWD}/screenrc ~/.screenrc
ln -s ${PWD}/zshrc ~/.zshrc

mkdir -p ~/.config
ln -s ${PWD}/i3 ~/.config/i3
```
