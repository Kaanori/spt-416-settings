#!/usr/bin/env python3
"""Bereinigt alle Textdateien unter paket/ (Argument 1) und schreibt BEREINIGT.md-Daten nach Argument 2."""
import json, glob, os, re, sys, collections
paket, report = sys.argv[1], sys.argv[2]
game = os.environ.get("SPT", "/path/to/your/SPT")
subs = []  # (kompiliert, ersatz, beschreibung)
lit = []   # (text, ersatz, beschreibung)
for f in glob.glob(game + "/SPT_Runtime/user/profiles/*.json"):
    d = json.load(open(f, encoding="utf-8"))
    i = d.get("info", {})
    ch = d.get("characters", {})
    pmc, sc = ch.get("pmc", {}), ch.get("scav", {})
    for v in (i.get("id"), pmc.get("_id"), pmc.get("sessionId"), sc.get("_id")):
        if v: lit.append((v, "<PROFILE_ID>", "profile/session ID"))
    for v in (i.get("username"), pmc.get("Info", {}).get("Nickname"), sc.get("Info", {}).get("Nickname")):
        if v and len(v) > 2: lit.append((v, "<PLAYER_NAME>", "player name"))
    for v in (i.get("aid"), pmc.get("aid")):
        if v: lit.append((str(v), "<ACCOUNT_ID>", "account ID (aid)"))
lit = sorted(set(lit), key=lambda x: -len(x[0]))
rx = [
 (re.compile(r"/home/[^/\s]+[^\s\"',;]*"), "<HOME>", "path /home/kaan"),
 (re.compile(r"/mnt/[A-Za-z0-9_./\- ]*[A-Za-z0-9_/]"), "<PATH>", "path /mnt/..."),
 (re.compile(r"[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}"), "<EMAIL>", "e-mail address"),
 (re.compile(r"https?://(?:discord(?:app)?\.com/api/webhooks|hooks\.slack\.com)/\S+"), "<WEBHOOK>", "webhook URL"),
 (re.compile(r"(?<![\dvV.])(?!127\.0\.0\.1(?![\d.]))(?!0\.0\.0\.0(?![\d.]))(?:(?:25[0-5]|2[0-4]\d|1?\d?\d)\.){3}(?:25[0-5]|2[0-4]\d|1?\d?\d)(?![\d.])"), "<IP>", "IP address"),
]
secret = re.compile(r'(?i)("?[\w\-]*(?:token|api[_\-]?key|secret|passw(?:or)?d|webhook|license[_\-]?key)"?\s*[:=]\s*)("[^"]+")')
hits = collections.OrderedDict()
def note(rel, what):
    hits.setdefault(rel, collections.Counter())[what] += 1
n = 0
for root, _, files in os.walk(paket):
    for fn in files:
        p = os.path.join(root, fn); rel = os.path.relpath(p, paket)
        try: s = open(p, encoding="utf-8").read()
        except Exception: continue
        o = s
        s = s.replace("Kaan's QoL", "\0QOL\0")
        for t, r, w in lit:
            c = s.count(t)
            if c: s = s.replace(t, r); [note(rel, w) for _ in range(c)]
        for pat, r, w in rx:
            s, c = pat.subn(r, s)
            for _ in range(c): note(rel, w)
        def sec(m):
            v = m.group(2)
            if v.strip('"') in ("", "<REDACTED>", "false", "true", "null", "0"): return m.group(0)
            note(rel, "secret-like field: " + m.group(1).strip(' :="'))
            return m.group(1) + '"<REDACTED>"'
        s = secret.sub(sec, s).replace("\0QOL\0", "Kaan's QoL")
        if s != o:
            open(p, "w", encoding="utf-8").write(s); n += 1
with open(report, "w", encoding="utf-8") as f:
    for rel, c in hits.items():
        for w, k in c.items(): f.write(f"{rel}\t{w}\t{k}\n")
print("bereinigte Dateien:", n)
