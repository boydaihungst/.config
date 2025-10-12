# .config

## prerequisite

- Using arch based distro (endeavourOS)
- Install i3wm from this setup
  > [i3wm setup](https://github.com/endeavouros-team/endeavouros-i3wm-setup#tutorial-to-install-endeavouros-i3-setup-from-scratch)
- Install packages

```sh
yay -S bat bluetuith-bin kitty kvantum jamesdsp mpd mpv ncmpcpp polybar ranger rofi rofi-greenclip smplayer smplayer-skins picom-git starship glow betterlockscreen xidlehook playerctl light scrot autotiling wmfocus xclip
# Optional
yay -S ibus ibus-bamboo fish calibre
```

## Installation

### Copy to ~/.config/ folder

```sh
git clone https://github.com/boydaihungst/.config
cd .config && cp -r ./* ~/.config/
cat ./home/.profile >> ~/.profile
cp ./home/.Xresources / ~/
cp ./home/.gtkrc-2.0 / ~/
```

```sh
# Change hostname (HOSTNAME) to whatever you want. eg: `/home/userA`-> HOSTNAME is `userA`
find ./ -type f -exec sed -i 's/huyhoang/HOSTNAME/g' {} \;

# Install font + application icons
mkdir -p ~/.local/share/fonts/
cp -r ./.local/share/fonts/* ~/.local/share/fonts/

mkdir -p ~/.local/share/applications/
cp -r ./.local/share/applications/* ~/.local/share/applications/

# Install theme
cp -r ./.themes ~/
cp -r ./.icons ~/

# Install firefox theme
https://addons.mozilla.org/en/firefox/addon/norddark-mrhereandthere/

# Set default shell to fish (Optional)
chsh -s $(which fish)

```

### Install neovim 0.9.0+ and lvim

```sh
# Neovim version manager (optional)
yay -S bob

# Install neovim nightly and use
bob install statble && bob use statble

# Install lvim
LV_BRANCH='release-1.3/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.3/neovim-0.9/utils/installer/install.sh)

# Copy config
cp -r ./lvim ~/.config/

# Open lvim and run:
:Lazy restore
:LvimSyncCorePlugins

# After all plugins installed, run:
:TSInstall all
```

## Gallery

Firefox
![image](https://user-images.githubusercontent.com/38396158/218135398-19652200-a4e2-4978-a341-de2434465b55.png)
Ranger
![image](https://user-images.githubusercontent.com/38396158/218135484-d4252b81-740c-4432-9914-1ea7bc4059c9.png)
Btop
![image](https://user-images.githubusercontent.com/38396158/218136687-bc60d830-c5c8-475f-be06-0bbeeade0dbd.png)
Kitty
![image](https://user-images.githubusercontent.com/38396158/218136811-1bb524c3-72ae-47bc-acd9-5fb24c3ac3e2.png)
Lvim
![image](https://user-images.githubusercontent.com/38396158/218137035-4c14d5e9-20b2-40b4-95ad-85972255fc40.png)
Ncmpcpp
![image](https://user-images.githubusercontent.com/38396158/218137589-6e72de3f-f5ac-4f78-bc2d-86897f4d3cea.png)
Calibre E-book viewer
![image](https://user-images.githubusercontent.com/38396158/218137735-9ca29fa4-6c24-4644-9220-cc520882a106.png)
Smplayer
![image](https://user-images.githubusercontent.com/38396158/218137951-253dc956-b726-4c91-a42d-67c46c90fd3c.png)
