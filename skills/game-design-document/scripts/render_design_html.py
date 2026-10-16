#!/usr/bin/env python3
"""Render a markdown GDD into a single-file design.html (sidebar TOC, badges, tables, light/dark).

Usage: render_design_html.py INPUT.md OUTPUT.html [--title T] [--lang es]

Dependency-free on purpose. Supports: # headings, paragraphs, **bold**, *italic*, `code`,
fenced code blocks, - / 1. lists (one level of nesting by 2+ spaces), pipe tables, > quotes,
links [t](u), horizontal rules, and the status markers [OK] [PROP] [OPEN] rendered as badges.
"""
import argparse
import html
import re
import sys
from pathlib import Path

BADGES = {"OK": "ok", "PROP": "prop", "OPEN": "open"}
INLINE_CODE = re.compile(r"`([^`]+)`")
BOLD = re.compile(r"\*\*(.+?)\*\*")
ITALIC = re.compile(r"(?<![*\w])\*(?!\s)(.+?)(?<!\s)\*(?![*\w])")
LINK = re.compile(r"\[([^\]]+)\]\(([^)\s]+)\)")
BADGE = re.compile(r"\[(OK|PROP|OPEN)\]")


def slug(text: str) -> str:
    s = re.sub(r"[^\w\s-]", "", text.lower(), flags=re.UNICODE)
    s = re.sub(r"[\s_]+", "-", s).strip("-")
    return s or "s"


def inline(text: str) -> str:
    out = []
    pos = 0
    for m in INLINE_CODE.finditer(text):
        out.append(_inline_no_code(text[pos:m.start()]))
        out.append(f"<code>{html.escape(m.group(1))}</code>")
        pos = m.end()
    out.append(_inline_no_code(text[pos:]))
    return "".join(out)


def _inline_no_code(text: str) -> str:
    t = html.escape(text, quote=False)
    t = BADGE.sub(lambda m: f'<span class="badge {BADGES[m.group(1)]}">{m.group(1)}</span>', t)
    t = LINK.sub(r'<a href="\2">\1</a>', t)
    t = BOLD.sub(r"<strong>\1</strong>", t)
    t = ITALIC.sub(r"<em>\1</em>", t)
    return t


def render_table(rows):
    cells = [[c.strip() for c in r.strip().strip("|").split("|")] for r in rows]
    if len(cells) >= 2 and all(re.fullmatch(r":?-{2,}:?", c.strip() or "--") for c in cells[1]):
        head, body = cells[0], cells[2:]
    else:
        head, body = None, cells
    out = ['<div class="table-wrap"><table>']
    if head:
        out.append("<thead><tr>" + "".join(f"<th>{inline(c)}</th>" for c in head) + "</tr></thead>")
    out.append("<tbody>")
    for r in body:
        if any(c for c in r):
            out.append("<tr>" + "".join(f"<td>{inline(c)}</td>" for c in r) + "</tr>")
    out.append("</tbody></table></div>")
    return "\n".join(out)


def render(md: str):
    lines = md.splitlines()
    out, toc = [], []
    i, n = 0, len(lines)
    para = []
    list_stack = []  # list of (indent, tag)

    def flush_para():
        if para:
            out.append(f"<p>{inline(' '.join(s.strip() for s in para))}</p>")
            para.clear()

    def close_lists(to_indent=-1):
        while list_stack and list_stack[-1][0] > to_indent:
            out.append(f"</li></{list_stack.pop()[1]}>")

    while i < n:
        line = lines[i]
        stripped = line.strip()
        if stripped.startswith("```"):
            flush_para(); close_lists()
            lang = stripped[3:].strip()
            buf = []
            i += 1
            while i < n and not lines[i].strip().startswith("```"):
                buf.append(lines[i]); i += 1
            cls = f' class="lang-{html.escape(lang)}"' if lang else ""
            out.append(f"<pre><code{cls}>{html.escape(chr(10).join(buf))}</code></pre>")
            i += 1
            continue
        m = re.match(r"^(#{1,4})\s+(.*)$", line)
        if m:
            flush_para(); close_lists()
            level = len(m.group(1)); text = m.group(2).strip()
            sid = slug(BADGE.sub("", text))
            if level == 1:
                out.append(f"<h1>{inline(text)}</h1>")
            else:
                out.append(f'<h{level} id="{sid}">{inline(text)}</h{level}>')
                if level == 2:
                    toc.append((sid, BADGE.sub("", text).strip()))
            i += 1
            continue
        if stripped.startswith("|") and i + 1 < n and lines[i + 1].strip().startswith("|"):
            flush_para(); close_lists()
            rows = []
            while i < n and lines[i].strip().startswith("|"):
                rows.append(lines[i]); i += 1
            out.append(render_table(rows))
            continue
        if re.fullmatch(r"(-{3,}|\*{3,})", stripped):
            flush_para(); close_lists(); out.append("<hr>"); i += 1; continue
        if stripped.startswith(">"):
            flush_para(); close_lists()
            buf = []
            while i < n and lines[i].strip().startswith(">"):
                buf.append(lines[i].strip()[1:].strip()); i += 1
            out.append(f"<blockquote><p>{inline(' '.join(buf))}</p></blockquote>")
            continue
        lm = re.match(r"^(\s*)([-*+]|\d+[.)])\s+(.*)$", line)
        if lm:
            flush_para()
            indent = len(lm.group(1).expandtabs(4)); tag = "ol" if lm.group(2)[0].isdigit() else "ul"
            if list_stack and indent > list_stack[-1][0]:
                out.append(f"<{tag}><li>{inline(lm.group(3))}")
                list_stack.append((indent, tag))
            else:
                close_lists(indent)
                if list_stack and list_stack[-1][0] == indent:
                    out.append(f"</li><li>{inline(lm.group(3))}")
                else:
                    out.append(f"<{tag}><li>{inline(lm.group(3))}")
                    list_stack.append((indent, tag))
            i += 1
            continue
        if not stripped:
            flush_para(); close_lists(); i += 1; continue
        if list_stack and line.startswith((" ", "\t")):
            out.append(" " + inline(stripped)); i += 1; continue
        close_lists()
        para.append(line); i += 1
    flush_para(); close_lists()
    return "\n".join(out), toc


CSS = """
:root{--bg:#f6f7fb;--surface:#fff;--surface-2:#eef0f6;--text:#1c2030;--muted:#5d6577;--border:#d8dce8;--accent:#5b6cff;--accent-deep:#3a47c4;--warn:#b7790a;--open:#d23f66;--ok:#23863d;--code-bg:#eef0f6;color-scheme:light}
@media (prefers-color-scheme:dark){:root:not([data-theme=light]){--bg:#11131a;--surface:#181b25;--surface-2:#20242f;--text:#e6e8f0;--muted:#9aa2b5;--border:#2c3140;--accent:#8c98ff;--accent-deep:#aeb6ff;--warn:#f2bd4b;--open:#f07d9b;--ok:#6ad98a;--code-bg:#20242f;color-scheme:dark}}
:root[data-theme=dark]{--bg:#11131a;--surface:#181b25;--surface-2:#20242f;--text:#e6e8f0;--muted:#9aa2b5;--border:#2c3140;--accent:#8c98ff;--accent-deep:#aeb6ff;--warn:#f2bd4b;--open:#f07d9b;--ok:#6ad98a;--code-bg:#20242f;color-scheme:dark}
*{box-sizing:border-box}html{scroll-behavior:smooth}
body{margin:0;background:var(--bg);color:var(--text);font:15px/1.6 Inter,system-ui,sans-serif}
h1,h2,h3,h4{line-height:1.2}h1{font-size:2.4rem;margin:0 0 .25rem;color:var(--accent-deep)}
h2{font-size:1.55rem;margin:3rem 0 1rem;padding-top:.5rem;border-top:2px dashed var(--border)}
h3{font-size:1.15rem;margin:1.6rem 0 .5rem}h4{font-size:1rem;margin:1.2rem 0 .4rem;color:var(--muted)}
a{color:var(--accent)}code{background:var(--code-bg);padding:.1em .35em;border-radius:4px;font-size:.9em}
pre{background:var(--code-bg);padding:12px 14px;border-radius:10px;overflow-x:auto;font-size:.85rem}pre code{background:none;padding:0}
blockquote{border-left:4px solid var(--accent);margin:1rem 0;padding:.2rem 1rem;color:var(--muted);background:var(--surface)}
.layout{display:grid;grid-template-columns:240px minmax(0,1fr);max-width:1180px;margin:0 auto}
nav{position:sticky;top:0;align-self:start;height:100vh;overflow-y:auto;padding:28px 16px;border-right:1px solid var(--border)}
nav .logo{font-weight:700;font-size:1.2rem;color:var(--accent-deep);margin-bottom:1rem}
nav ol{list-style:none;padding:0;margin:0}nav a{display:block;padding:4px 8px;border-radius:6px;color:var(--muted);text-decoration:none;font-size:.9rem}
nav a:hover{background:var(--surface-2);color:var(--text)}
main{padding:36px 40px 80px;min-width:0}
.legend{display:flex;gap:14px;flex-wrap:wrap;font-size:.85rem;color:var(--muted);margin:.5rem 0 1.5rem}
.badge{display:inline-block;font-size:.72rem;font-weight:600;padding:2px 8px;border-radius:999px;vertical-align:middle;white-space:nowrap;margin-left:.25em}
.ok{background:color-mix(in srgb,var(--ok) 20%,transparent);color:var(--ok)}
.prop{background:color-mix(in srgb,var(--warn) 20%,transparent);color:var(--warn)}
.open{background:color-mix(in srgb,var(--open) 18%,transparent);color:var(--open)}
.table-wrap{overflow-x:auto;margin:1rem 0;border:1px solid var(--border);border-radius:12px}
table{border-collapse:collapse;width:100%;background:var(--surface);font-size:.9rem}
th,td{text-align:left;padding:9px 12px;border-bottom:1px solid var(--border);vertical-align:top}
th{background:var(--surface-2);font-weight:600;white-space:nowrap}tr:last-child td{border-bottom:0}
ul,ol{padding-left:1.4rem}li{margin:.2rem 0}
.theme-toggle{position:fixed;top:14px;right:16px;background:var(--surface);color:var(--text);border:1px solid var(--border);border-radius:999px;padding:6px 12px;cursor:pointer;font:inherit;font-size:.85rem;z-index:2}
@media (max-width:860px){.layout{grid-template-columns:1fr}nav{position:static;height:auto;border-right:0;border-bottom:1px solid var(--border);padding:16px}nav ol{columns:2}main{padding:24px 16px 60px}h1{font-size:1.9rem}}
"""

PAGE = """<!doctype html>
<html lang="{lang}">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{title}</title>
<style>{css}</style>
</head>
<body>
<button class="theme-toggle" onclick="(function(){{var r=document.documentElement;var d=r.getAttribute('data-theme')==='dark'||(!r.getAttribute('data-theme')&&matchMedia('(prefers-color-scheme: dark)').matches);r.setAttribute('data-theme',d?'light':'dark');}})()">☀/☾</button>
<div class="layout">
<nav><div class="logo">{nav_title}</div><ol>{toc}</ol></nav>
<main>
<div class="legend"><span class="badge ok">OK</span> {l_ok} · <span class="badge prop">PROP</span> {l_prop} · <span class="badge open">OPEN</span> {l_open}</div>
{body}
</main>
</div>
</body>
</html>
"""

LEGEND = {
    "es": ("decidido", "propuesto, revisable", "pendiente"),
    "en": ("decided", "proposed, revisable", "open"),
}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("input"); ap.add_argument("output")
    ap.add_argument("--title", default=None); ap.add_argument("--lang", default="es")
    a = ap.parse_args()
    md = Path(a.input).read_text(encoding="utf-8")
    body, toc = render(md)
    first_h1 = re.search(r"^#\s+(.*)$", md, flags=re.M)
    title = a.title or (first_h1.group(1).strip() if first_h1 else Path(a.input).stem)
    nav_title = title.split("·")[0].strip()
    l_ok, l_prop, l_open = LEGEND.get(a.lang, LEGEND["en"])
    toc_html = "".join(f'<li><a href="#{sid}">{html.escape(t)}</a></li>' for sid, t in toc)
    page = PAGE.format(lang=a.lang, title=html.escape(title), css=CSS, nav_title=html.escape(nav_title),
                       toc=toc_html, body=body, l_ok=l_ok, l_prop=l_prop, l_open=l_open)
    Path(a.output).write_text(page, encoding="utf-8")
    print(f"wrote {a.output} ({len(page)} bytes, {len(toc)} sections)")


if __name__ == "__main__":
    sys.exit(main())
