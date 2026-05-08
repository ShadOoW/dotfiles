# Java — only on Linux
[[ "$(uname)" == "Linux" ]] && export JAVA_HOME=/usr/lib/jvm/java-26-openjdk

export ATUIN_NOBIND='true'

[ -f "$HOME/.deno/env" ] && . "$HOME/.deno/env"
