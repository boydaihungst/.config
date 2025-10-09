#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc
[[ -f ~/.profile ]] && . ~/.profile
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
# Load git completion
# [[ -f ~/.git-completion.bash ]] && . ~/.git-completion.bash
# Load git aliases
# [[ -f ~/.git-aliases.bash ]] && . ~/.git-aliases.bash
