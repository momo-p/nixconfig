# imported by both the rofi mode and the sway startup restore, so they share one store path
{
  config,
  pkgs,
}:
pkgs.writeShellScript "cursor-theme" ''
  state=${config.xdg.stateHome}/cursor-theme
  size=${toString config.home.pointerCursor.size}

  apply() {
    ${pkgs.sway}/bin/swaymsg seat '*' xcursor_theme "$1" "$size" >/dev/null
  }

  if [ "$1" = "--restore" ]; then
    [ -r "$state" ] && apply "$(cat "$state")"
    exit 0
  fi

  if [ "$#" -eq 0 ]; then
    printf '\0no-custom\x1ftrue\n'
    dirs="$HOME/.icons"
    for base in $(printf '%s' "$XDG_DATA_DIRS" | tr ':' ' '); do
      dirs="$dirs $base/icons"
    done
    # a theme without a cursors/ subdir is an icon set, not a pointer
    for d in $dirs; do
      for t in "$d"/*/cursors; do
        [ -d "$t" ] || continue
        t=''${t%/cursors}
        printf '%s\n' "''${t##*/}"
      done
    done | sort -u
    exit 0
  fi

  printf '%s\n' "$1" > "$state"
  apply "$1"
''
