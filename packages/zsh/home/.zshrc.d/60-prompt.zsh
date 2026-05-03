autoload -Uz vcs_info
precmd() { vcs_info; }
zstyle ':vcs_info:git:*' formats ' %F{yellow}(%b)%f'
setopt prompt_subst
PROMPT='%B%F{blue}%c%B%F{magenta} %{$reset_color%}% %F{red}❯%F{yellow}❯%F{green}❯%f '
RPROMPT='%B%F{green}${vcs_info_msg_0_}%f'
