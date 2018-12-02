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

# Handling packages
Here are example commands on how to manage the plugins
## Adding a package
```bash
git submodule add https://github.com/vim-airline/vim-airline.git vim/pack/shapeshed/start/vim-airline
git add .gitmodules vim/pack/shapeshed/start/vim-airline
git commit
```
## Updating package
```bash
git submodule update --remote --merge
git commit
```
## Removing package
```bash
git submodule deinit vim/pack/shapeshed/start/vim-airline
git rm vim/pack/shapeshed/start/vim-airline
rm -Rf .git/modules/vim/pack/shapeshed/start/vim-airline
git commit
```
