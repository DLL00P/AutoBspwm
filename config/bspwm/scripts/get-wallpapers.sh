#!/usr/bin/env bash
#
# get-wallpapers.sh - download wallpapers into ~/Wallpapers
#
#   get-wallpapers.sh                         anime collection (dharmx/walls, ~300 images)
#   get-wallpapers.sh anime evangelion        folders from dharmx/walls (--list to see all)
#   get-wallpapers.sh --popular               top wallpapers of the most popular anime
#   get-wallpapers.sh --series "chainsaw man" "naruto" ...
#                                             top wallpapers of any anime, by name
#   COUNT=40 get-wallpapers.sh --series "one piece"   (default COUNT: 20 per series)
#
# --series / --popular use the public Wallhaven API (https://wallhaven.cc):
# safe-for-work only, anime category, at least 1920x1080, 16:9 or 16:10,
# sorted by most favourites. Each series goes to ~/Wallpapers/<series>/.
# Running it again only downloads what is missing.
#
# Nothing is redistributed by this repository; all rights belong to the artists.

set -uo pipefail

WALL_DIR="${WALL_DIR:-$HOME/Wallpapers}"
COUNT="${COUNT:-20}"
WALLS_REPO="https://github.com/dharmx/walls.git"
WALLS_CACHE="$HOME/.cache/wallpaper/walls-repo"
API="https://wallhaven.cc/api/v1/search"

POPULAR=(
	"naruto" "one piece" "demon slayer" "chainsaw man" "jujutsu kaisen"
	"attack on titan" "dragon ball" "solo leveling" "bleach" "hunter x hunter"
	"spy x family" "frieren" "my hero academia" "tokyo ghoul" "one punch man"
	"death note" "cyberpunk edgerunners" "neon genesis evangelion"
)

mkdir -p "$WALL_DIR"

# ------------------------------------------------------------ dharmx/walls
walls_repo() {
	mkdir -p "$(dirname "$WALLS_CACHE")"
	if [[ ! -d "$WALLS_CACHE/.git" ]]; then
		git clone --depth 1 --filter=blob:none --no-checkout -q "$WALLS_REPO" "$WALLS_CACHE" || exit 1
	fi
}

get_walls_categories() {
	local c n
	walls_repo
	for c in "$@"; do
		git -C "$WALLS_CACHE" ls-tree -d --name-only HEAD | grep -qxF "$c" \
			|| { echo "[!] Unknown category '$c' (use --list)"; exit 1; }
	done

	echo "[*] Downloading: $* (this can take a while)"
	# add to the categories already downloaded instead of replacing them
	if git -C "$WALLS_CACHE" sparse-checkout list 2>/dev/null | grep -q .; then
		git -C "$WALLS_CACHE" sparse-checkout add "${@/%//}"
	else
		git -C "$WALLS_CACHE" sparse-checkout set --no-cone "${@/%//}"
	fi
	git -C "$WALLS_CACHE" checkout -q
	git -C "$WALLS_CACHE" pull -q --depth 1 || true

	for c in "$@"; do
		# link instead of copying so the images are stored only once
		[[ -e "$WALL_DIR/$c" && ! -L "$WALL_DIR/$c" ]] \
			&& { echo "[!] $WALL_DIR/$c exists and is not a link, skipping"; continue; }
		ln -sfn "$WALLS_CACHE/$c" "$WALL_DIR/$c"
		n=$(find -L "$WALL_DIR/$c" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) | wc -l)
		echo "[+] $c: $n wallpapers"
	done
}

# ------------------------------------------------------------ Wallhaven
slug() {
	printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | sed 's/^-//; s/-$//'
}

# print "<url>" lines for the top $COUNT results of a query
wallhaven_urls() {
	local query="$1" page=1 got=0 json urls last
	while (( got < COUNT )); do
		json=$(curl -fsSL --retry 3 --max-time 30 -G "$API" \
			--data-urlencode "q=$query" \
			-d categories=010 -d purity=100 -d atleast=1920x1080 \
			-d ratios=16x9,16x10 -d sorting=favorites -d order=desc -d page="$page") || return 1
		urls=$(printf '%s' "$json" | python3 -c '
import json, sys
d = json.load(sys.stdin)
for w in d.get("data", []):
    if w.get("purity") == "sfw" and w.get("category") == "anime":
        print(w["path"])
print("#last_page=%s" % d.get("meta", {}).get("last_page", 1))
') || return 1
		while read -r u; do
			[[ "$u" == "#last_page="* ]] && continue
			[[ -n "$u" ]] || continue
			echo "$u"
			(( ++got >= COUNT )) && break
		done <<< "$urls"
		last=$(sed -n 's/^#last_page=//p' <<< "$urls")
		(( page >= ${last:-1} )) || [[ "$urls" != *"https://"* ]] && break
		(( page++ ))
		sleep 1.5   # API limit: 45 requests per minute
	done
}

get_series() {
	local s dir url file n new total=0
	command -v curl >/dev/null || { echo "[!] curl is required (sudo apt install curl)"; exit 1; }
	for s in "$@"; do
		dir="$WALL_DIR/$(slug "$s")"
		mkdir -p "$dir"
		echo "[*] $s: looking for the top $COUNT wallpapers..."
		new=0
		while read -r url; do
			file="$dir/$(basename "$url")"
			[[ -s "$file" ]] && continue
			if curl -fsSL --retry 3 --max-time 120 -o "$file.part" "$url"; then
				mv "$file.part" "$file"; (( new++ ))
			else
				rm -f "$file.part"
			fi
		done < <(wallhaven_urls "$s" || echo "[!] Wallhaven request failed for '$s'" >&2)
		n=$(find "$dir" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) | wc -l)
		(( n == 0 )) && rmdir "$dir" 2>/dev/null
		echo "[+] $s: $new new, $n in $dir"
		(( total += new ))
		sleep 1.5
	done
	echo "[+] Done: $total new wallpapers"
}

# ------------------------------------------------------------ main
case "${1:-}" in
	--list)
		walls_repo
		echo "dharmx/walls folders:"
		git -C "$WALLS_CACHE" ls-tree -d --name-only HEAD | tr '\n' ' '; echo
		echo
		echo "Popular anime (--popular):"
		printf '  %s\n' "${POPULAR[@]}"
		;;
	--popular)
		get_series "${POPULAR[@]}"
		;;
	--series)
		shift
		(( $# )) || { echo 'Usage: get-wallpapers.sh --series "chainsaw man" "naruto" ...'; exit 1; }
		get_series "$@"
		;;
	-h|--help)
		sed -n '3,17p' "$0" | sed 's/^# \{0,1\}//'
		;;
	"")
		get_walls_categories anime
		;;
	*)
		get_walls_categories "$@"
		;;
esac
