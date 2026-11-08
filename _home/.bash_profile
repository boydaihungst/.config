#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc
[[ -f ~/.profile ]] && . ~/.profile
# if [ -z "${WAYLAND_DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
#   dbus-run-session sway --unsupported-gpu
# fi

# # Load git completion
# [[ -f ~/.git-completion.bash ]] && . ~/.git-completion.bash
# Load git aliases
# [[ -f ~/.git-aliases.bash ]] && . ~/.git-aliases.bash
