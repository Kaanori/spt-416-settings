#!/bin/bash
# Sammelt Client- und Server-Einstellungen aus dem SPT-4.1.6-Ordner in paket/ und bereinigt sie.
# Der Spielordner wird NUR gelesen. Wiederholbar: paket/ wird jedes Mal neu aufgebaut.
set -u
HIER="$(cd "$(dirname "$0")" && pwd)"
SPT="${SPT:-/path/to/your/SPT}"   # set SPT=... to your SPT folder
P="$HIER/paket"
rm -rf "$P"; mkdir -p "$P"
: > "$HIER/zu-gross.txt"
: > "$HIER/weggelassen.txt"
MAX=$((2*1024*1024))

kopiere() {   # kopiere <relativer Pfad ab SPT>
  local rel="$1" src="$SPT/$1"
  local sz; sz=$(stat -c %s "$src")
  if [ "$sz" -gt "$MAX" ]; then echo "$rel ($sz Byte)" >> "$HIER/zu-gross.txt"; return; fi
  mkdir -p "$P/$(dirname "$rel")"; cp "$src" "$P/$rel"
}

# ---------- Client: BepInEx/config ----------
cd "$SPT"
find BepInEx/config -maxdepth 2 -type f \( -name '*.cfg' \) \
  ! -name '*.vor-*' ! -name '*.standard-*' ! -name '*.sicherung' ! -name '*.bak' \
  ! -iname 'com.kaan.zielhilfe*' ! -iname 'com.kaan.platzierzeit*' ! -name 'FixPluginTypesSerialization.cfg' ! -name '*.heading-offset.txt' | sort | while read -r f; do kopiere "$f"; done
# Client: SAIN (Presets + Editor-Voreinstellungen)
find BepInEx/plugins/SAIN -type f -name '*.json' ! -name '*.standard-*' | sort | while read -r f; do kopiere "$f"; done
# Client: ORBIT-Zonen/Geometrie
find BepInEx/plugins/ORBIT/Config -type f -name '*.json' | sort | while read -r f; do kopiere "$f"; done
# Client: weitere kleine Einstellungsdateien
for f in BepInEx/plugins/AmandsSense/Items.json BepInEx/plugins/LennoxP90-MapVariants/maps.json; do [ -f "$f" ] && kopiere "$f"; done

# ---------- Server ----------
M=SPT_Runtime/user/mods
find "$M" -mindepth 2 -type f | python3 -I -c '
import sys, re
inc = [
 r"^[^/]+/config(\.[^/]*)?\.(json|jsonc|json5)$",
 r"^[^/]+/[Cc]onfig/(config|settings)[^/]*\.(json|jsonc|json5)$",
 r"^KaansQoL/[^/]+\.json$",
 r"^AufgabenGepaeck/questcase\.json$",
 r"^GroessereRucksaecke/rucksaecke\.json$",
 r"^\[SVM\] Server Value Modifier/(Presets/[^/]+\.json|Loader/loader\.json)$",
 r"^Solarint-SAIN-ServerMod/(CoreOverrides\.json|Data/NicknamePersonalities\.json|Presets/[^/]+\.json)$",
 r"^BarterItemsStacks/(params\.json|presets/[^/]+\.jsonc)$",
 r"^archangelwtf-lotsoflootredux/Presets/[^/]+\.json$",
 r"^ORBIT/(config\.json|zones/[^/]+\.json)$",
 r"^KirisameMedTiming/client_overrides\.json$",
 r"^LegArmorServer/config/bots\.json$",
 r"^CSGasServer/config/gas_masks\.json$",
 r"^acidphantasm-progressivebotsystem/blacklists\.json$",
]
exc = r"(default|standard|\.vor-|\.bak|sicherung|sync-only-example)"
inc = [re.compile(x) for x in inc]
for line in sys.stdin:
    line = line.rstrip("\n"); rel = line[len("SPT_Runtime/user/mods/"):]
    if re.search(exc, rel, re.I): continue
    if rel.startswith("OperatorRegistry/"): continue   # enthaelt nur Standard-Adresse + Installations-ID
    if any(r.search(rel) for r in inc): print(line)
' | sort | while read -r f; do kopiere "$f"; done
# sptSettings (Spieloptionen: Game/Graphics/Sound/Control/PostFx ...) werden bewusst NICHT kopiert.

# ---------- Bereinigen ----------
python3 -I "$HIER/bereinigen.py" "$P" "$HIER/bereinigt.tsv"
echo "Dateien: $(find "$P" -type f | wc -l), Groesse: $(du -sh "$P" | cut -f1)"
echo "Zu gross (nicht kopiert): $(wc -l < "$HIER/zu-gross.txt")"

# ---------- Doku + Zip ----------
mkdir -p "$P/SPT-Settings-Info"; cp "$HIER"/{README.md,MODS.md,BEREINIGT.md,LICENSE} "$P/SPT-Settings-Info/"
rm -f "$HIER"/spt-416-settings-*.zip
(cd "$P" && zip -qr "$HIER/spt-416-settings-$(date +%F).zip" .)
