#/bin/bash

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
#brew tap ./Brewfile_pkg.list
#brew install wget
#wget https://github.com/3t0n/LayoutSwitcher/releases/download/v.1.3.0/LayoutSwitcher.dmg
#hdiutil mount LayoutSwitcher.dmg
#sudo cp -R "/Volumes/LayoutSwitcher/LayoutSwitcher.app" /Applications 
#hdiutil unmount /Volumes/LayoutSwitcher 
sudo su $CURRENT_USER -c "defaults write -g AppleLanguages -array en ru "
defaults write com.apple.HIToolbox AppleEnabledInputSources -array '<dict><key>InputSourceKind</key><string>Keyboard Layout</string><key>KeyboardLayout ID</key><integer>0</integer><key>KeyboardLayout Name</key><string>U.S.</string></dict>' '<dict><key>InputSourceKind</key><string>Keyboard Layout</string><key>KeyboardLayout ID</key><integer>19458</integer><key>KeyboardLayout Name</key><string>RussianWin</string></dict>'

brew install python ansible

brew install stats
brew install telegram zoom
brew install utm

brew tap homebrew/cask-versions
brew install google-chrome-beta
brew tap homebrew/cask-versions && brew install --cask google-chrome-canary

#brew install jandedobbeleer/oh-my-posh/oh-my-posh
#brew install iterm2
#brew tap homebrew/cask-fonts     
#brew install font-anonymice-nerd-font
#echo eval "$(oh-my-posh init zsh)" >> ~/.zshrc
#brew tap lotyp/homebrew-formulae
brew install --cask maccy

brew install lotyp/formulae/dockutil
dockutil --remove all
brew install remote-desktop-manager-free  
#brew install --cask microsoft-remote-desktop
#brew install --cask parallels-client
#brew install chromium
#xattr -cr /Applications/Chromium.app
#defaults delete com.apple.dock persistent-apps; killall Dock
#brew leaast > brew.txt

#unload music app
launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist
