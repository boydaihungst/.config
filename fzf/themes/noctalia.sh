fzf_theme_opts="\
--color=bg+:#000000
--color=bg:#000000
--color=spinner:#e9f2fd
--color=hl:#ff9290
--color=fg:#e9f2fd
--color=header:#ff9290
--color=info:#ffe0cd
--color=pointer:#e9f2fd
--color=marker:#e9f2fd
--color=fg+:#e9f2fd
--color=prompt:#ffe0cd
--color=hl+:#ff9290
--color=selected-bg:#000000
--color=border:#00223f
--color=label:#e9f2fd"

export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:+$FZF_DEFAULT_OPTS
}$fzf_theme_opts"
