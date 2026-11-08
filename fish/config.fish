# @fish-lsp-disable 2002
if status is-interactive

end
# Emulates vim's cursor shape behavior
# Set the normal and visual mode cursors to a block
set fish_cursor_default block
# Set the insert mode cursor to a line
set fish_cursor_insert line
# Set the replace mode cursor to an underscore
set fish_cursor_replace_one underscore
# The following variable can be used to configure cursor shape in
# visual mode, but due to fish_cursor_default, is redundant here
set fish_cursor_visual block

set fzf_fd_opts --hidden --follow --exclude .gi --exclude .git --exclude .svn --exclude .hg --exclude .bzr --exclude _darcs --exclude-dir .DS_Store --exclude-dir .git --exclude-dir .hg --exclude-dir .svn --exclude-dir .bundle --exclude-dir .tox --exclude-dir __pycache__ --exclude-dir node_modules --exclude-dir .next --exclude-dir .nuxt --exclude-dir dist --max-depth 5
set FZF_DEFAULT_OPTS "--preview-window=wrap --no-multi --bind 'tab:down,btab:up,alt-tab:toggle+down,alt-btab:toggle+up' --marker="*" --cycle --layout=reverse --border --height=40%"
source "$HOME/.config/fzf/themes/noctalia.fish"

if not functions -q fzf_configure_bindings
    echo "fzf_configure_bindings not found. Install with command: fisher install patrickf1/fzf.fish"
else
    # https://github.com/patrickf1/fzf.fish
    fzf_configure_bindings --directory=\cf --git_log=\cg --history=\ch --processes=\cpm
    set fzf_diff_highlighter delta --paging=never --width=20
    set fzf_history_time_format %H:%M:%S %d/%m/%y
    set fzf_history_opts --with-nth=4 --no-multi --bind 'tab:down,btab:up'
    set fzf_git_log_opts --no-multi --bind 'tab:down,btab:up'
    set fzf_variables_opts --no-multi --bind 'tab:down,btab:up'
end

fish_add_path -aP ~/bin ~/.local/bin ~/.cargo/bin $GEM_HOME/bin ~/.local/share/neovim/bin /usr/local/go/bin ~/android_root/platform-tools /usr/include/vapoursynth ~/go/bin ~/.cache/.bun/bin ~/.dotnet/tools

# ASDF configuration code
if set -q ASDF_DATA_DIR
    fish_add_path -p "$ASDF_DATA_DIR/shims"
else
    fish_add_path -p "$HOME/.asdf/shims"
end

if not type -q safe-rm
    echo "safe-rm not found. Install through package manager!"
else
    set SAFE_RM_OPTIONS_ANYWHERE yes
    alias rm='safe-rm'
end

if type -q nvim
    set EDITOR nvim
    set VISUAL nvim
else
    set EDITOR vim
    set VISUAL vim
end
set COLORTERM truecolor
set TMPDIR /tmp
set fish_greeting
# if test -f ~/.ssh/cf_llm
#     source ~/.ssh/cf_llm
# end
if set -q KITTY_WINDOW_ID
    alias ssh="kitten ssh"
end
if set -q WEZTERM_PANE
    alias ssh="wezterm ssh"
end
alias sudo="sudo -E -s"

if test -x /usr/local/bin/advcp
    # https://github.com/jarun/advcpmv
    alias cp='/usr/local/bin/advcp -g'
    alias mv='/usr/local/bin/advmv -g'
end

alias ll='ls -alFh'
alias la='ls -Ah'
alias l='ls -CFh'

fish_vi_key_bindings
bind yy fish_clipboard_copy
bind p fish_clipboard_paste

if type -q thefuck
    thefuck --alias | source
end
if type -q starship
    starship init fish | source
end
if type -q zoxide
    zoxide init fish | source
end
export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
set SSH_AUTH_SOCK $(gpgconf --list-dirs agent-ssh-socket)
