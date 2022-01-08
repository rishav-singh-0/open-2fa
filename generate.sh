#!/bin/bash

# FIle for all seeds
seed_file=$HOME/.config/open-2fa/seeds

decode ()
{
  oathtool -b --totp $1
}

# Dmenu for selecting application/code_id
chosen=$(cut -d ':' -f1 $seed_file | dmenu -i -l 30)

# Copying seed for selected application
seed=$(cat $seed_file | sed -n '/'$chosen'/p' | awk -F':' '{print $2}')

# Decoding seed
code=$(decode "$seed")

# Copy code to clipboard and push notification
if [ -n "$1" ]; then
	xdotool type "$code"
else
	echo "$code" | tr -d '\n' | xclip -selection clipboard
	notify-send "'$code' copied to clipboard." &
fi
