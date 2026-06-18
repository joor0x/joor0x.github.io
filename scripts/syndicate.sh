#!/usr/bin/env bash
#
# syndicate.sh — turn a Hugo post into DEV.to- and Hashnode-ready Markdown.
#
# It reads content/posts/<slug>/index.md, rewrites relative image/link paths to
# absolute canonical URLs, strips Hugo shortcodes, injects UTM backlinks, and
# writes platform-specific copies to syndication/<slug>/.
#
# Usage:
#   scripts/syndicate.sh <post-slug>     # generate copies for one post
#   scripts/syndicate.sh --list          # list available post slugs
#   scripts/syndicate.sh <slug> --stdout # print to stdout instead of files
#   scripts/syndicate.sh <slug> --api    # create drafts via the platform APIs
#                                        #   DEV.to:   needs DEVTO_API_KEY
#                                        #   Hashnode: needs HASHNODE_API_KEY +
#                                        #             HASHNODE_PUB_ID
#                                        #   (posts to whichever is configured)
#
# The original Hugo post stays the canonical source; the copies point back to it
# via the canonical_url field, so they never compete with you in search.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

POSTS_DIR="content/posts"

usage() {
  sed -n '2,18p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

list_slugs() {
  echo "Available post slugs:"
  for d in "$POSTS_DIR"/*/; do
    [ -f "${d}index.md" ] && echo "  - $(basename "$d")"
  done
}

[ $# -eq 0 ] && { usage; }

case "${1:-}" in
  -h|--help) usage 0 ;;
  --list|-l) list_slugs; exit 0 ;;
esac

SLUG="$1"
MODE="files"
case "${2:-}" in
  --stdout) MODE="stdout" ;;
  --api)    MODE="api" ;;
  "")       ;;
  *) echo "error: unknown option '$2' (use --stdout or --api)" >&2; exit 1 ;;
esac

POST="$POSTS_DIR/$SLUG/index.md"
if [ ! -f "$POST" ]; then
  echo "error: no post found at $POST" >&2
  echo >&2
  list_slugs >&2
  exit 1
fi

# baseURL straight from hugo.toml so the script stays config-driven.
BASE_URL="$(grep -E '^baseURL' hugo.toml | head -1 | sed -E 's/.*=\s*"([^"]*)".*/\1/')"
BASE_URL="${BASE_URL:-https://joor0x.github.io/}"

OUT_DIR="syndication/$SLUG"
[ "$MODE" = "files" ] && mkdir -p "$OUT_DIR"

POST="$POST" SLUG="$SLUG" BASE_URL="$BASE_URL" OUT_DIR="$OUT_DIR" MODE="$MODE" \
DEVTO_API_KEY="${DEVTO_API_KEY:-}" \
HASHNODE_API_KEY="${HASHNODE_API_KEY:-}" HASHNODE_PUB_ID="${HASHNODE_PUB_ID:-}" \
python3 - <<'PY'
import os, re, sys

post     = os.environ["POST"]
slug     = os.environ["SLUG"]
base_url = os.environ["BASE_URL"].rstrip("/") + "/"
out_dir  = os.environ["OUT_DIR"]
mode     = os.environ["MODE"]

canonical = f"{base_url}posts/{slug}/"

# Some API edges (Hashnode is behind Cloudflare) reject the default python-urllib
# User-Agent with a 403/1010, so present a normal one.
USER_AGENT = "Mozilla/5.0 (compatible; syndicate.sh/1.0; +https://joor0x.github.io)"

raw = open(post, encoding="utf-8").read()

# --- 1. Split front matter (handles both +++ TOML and --- YAML) -------------
m = re.match(r'^(\+\+\+|---)\s*\n(.*?)\n\1\s*\n(.*)$', raw, re.DOTALL)
if not m:
    sys.exit(f"error: could not parse front matter in {post}")
fm, body = m.group(2), m.group(3)

def fm_scalar(field):
    mm = re.search(rf'^{field}\s*[:=]\s*(.+?)\s*$', fm, re.MULTILINE)
    if not mm:
        return ""
    return mm.group(1).strip().strip('"').strip("'")

def fm_tags():
    mm = re.search(r'^tags\s*[:=]\s*\[(.*?)\]', fm, re.MULTILINE | re.DOTALL)
    if not mm:
        return []
    return [t.strip().strip('"').strip("'") for t in mm.group(1).split(",") if t.strip()]

title       = fm_scalar("title")
description  = fm_scalar("description")
tags        = fm_tags()

# --- 2. Strip Hugo shortcodes (none in repo today, but be safe) -------------
shortcodes = len(re.findall(r'\{\{[<%].*?[>%]\}\}', body, re.DOTALL))
body = re.sub(r'\{\{[<%].*?[>%]\}\}', '', body, flags=re.DOTALL)

# --- 3. Rewrite relative image/link targets to absolute canonical URLs ------
def absolutize(target):
    t = target.strip()
    # Leave absolute URLs, root-relative paths, anchors and mailto alone.
    if re.match(r'^(https?:|/|#|mailto:|tel:)', t):
        return target
    return f"{base_url}posts/{slug}/{t.lstrip('./')}"

img_count = [0]
def repl(mobj):
    bang, alt, target = mobj.group(1), mobj.group(2), mobj.group(3)
    # A target may carry a title: (url "alt text") — keep the title part intact.
    parts = target.split(None, 1)
    url = absolutize(parts[0])
    rest = (" " + parts[1]) if len(parts) > 1 else ""
    if bang and url != parts[0] + (" " + parts[1] if len(parts) > 1 else ""):
        img_count[0] += 1
    return f"{bang}[{alt}]({url}{rest})"

body = re.sub(r'(!?)\[([^\]]*)\]\(([^)]+)\)', repl, body)
body = body.strip()

# --- 4. Platform-specific tag rules -----------------------------------------
# DEV.to: alphanumeric only, lowercase, max 4 tags.
dev_tags = []
for t in tags:
    clean = re.sub(r'[^a-z0-9]', '', t.lower())
    if clean and clean not in dev_tags:
        dev_tags.append(clean)
dev_tags = dev_tags[:4]

# Hashnode: lenient, keep hyphens, up to 5 tags.
hash_tags = []
for t in tags:
    clean = t.lower().strip()
    if clean and clean not in hash_tags:
        hash_tags.append(clean)
hash_tags = hash_tags[:5]

def backlink(platform):
    url = f"{canonical}?utm_source={platform}&utm_medium=syndication&utm_campaign={slug}"
    return (f"> 📝 **Originally published on [joor0x.github.io]({url}).** "
            f"Follow there for the canonical version and more posts.")

# --- 5. Build outputs --------------------------------------------------------
# Body shared by the file/stdout copies and the API payload: backlink-wrapped,
# images already absolutized. No front matter — that is added per output below.
dev_body = backlink("devto") + "\n\n" + body + "\n\n---\n\n" + backlink("devto")

def dev_md():
    fm_lines = [
        "---",
        f'title: "{title}"',
        "published: false",
    ]
    if description:
        fm_lines.append(f'description: "{description}"')
    fm_lines.append(f"tags: {', '.join(dev_tags)}")
    fm_lines.append(f"canonical_url: {canonical}")
    fm_lines.append("# cover_image: " + f"{base_url}posts/{slug}/images/cover.png  # optional, set if you have one")
    fm_lines.append("---")
    return "\n".join(fm_lines) + "\n\n" + dev_body + "\n"

# Hashnode contentMarkdown: no H1 (Hashnode renders the title separately) and
# no front matter (title/tags/canonical go in API fields). Shared by API + file.
hash_body = backlink("hashnode") + "\n\n" + body + "\n\n---\n\n" + backlink("hashnode")

def hashnode_md():
    header = [
        "<!-- ===== HASHNODE METADATA — set these in the editor UI ===== -->",
        f"<!-- Title:        {title} -->",
        f"<!-- Canonical:    {canonical}  (Settings → Original/Canonical URL) -->",
        f"<!-- Tags:         {', '.join(hash_tags)} -->",
        "<!-- ========================================================== -->",
        "",
        f"# {title}",
        "",
        hash_body,
        "",
    ]
    return "\n".join(header)

dev_out  = dev_md()
hash_out = hashnode_md()

warnings = []
if shortcodes:
    warnings.append(f"stripped {shortcodes} Hugo shortcode(s) — check those spots manually")
if len(tags) > 4:
    warnings.append(f"post has {len(tags)} tags; DEV.to limited to first 4: {', '.join(dev_tags)}")
if not description:
    warnings.append("no description in front matter — add one for better SEO on the copies")

import json, urllib.request, urllib.error

def _send(req, label):
    """POST a urllib Request, returning parsed JSON or exiting with a clear error."""
    try:
        with urllib.request.urlopen(req) as r:
            raw = r.read().decode("utf-8", "replace")
    except urllib.error.HTTPError as e:
        body = e.read().decode(errors="replace")[:500]
        sys.exit(f"error: {label} API returned {e.code}\n  {body}")
    except urllib.error.URLError as e:
        sys.exit(f"error: could not reach {label} API: {e.reason}")
    try:
        return json.loads(raw)
    except ValueError:
        kind = "HTML" if raw.lstrip()[:1] == "<" else "non-JSON"
        sys.exit(f"error: {label} returned a {kind} response ({len(raw)} bytes), not JSON.\n"
                 "  Likely a proxy/Cloudflare interstitial or wrong endpoint — "
                 "check network egress and that your token is valid.")

def post_devto():
    key = os.environ.get("DEVTO_API_KEY", "").strip()
    if not key:
        sys.exit("error: DEVTO_API_KEY is not set.\n"
                 "  Create a key at https://dev.to/settings/extensions "
                 "('DEV Community API Keys'), then:\n"
                 "  export DEVTO_API_KEY=your_key_here")
    article = {
        "title": title,
        "body_markdown": dev_body,
        "published": False,          # always a draft — you review & publish in DEV
        "tags": dev_tags,
        "canonical_url": canonical,
    }
    if description:
        article["description"] = description
    data = json.dumps({"article": article}).encode("utf-8")
    req = urllib.request.Request(
        "https://dev.to/api/articles", data=data, method="POST",
        headers={
            "api-key": key,
            "Content-Type": "application/json",
            "Accept": "application/vnd.forem.api-v1+json",
            "User-Agent": USER_AGENT,
        },
    )
    resp = _send(req, "DEV.to")
    print(f"✓ Created DEV.to draft (published: false)")
    print(f"  Canonical : {canonical}")
    print(f"  Tags      : {', '.join(dev_tags)}")
    print(f"  Edit/publish: {resp.get('url') or 'https://dev.to/dashboard'}")

def post_hashnode():
    token  = os.environ.get("HASHNODE_API_KEY", "").strip()
    pub_id = os.environ.get("HASHNODE_PUB_ID", "").strip()
    if not token or not pub_id:
        return False  # not configured — caller reports it
    # Tag input: Hashnode wants {slug, name}; slug must be lowercase alnum + hyphen.
    tags = []
    for t in hash_tags:
        s = re.sub(r'[^a-z0-9-]', '', t.lower()).strip('-')
        if s:
            tags.append({"slug": s, "name": t})
    query = (
        "mutation CreateDraft($input: CreateDraftInput!) {"
        "  createDraft(input: $input) { draft { id slug } }"
        "}"
    )
    variables = {"input": {
        "title": title,
        "publicationId": pub_id,
        "contentMarkdown": hash_body,
        "tags": tags,
        "originalArticleURL": canonical,   # <-- canonical / "Originally published at"
    }}
    data = json.dumps({"query": query, "variables": variables}).encode("utf-8")
    req = urllib.request.Request(
        "https://gql.hashnode.com/", data=data, method="POST",
        headers={
            "Authorization": token,
            "Content-Type": "application/json",
            "User-Agent": USER_AGENT,
        },
    )
    resp = _send(req, "Hashnode")
    # GraphQL returns HTTP 200 even on logical errors — inspect the body.
    if resp.get("errors"):
        msgs = "; ".join(e.get("message", str(e)) for e in resp["errors"])
        sys.exit(f"error: Hashnode GraphQL: {msgs}")
    draft = (resp.get("data") or {}).get("createDraft", {}).get("draft") or {}
    print(f"✓ Created Hashnode draft")
    print(f"  Canonical : {canonical}")
    print(f"  Tags      : {', '.join(t['slug'] for t in tags)}")
    print(f"  Draft id  : {draft.get('id', '?')} — review & publish in your Hashnode dashboard (Drafts)")
    return True

if mode == "stdout":
    print("=" * 70)
    print("DEV.TO  (paste into the front-matter editor)")
    print("=" * 70)
    print(dev_out)
    print("=" * 70)
    print("HASHNODE  (paste body; set canonical/tags in the UI)")
    print("=" * 70)
    print(hash_out)
elif mode == "api":
    have_dev  = bool(os.environ.get("DEVTO_API_KEY", "").strip())
    have_hash = bool(os.environ.get("HASHNODE_API_KEY", "").strip()
                     and os.environ.get("HASHNODE_PUB_ID", "").strip())
    if not have_dev and not have_hash:
        sys.exit(
            "error: no API credentials configured. Set one or both:\n"
            "  DEV.to    → export DEVTO_API_KEY=...        (dev.to/settings/extensions)\n"
            "  Hashnode  → export HASHNODE_API_KEY=...     (hashnode.com/settings/developer)\n"
            "              export HASHNODE_PUB_ID=...      (your publication's id)")
    if have_dev:
        post_devto()
    else:
        print("• DEV.to skipped (DEVTO_API_KEY not set)")
    if have_hash:
        post_hashnode()
    else:
        print("• Hashnode skipped (HASHNODE_API_KEY / HASHNODE_PUB_ID not set)")
else:
    dev_path  = os.path.join(out_dir, "devto.md")
    hash_path = os.path.join(out_dir, "hashnode.md")
    open(dev_path, "w", encoding="utf-8").write(dev_out)
    open(hash_path, "w", encoding="utf-8").write(hash_out)
    print(f"✓ Canonical: {canonical}")
    print(f"✓ Images/links rewritten to absolute: {img_count[0]}")
    print(f"✓ DEV.to     → {dev_path}   (tags: {', '.join(dev_tags)})")
    print(f"✓ Hashnode   → {hash_path}   (tags: {', '.join(hash_tags)})")

if warnings:
    print("\n⚠ warnings:", file=sys.stderr)
    for w in warnings:
        print(f"  - {w}", file=sys.stderr)
PY
