if status is-interactive
    # Commands to run in interactive sessions can go here
end
set fzf_fd_opts --hidden
starship init fish | source
set FZF_DEFAULT_OPTS "--preview-window=wrap --marker="*" --cycle --layout=reverse --border --height=40% --color 'bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8,fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc,marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8'"
set fish_greeting
fish_add_path $(yarn global bin)
fish_add_path ~/.yarn/bin
fish_add_path ~/.config/yarn/global/node_modules/.bin
alias ssh="kitty +kitten ssh"
alias sudo="sudo -E -s"
