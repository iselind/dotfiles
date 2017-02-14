#!/bin/sh

mkdir -p ~/.vim
cd vim
for part in *
do
    target=~/.vim/$part
    rm -rf $target
    ln -s $(pwd)/$part $target
done
cd -

rm -f ~/.vimrc
ln -s $(pwd)/vimrc ~/.vimrc

echo "Installation complete"
