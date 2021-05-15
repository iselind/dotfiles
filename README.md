# dotfiles
My dotfiles

To install the configuration files, run
``` bash
ln -s ${PWD}/vim ~/.vim
ln -s ${PWD}/screenrc ~/.screenrc
ln -s ${PWD}/zshrc ~/.zshrc

mkdir -p ~/.config
ln -s ${PWD}/i3 ~/.config/i3
```

To initialize the Vim plugins execute `:PlugInstall` within Vim.
