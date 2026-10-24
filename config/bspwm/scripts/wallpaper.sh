#!/usr/bin/env bash
#
# wallpaper.sh - set a wallpaper and recolour the whole desktop from it.
#
#   wallpaper.sh --random        random wallpaper (never repeats the current one)
#   wallpaper.sh --next|--prev   step through the collection in order
#   wallpaper.sh --pick          choose one visually with rofi
#   wallpaper.sh --set FILE      use a specific image
#   wallpaper.sh --restore       re-apply the last wallpaper and colours (no pywal run)
#   wallpaper.sh --login         restore if bspwm is just being reloaded, random otherwise
#   wallpaper.sh --cycle MIN     change to a random wallpaper every MIN minutes
#   wallpaper.sh --pin           toggle: keep the current wallpaper + colours forever
#                                (logins, --cycle and the change keys leave it alone)
#
# Wallpapers are read recursively from $WALL_DIR (default: ~/Wallpapers).

export PATH="$HOME/.local/bin:$PATH"

WALL_DIR="${WALL_DIR:-$HOME/Wallpapers}"
STATE_DIR="$HOME/.cache/wallpaper"
CURRENT="$STATE_DIR/current"
LOCK="$STATE_DIR/lock"
SCRIPTS="$HOME/.config/bspwm/scripts"
BAR_LAUNCH="$HOME/.config/polybar/launch.sh"
BAR_STYLE="--shapes"
PINNED="$STATE_DIR/pinned"
PICKER_THEME="$HOME/.config/polybar/shapes/scripts/rofi/wallpicker.rasi"

mkdir -p "$STATE_DIR"

notify() {
	command -v notify-send >/dev/null && notify-send -a wallpaper "Wallpaper" "$1"
	echo "[wallpaper] $1" >&2
}

list_walls() {
	find -L "$WALL_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) 2>/dev/null | sort
}

current_wall() {
	[[ -L "$CURRENT" ]] && readlink "$CURRENT"
}

relaunch_bar() {
	# close the lock fds: polybar must not inherit (and hold) them
	[[ -x "$BAR_LAUNCH" ]] && "$BAR_LAUNCH" "$BAR_STYLE" >/dev/null 2>&1 8>&- 9>&- &
}

reload_kitty() {
	# kitty >= 0.24 reloads its config (and therefore color.ini) on SIGUSR1
	pkill -USR1 -x kitty 2>/dev/null
}

apply() {
	local img="$1"
	[[ -f "$img" ]] || { notify "File not found: $img"; return 1; }

	(
		flock -n 9 || { notify "A wallpaper change is already running (lock: $LOCK)"; exit 0; }

		feh --no-fehbg --bg-fill "$img"
		ln -sfn "$img" "$CURRENT"

		if ! command -v wal >/dev/null; then
			notify "pywal (wal) is not installed - colours were not updated"
			relaunch_bar
			exit 0
		fi

		# -n: don't set the wallpaper (feh did), -q: quiet, -t: skip TTYs,
		# -e: don't reload gtk/xrdb. Open terminals are recoloured by wal itself.
		wal -n -q -t -e -i "$img" >/dev/null 2>&1 \
			|| { notify "pywal failed on $(basename "$img")"; relaunch_bar; exit 0; }

		python3 "$SCRIPTS/theme-colors.py"
		reload_kitty
		relaunch_bar
	) 9>"$LOCK"
}

is_pinned() {
	[[ -f "$PINNED" ]]
}

refuse_if_pinned() {
	if is_pinned; then
		notify "Wallpaper is pinned. Press Alt+F10 to unpin it."
		exit 0
	fi
}

toggle_pin() {
	local img
	if is_pinned; then
		img="$(cat "$PINNED")"
		[[ -f "$img" ]] && ln -sfn "$img" "$CURRENT"
		rm -f "$PINNED"
		notify "Wallpaper unpinned - it will change again on login"
		return
	fi
	img="$(current_wall)"
	[[ -f "$img" ]] || { notify "No current wallpaper to pin"; return 1; }
	# keep a private copy so updating or deleting the collection can't break it
	mkdir -p "$STATE_DIR/pin"
	rm -f "$STATE_DIR/pin/"*
	cp -f -- "$img" "$STATE_DIR/pin/"
	cp -f "$HOME/.cache/wal/colors.json" "$HOME/.cache/wal/colors-kitty.conf" "$STATE_DIR/pin/" 2>/dev/null
	ln -sfn "$STATE_DIR/pin/$(basename "$img")" "$CURRENT"
	printf '%s\n' "$img" > "$PINNED"
	notify "Pinned: $(basename "$img")"
}

random_wall() {
	local cur walls
	cur="$(current_wall)"
	mapfile -t walls < <(list_walls | grep -vxF -- "$cur")
	(( ${#walls[@]} )) || mapfile -t walls < <(list_walls)
	(( ${#walls[@]} )) || { notify "No images found in $WALL_DIR"; return 1; }
	printf '%s\n' "${walls[RANDOM % ${#walls[@]}]}"
}

step_wall() {
	local dir="$1" cur walls i n
	cur="$(current_wall)"
	mapfile -t walls < <(list_walls)
	n=${#walls[@]}
	(( n )) || { notify "No images found in $WALL_DIR"; return 1; }
	for i in "${!walls[@]}"; do
		[[ "${walls[i]}" == "$cur" ]] && break
	done
	[[ "${walls[i]}" == "$cur" ]] || i=-1
	printf '%s\n' "${walls[( (i + dir) % n + n ) % n]}"
}

pick_wall() {
	local choice
	choice=$(list_walls | while read -r f; do
		printf '%s\0icon\x1f%s\n' "${f#"$WALL_DIR"/}" "$f"
	done | rofi -dmenu -i -show-icons -p "wallpaper" -theme "$PICKER_THEME")
	[[ -n "$choice" ]] && printf '%s\n' "$WALL_DIR/$choice"
}

restore() {
	local img
	img="$(current_wall)"
	if [[ -f "$img" ]]; then
		feh --no-fehbg --bg-fill "$img"
		# pinned: always regenerate from the palette saved when pinning
		if is_pinned && [[ -f "$STATE_DIR/pin/colors.json" ]]; then
			mkdir -p "$HOME/.cache/wal"
			cp -f "$STATE_DIR/pin/colors.json" "$STATE_DIR/pin/colors-kitty.conf" "$HOME/.cache/wal/" 2>/dev/null
		fi
		[[ -f "$HOME/.cache/wal/colors.json" ]] && python3 "$SCRIPTS/theme-colors.py" 2>/dev/null
		relaunch_bar
	else
		apply "$(random_wall)"
	fi
}

case "$1" in
	--random|"") refuse_if_pinned; apply "$(random_wall)" ;;
	--next)      refuse_if_pinned; apply "$(step_wall 1)" ;;
	--prev)      refuse_if_pinned; apply "$(step_wall -1)" ;;
	--pick)      refuse_if_pinned; img="$(pick_wall)"; [[ -n "$img" ]] && apply "$img" ;;
	--set)       refuse_if_pinned; apply "$(realpath -s -- "$2")" ;;
	--pin)       toggle_pin ;;
	--restore)   restore ;;
	--login)
		# bspwmrc runs on login *and* on `bspc wm -r`; only shuffle on a real login
		if is_pinned || pgrep -u "$UID" -x polybar >/dev/null; then restore; else apply "$(random_wall)"; fi
		;;
	--cycle)
		min="${2:-30}"
		[[ "$min" =~ ^[0-9]+$ && "$min" -gt 0 ]] || { echo "Usage: $0 --cycle MINUTES"; exit 1; }
		# only one cycler at a time
		exec 8>"$STATE_DIR/cycle.lock"
		flock -n 8 || exit 0
		while sleep "$((min * 60))"; do is_pinned || apply "$(random_wall)"; done
		;;
	-h|--help|*)
		sed -n '3,15p' "$0" | sed 's/^# \{0,1\}//'
		;;
esac
