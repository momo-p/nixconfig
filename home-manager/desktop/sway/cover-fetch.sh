# musicbrainz asks for a real user agent and roughly one request a second, so
# every answer is cached, misses included, and a track is only ever looked up
# once
set -eu

artist=${1:-}
album=${2:-}
[ -n "$artist" ] || exit 0

dir=$XDG_CACHE_HOME/covers
mkdir -p "$dir"
key=$(printf '%s\n%s' "$artist" "$album" | sha256sum | cut -c1-32)
hit=$dir/$key.jpg
miss=$dir/$key.miss

[ -f "$hit" ] && { printf '%s' "$hit"; exit 0; }
[ -f "$miss" ] && exit 0

ua="nixconfig-rail/1 ( https://github.com/momo-p/nixconfig )"
query=$(printf 'artist:"%s"' "$artist")
[ -n "$album" ] && query=$(printf '%s AND release:"%s"' "$query" "$album")

# art often hangs off the release group rather than the individual pressing,
# so ask for both and try each release before falling back to its group
paths=$(curl -sS -A "$ua" --max-time 15 --get \
          --data-urlencode "query=$query" --data 'fmt=json&limit=5' \
          https://musicbrainz.org/ws/2/release/ 2>/dev/null \
        | jq -r '.releases[]? | "release/\(.id)", "release-group/\(.["release-group"].id // "")"' 2>/dev/null \
        | grep -v '/$' || true)

for p in $paths; do
  code=$(curl -sSL -A "$ua" --max-time 15 -o "$hit.part" \
           -w '%{http_code}' \
           "https://coverartarchive.org/$p/front-250" 2>/dev/null || true)
  if [ "$code" = 200 ] && [ -s "$hit.part" ]; then
    mv "$hit.part" "$hit"
    printf '%s' "$hit"
    exit 0
  fi
  rm -f "$hit.part"
  sleep 1
done

: > "$miss"
