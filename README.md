# .config

## prerequisite
     
- Using arch based distro (endeavourOS)
- Install i3wm from this setup
   
   > [i3wm setup](https://github.com/endeavouros-team/endeavouros-i3wm-setup#tutorial-to-install-endeavouros-i3-setup-from-scratch)
- Install packages
```sh
yay -S bat bluetuith-bin kitty kvantum jamesdsp mpd mpv ncmpcpp polybar ranger rofi rofi-greenclip smplayer smplayer-skins picom-git starship glow 
# Optional
yay -S ibus ibus-bamboo fish
```


## Installation
   
- Copy to ~/.config/ folder
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
   
- Install neovim 0.8.0 + lvim
      
      ```sh
         # Neovim version manager (optional)
         yay -S bob 
         # Install neovim 0.8.0 and use 
         bob install 0.8.0 && bob use 0.8.0
         # Install lvim
         LV_BRANCH='release-1.2/neovim-0.8' bash <(curl -s https://raw.githubusercontent.com/boydaihungst/LunarVim/master/utils/installer/install.sh)
      ```
