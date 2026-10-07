#!/usr/bin/env bash
# Re-copy the landing page from the main repository and repoint its login links.
#
#   ./sync.sh ../QuantAxion
#
# The two copies exist because the application serves the page at / behind its
# access gate, and this site serves it with nothing behind it. The only
# difference that matters is where the login button goes: in the app it is a
# real route, here it must be the static access notice, or a visitor clicks
# through to a 404.

set -euo pipefail

source_repo="${1:-../QuantAxion}"
source_file="$source_repo/src/api/static/landing.html"
target="$(cd "$(dirname "$0")" && pwd)/index.html"

[[ -f "$source_file" ]] || {
  echo "Not found: $source_file" >&2
  echo "Pass the path to the main repository: ./sync.sh ../QuantAxion" >&2
  exit 1
}

cp "$source_file" "$target"

# Repoint and relabel. The app says "Log in" because a session is waiting to be
# created; here there is nothing to log in to, and saying so is better than a
# button that implies otherwise.
python3 - "$target" <<'PY'
import sys
from pathlib import Path

page = Path(sys.argv[1])
html = page.read_text()
html = html.replace('href="/login"', 'href="/login.html"')
for pattern in (
    '<a class="btn primary" href="/login.html">Log in</a>',
    '<a class="btn lg" href="/login.html">Log in</a>',
    '<a class="btn primary lg" href="/login.html">Log in</a>',
    '<a href="/login.html">Log in</a>',
):
    html = html.replace(pattern, pattern.replace("Log in", "Request access"))
page.write_text(html)

remaining = html.count('href="/login"')
assert remaining == 0, f"{remaining} app-only login links survived the rewrite"
print(f"Synced. {html.count('href=\"/login.html\"')} links point at the access page.")
PY
