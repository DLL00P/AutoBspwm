#!/bin/sh
# Set with: settarget <IP> [NAME]   (clear with: cleartarget)
file="$HOME/.config/polybar/shapes/scripts/target"
read -r ip name 2>/dev/null < "$file"
if [ -n "$ip" ] && [ -n "$name" ]; then
	echo "$ip · $name"
elif [ -n "$ip" ]; then
	echo "$ip"
else
	echo "No target"
fi
