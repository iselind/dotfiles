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

## DevBox

A Linux environment ready for use on a new system, even a corporate one.

Inside you should expect to find a proper `GNU Screen` configured and `Vim + COC` setup for
- Java
- Python
- Go

### Setup

1. Add the bin folder to `$PATH`
1. Build the devbox image. The initial building of the Docker image will take a couple of minutes.
   ```bash
   ./bin/rebuild-devbox.cmd
   ```
1. Configure your IDEs and Windows Terminal to use `./bin/start-devbox.cmd` to start shells.

### Use cases

#### Start a shell
```bash
./bin/start-devbox.cmd
```

> **NOTE:** This command makes sure that the devbox is started before the shell is opened.

> **NOTE:** The Docker image is NOT rebuilt if the Dockerfile is updated. To do that, use `./bin/rebuild-devbox.cmd`.

#### Tear down the devbox
```bash
./bin/stop-devbox.cmd
```

#### Rebuild the devbox image
```bash
./bin/rebuild-devbox.cmd
```

### The bin-folder

Only holds bat/cmd files as powershell files are usually required to be signed to execute on corporate computers.