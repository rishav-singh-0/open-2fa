#!/bin/bash

# File for all seeds
seed_file="${1:-$HOME/.config/open-2fa/seeds}"

decode() {
  oathtool -b --totp "$1"
}

# Select menu program and clipboard tool
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
  program="wofi -d -L 10 -W 300 -p Select"
  clipboard="wl-copy --type text/plain"
  typer="wl-copy"
else
  program="dmenu -i -l 10"
  clipboard="xclip -selection clipboard"
  typer="xdotool type"
fi

# Verify seed file exists
[ -f "$seed_file" ] || { echo "Seed file not found: $seed_file" >&2; exit 1; }

# Select application
chosen=$(cut -d ':' -f1 "$seed_file" | eval "$program")
[ -n "$chosen" ] || exit 0

# Retrieve and decode seed
seed=$(awk -F':' -v app="$chosen" '$1 == app {print $2}' "$seed_file")
[ -n "$seed" ] || { echo "Seed not found for: $chosen" >&2; exit 1; }
code=$(decode "$seed")
[ -n "$code" ] || { echo "Failed to generate code for: $chosen" >&2; exit 1; }

# Output code
if [ -n "$code" ]; then
  echo -n "$code" | eval "$typer"
else
  echo -n "$code" | eval "$clipboard"
  command -v notify-send >/dev/null && notify-send "$code copied to clipboard."
fi
