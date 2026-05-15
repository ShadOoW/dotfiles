for f in "$HOME"/.zshrc.d/*.zsh(N-.); do
  source "$f"
done

# bun completions
[ -s "/home/shad/.bun/_bun" ] && source "/home/shad/.bun/_bun"
