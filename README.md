# SPT 4.1.6 settings (client + server)

My personal mod **settings** for [SPT](https://sp-tarkov.com) 4.1.6 (the offline /
single-player version of Escape from Tarkov), ready to copy into your own SPT folder.

> **How this was made (AI disclosure):** the configuration was tuned by Kaan, who has
> no programming background, by playing and testing. **Claude**, an AI assistant made by
> Anthropic, helped with the tuning, wrote the collection and sanitising scripts, and
> prepared this package. No human expert has reviewed the values.

**Download:** [latest release](https://github.com/Kaanori/spt-416-settings/releases/latest) | [VirusTotal report](https://www.virustotal.com/gui/file/bb46a581c2c1cc1907df9a7b44cfd7cf87f369bf58bec5c799f2719dd31d8e82)

## Changelog

* **v2026.11.10.2** - Player health back to default (SVM preset `Player.Health` no longer 5x).
* **v2026.11.10** - first release.

## What is in here

* **Settings only.** No mods, no DLLs, no assets, no profiles, no save games.
  You need to install the mods themselves from the [SPT Forge](https://forge.sp-tarkov.com)
  or from the authors; the full list with the versions these settings were made for
  is in [`MODS.md`](MODS.md).
* `BepInEx/config/*.cfg` - client mod settings (F12 menu values).
* `BepInEx/plugins/SAIN/Presets`, `BepInEx/plugins/ORBIT/Config` - SAIN presets and ORBIT zone files.
* `SPT_Runtime/user/mods/<mod>/` - server mod configs (config.json / .jsonc, SVM preset,
  ABPS, PBT, SAIN server preset, ORBIT config, ...).
* Game options (`SPT_Runtime/user/sptSettings`: graphics, sound, controls) are **not included**.
* [`BEREINIGT.md`](BEREINIGT.md) - what was checked and removed for privacy.

## The SVM preset (PhoenixSVM405)

The main server-side tuning lives in one file:
`SPT_Runtime/user/mods/[SVM] Server Value Modifier/Presets/PhoenixSVM405.json`

* Copy it into the same folder of your own SVM install (the `Presets` folder next to
  `ServerValueModifier.dll`), start the **Server Value Modifier** program/menu and
  select/load the preset `PhoenixSVM405`. The included `Loader/loader.json` just points to it.
* It contains **only SVM values** (traders, flea market, weights, stack sizes, raid times, ...).
* The other server mods (ABPS/PBT, MoreBots, VisitAPI, QuestBackport, loot, Kaan's own mods, ...)
  are not part of the SVM preset - they have their own config files, which are also in this
  package under `SPT_Runtime/user/mods/<mod>/`.

## Installation

1. **Back up your own configs first** (`BepInEx/config`, `SPT_Runtime/user/mods`). The zip overwrites files with the same name.
2. Install the mods listed in `MODS.md` (at least the ones whose settings you want).
3. Extract the zip into your SPT folder (the one that contains `BepInEx` and `SPT_Runtime`).
4. Start the server once, then the game. Settings of mods you have not installed are harmless.

If you only want some mods' settings, copy just those files.

## Version warning

Settings files belong to one specific mod version. Newer or older versions can add,
rename or drop options. Use these files only with the versions in `MODS.md`;
otherwise take them as a reference and compare by hand. A mod may rewrite its config
on first start - that is normal.

## Linux / Proton notes

This setup runs on Linux (Proton/Wine). Some things are therefore specific to that:

* `FixPluginTypesSerialization.cfg` is **not** included - it holds memory offsets for
  one patched build under Proton and would break other setups.
* Graphics-related settings (e.g. FSR/AO/fog mods) are tuned for an
  AMD GPU and 4K; lower them if you have a weaker card.
* Anything path-like was replaced by a placeholder (see `BEREINIGT.md`).

## Included on purpose and left out

Left out: game options (sptSettings), user profiles, caches, logs, backups (`*.vor-*`, `*.bak`), large data files
(over 2 MB), the aim-assist plug-in's settings, and settings that only store machine state.

## License

MIT, see [`LICENSE`](LICENSE). The settings belong to the respective mods; their
licenses apply to the mods themselves, which are not part of this package.
