function cd_up() {
  BUFFER="cd .."
  zle accept-line
}
function cd_back() {
  BUFFER="cd -"
  zle accept-line
}
function go_home_dir() {
  BUFFER="cd ~"
  zle accept-line
}
function run_ls() {
  BUFFER="ls"
  zle accept-line
}

zle -N cd_up
zle -N cd_back
zle -N go_home_dir
zle -N run_ls

bindkey "^[[5~" cd_up
bindkey "^[[6~" cd_back
bindkey -r '^[[H'
bindkey "^[OH" go_home_dir
bindkey -r '^[[F'
bindkey "^[OF" run_ls

bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word
bindkey "^[Od" backward-word
bindkey "^[Oc" forward-word
