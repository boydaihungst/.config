if status is-interactive

    set -l onedark_options -b

    if set -q VIM
        # Using from vim/neovim.
        set onedark_options -256
    else if test -n "$SSH_TTY"
        # function fish_title
        #     echo (whoami)@(hostname)":"(basename (pwd))" - "(status current-command)
        # end
        # Using from emacs.
        set onedark_options -256
    end
    set_onedark_color black 080A0E current
    set_onedark_color white BCC4C9 current
    set_onedark_color red A24F5F current
    set_onedark_color green 98c379 current
    set_onedark_color blue 597A9A current
    set_onedark $onedark_options # Commands to run in interactive sessions can go here
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

set fzf_fd_opts --hidden
starship init fish | source
set FZF_DEFAULT_OPTS "--preview-window=wrap --marker="*" --cycle --layout=reverse --border --height=40% --color 'bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8,fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc,marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8'"
fzf_configure_bindings --directory=\cf --git_status=\cg --history=\ch --processes=\cp
fish_add_path -p /usr/lib/safe-rm
fish_add_path -aP ~/bin ~/.bun/bin ~/.local/bin ~/.cargo/bin $GEM_HOME/bin ~/.local/share/neovim/bin ~/.local/share/bob/nvim-bin /usr/local/go/bin ~/.pyenv/bin ~/android_root/platform-tools /usr/include/vapoursynth ~/go/bin
set EDITOR nvim
set VISUAL nvim
set COLORTERM truecolor
set TMPDIR /tmp
set fish_greeting
if test -f ~/.ssh/cf_llm
    source ~/.ssh/cf_llm
end

# if not test -f ~/.terminfo/w/wezterm
#     curl https://raw.githubusercontent.com/wez/wezterm/main/termwiz/data/wezterm.terminfo | tic -x -o ~/.terminfo -
# end

alias ssh="kitten ssh"
# alias ssh="wezterm ssh"
alias sudo="sudo -E -s"
fish_vi_key_bindings
bind yy fish_clipboard_copy
bind p fish_clipboard_paste

set -x N_PREFIX "$HOME/n"
contains "$N_PREFIX/bin" $PATH; or set -a PATH "$N_PREFIX/bin" # Added by n-install (see http://git.io/n-install-repo).
zoxide init fish | source

thefuck --alias | source
