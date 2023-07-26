#/bin/bash

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew tap ./Brewfile_pkg.list
brew install wget
wget https://github.com/3t0n/LayoutSwitcher/releases/download/v.1.3.0/LayoutSwitcher.dmg
hdiutil mount LayoutSwitcher.dmg
sudo cp -R "/Volumes/LayoutSwitcher/LayoutSwitcher.app" /Applications 
hdiutil unmount /Volumes/LayoutSwitcher 
brew install python ansible
brew install jandedobbeleer/oh-my-posh/oh-my-posh
brew install iterm2
brew tap homebrew/cask-fonts     
brew install font-anonymice-nerd-font
brew install stats
echo eval "$(oh-my-posh init zsh)" >> ~/.zshrc
defaults delete com.apple.dock persistent-apps; killall Dock

brew leaast > brew.txt

