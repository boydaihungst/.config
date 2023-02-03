# .config

## Installation
   
  - Copy to ~/.config/ folder
    ```sh
      git clone https://github.com/boydaihungst/.config ~/.config/
    ```
  
  - Change hostname (HOSTNAME) to what ever you want. eg: `/home/userA`-> HOSTNAME is `userA`
    ```sh
      find ./ -type f -exec sed -i 's/huyhoang/HOSTNAME/g' {} \;
    ```
 
   - Rollback packer snapshot
   - Install lvim
      ```sh
         LV_BRANCH='release-1.2/neovim-0.8' bash <(curl -s https://raw.githubusercontent.com/boydaihungst/LunarVim/master/utils/installer/install.sh)
      ```
