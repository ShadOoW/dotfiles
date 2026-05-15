if [[ -d "$HOME/.config/secrets" ]]; then
  for _sf in "$HOME/.config/secrets/"*(N-.); do
    while IFS= read -r _sl || [[ -n "$_sl" ]]; do
      _sl="${_sl%$'\r'}"
      [[ "$_sl" =~ ^[[:space:]]*$ || "$_sl" =~ ^[[:space:]]*# ]] && continue
      _sk="${_sl%%=*}"
      _sv="${_sl#*=}"
      [[ "$_sk" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] && export "${_sk}"="${_sv}"
    done <"$_sf"
  done
  unset _sf _sl _sk _sv
fi
