# export MOZ_ENABLE_WAYLAND=1
# export XDG_CURRENT_DESKTOP=sway
# export XDG_SESSION_TYPE=wayland
# export WLR_NO_HARDWARE_CURSORS=1
# export WLR_RENDERER_ALLOW_SOFTWARE=1
# export WLR_DRM_NO_ATOMIC=1
# export ELECTRON_OZONE_PLATFORM_HINT=wayland
export MOZ_USE_XINPUT2=1
# export GDK_DPI_SCALE=1
export GTK_USE_PORTAL=1
export GLFW_IM_MODULE=fcitx
export SDL_IM_MODULE=fcitx
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export QT4_IM_MODULE=fcitx
export CLUTTER_IM_MODULE=fcitx
# export INPUT_METHOD=ibus
# export GDK_DEBUG=portals
export QT_STYLE_OVERRIDE=kvantum
export PATH="/usr/lib/safe-rm:$PATH:$HOME/bin:$HOME/.bun/bin:$HOME/.local/bin:$HOME/.cargo/bin:$GEM_HOME/bin:$HOME/.local/share/neovim/bin:$HOME/.local/share/bob/nvim-bin:$HOME/.pyenv/bin:$HOME/android_root/platform-tools/adb:/opt/cuda/bin:/usr/local/VideoSubFinder:$HOME/.yarn/bin:$HOME/go/bin"
export npm_config_prefix="$HOME/.local"
export JAVA_HOME=/usr/lib/jvm/default
export EDITOR=nvim
export VISUAL=nvim
export TERMINAL=kitty
export TERM=xterm-kitty
export COLORTERM=truecolor
export USE_CCACHE=1
export CCACHE_COMPRESS=1
export CCACHE_MAXSIZE=50G # 50 GB
if [ -f "$HOME"/.ssh/cf_llm ]; then
  source "$HOME"/.ssh/cf_llm
fi
export CUDAToolkit_ROOT=/opt/cuda
