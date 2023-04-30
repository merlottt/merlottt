#/bin/bash

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew tap ./Brewfile_pkg.list
wget https://github.com/3t0n/LayoutSwitcher/releases/download/v.1.3.0/LayoutSwitcher.dmg
brew install python ansible
brew install jandedobbeleer/oh-my-posh/oh-my-posh
brew install iterm2
brew tap homebrew/cask-fonts     
brew install font-anonymice-nerd-font
echo eval "$(oh-my-posh init zsh)" >> ~/.zshrc

brew leaast > brew.txt

