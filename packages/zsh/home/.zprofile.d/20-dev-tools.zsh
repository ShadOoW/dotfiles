[[ "$_DISTRO" != "macos" ]] && export JAVA_HOME=/usr/lib/jvm/java-26-openjdk

export ATUIN_NOBIND='true'

[ -f "$HOME/.deno/env" ] && . "$HOME/.deno/env"
