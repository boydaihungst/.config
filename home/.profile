export GLFW_IM_MODULE=ibus
export MOZ_USE_XINPUT2=1
export GDK_DPI_SCALE=1
export GTK_USE_PORTAL=1
export GTK_IM_MODULE=ibus
export QT_IM_MODULE=xim
export XMODIFIERS=@im=xim
export QT4_IM_MODULE=xim
export CLUTTER_IM_MODULE=xim
export GDK_DEBUG=portals
export QT_STYLE_OVERRIDE=kvantum
# export MOZ_DISABLE_RDD_SANDBOX=1
export PATH="$PATH:$HOME/bin:$HOME/.bun/bin:$HOME/.local/bin:$HOME/.cargo/bin:$GEM_HOME/bin:$HOME/.local/share/neovim/bin:$HOME/.local/share/bob/nvim-bin"
export npm_config_prefix="$HOME/.local"
export JAVA_HOME=/usr/lib/jvm/default
# export GEM_HOME="$(ruby -e 'puts Gem.user_dir')"
export EDITOR=lvim
export VISUAL=lvim
export TERMINAL=kitty
export TERM=xterm-kitty
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
export TPM2_PKCS11_TCTI=tabrmd:
export TSS2_LOG=fapi+NONE
export WMFOCUS_OPTS='--textcolor "#cdd6f4" --bgcolor "#1e1e2e" --textcolorcurrent "#f38ba8" --bgcolorcurrent "#1e1e2e" --chars "hlkj"'
export COLORTERM=truecolor
export AVFSBASE=$XDG_RUNTIME_DIR/avfs
export USE_CCACHE=1
export CCACHE_COMPRESS=1
export CCACHE_MAXSIZE=50G # 50 GB
mountavfs
