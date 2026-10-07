#!/usr/bin/env bash
# Re-copy the landing page from the main repository and adapt it for this site.
#
#   ./sync.sh ../QuantAxion
#
# The two copies exist because the application serves the page at / behind its
# access gate, and this site serves it with nothing behind it.
#
# The link target needs no rewriting: the app routes /login to its form, and
# Vercel's cleanUrls resolves /login to login.html here, so one href is correct
# in both places. Only the wording differs — there is no session to create on
# this site, and a button saying "Log in" would promise one.

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

python3 - "$target" <<'PY'
import re
import sys
from pathlib import Path

page = Path(sys.argv[1])
html = page.read_text()

# Relabel only the anchors that point at the access route, so an unrelated
# "Log in" elsewhere in the copy would not be caught by accident.
html, changed = re.subn(
    r'(<a\b[^>]*href="/login"[^>]*>)Log in(</a>)', r'\1Request access\2', html
)
page.write_text(html)

links = html.count('href="/login"')
assert links, "No /login links found — did the landing page change its markup?"
assert 'href="/login.html"' not in html, "An extension-ful link survived; cleanUrls would redirect it"
assert ">Log in<" not in html, "A 'Log in' label survived the rewrite"
print(f"Synced. {changed} of {links} access links relabelled.")
PY
