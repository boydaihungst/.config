# @fish-lsp-disable 2002
if status is-interactive

    if not functions -q set_onedark
        echo "onedark theme not found. Install with command: fisher install rkbk60/onedark-fish"
    else
        set -l onedark_options -b

        if set -q VIM
            # Using from vim/neovim.
            set onedark_options -256
            # else if test -n "$SSH_TTY"
            #     # function fish_title
            #     #     echo (whoami)@(hostname)":"(basename (pwd))" - "(status current-command)
            #     # end
            #     # Using from emacs.
            #     set onedark_options -256
        end
        set_onedark_color black 080A0E current
        set_onedark_color white BCC4C9 current
        set_onedark_color red A24F5F current
        set_onedark_color green 98c379 current
        set_onedark_color blue 597A9A current
        set_onedark $onedark_options # Commands to run in interactive sessions can go here
    end
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
set FZF_DEFAULT_OPTS "--preview-window=wrap --no-multi --bind 'tab:down,btab:up,alt-tab:toggle+down,alt-btab:toggle+up' --marker="*" --cycle --layout=reverse --border --height=40% --color 'bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8,fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc,marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#8EBD6B'"

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

if not type -q safe-rm
    echo "safe-rm not found. Install through package manager!"
end
fish_add_path -p /usr/lib/safe-rm
fish_add_path -aP ~/bin ~/.local/bin ~/.cargo/bin $GEM_HOME/bin ~/.local/share/neovim/bin /usr/local/go/bin ~/android_root/platform-tools /usr/include/vapoursynth ~/go/bin

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
if test -f ~/.ssh/cf_llm
    source ~/.ssh/cf_llm
end
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

fish_vi_key_bindings
bind yy fish_clipboard_copy
bind p fish_clipboard_paste

# ASDF configuration code
if set -q ASDF_DATA_DIR
    set _asdf_shims "$ASDF_DATA_DIR/shims"
else
    set _asdf_shims "$HOME/.asdf/shims"
end

# Do not use fish_add_path (added in Fish 3.2) because it
# potentially changes the order of items in PATH
if not contains $_asdf_shims $PATH
    set -gx --prepend PATH $_asdf_shims
end
set --erase _asdf_shims
if type -q thefuck
    thefuck --alias | source
end
if type -q starship
    starship init fish | source
end
if type -q zoxide
    zoxide init fish | source
end
