# Sanitising report

All copied text files were checked automatically by `bereinigen.py` and then
re-checked by hand with `grep -r`. Rules (what would have been replaced):

| What | Replaced by | Result in this package |
|---|---|---|
| Profile / session IDs (the 24-hex IDs from the SPT profiles, incl. scav IDs) | `<PROFILE_ID>` | none found |
| Player names and nicknames from the profiles | `<PLAYER_NAME>` | none found (only the public mod name "Kaan's QoL", kept on purpose) |
| Account IDs (aid) | `<ACCOUNT_ID>` | none found |
| Paths `/home/...`, `/mnt/...`, Windows drive paths | `<HOME>`, `<PATH>` | none found |
| E-mail addresses | `<EMAIL>` | none found |
| Fields named token / apikey / secret / password / webhook / license key (string values) | `"<REDACTED>"` | none found (the word "secrets" in ABPS config.json is a game feature, "secret extracts") |
| Webhook URLs (Discord / Slack) | `<WEBHOOK>` | none found |
| IP addresses except `127.0.0.1` and `0.0.0.0` | `<IP>` | none found |

Files left out entirely for privacy or machine specificity:

* Game options (`SPT_Runtime/user/sptSettings/*.ini`) - game options are not included.
* `OperatorRegistry` config - contains a third-party server address and an installation ID.
* `user/profiles`, `user/profileData`, `user/credentials`, caches, logs, save games.
* `BepInEx/config/FixPluginTypesSerialization.cfg` - machine-specific memory offsets.
* `QuestTracker/config/<profile id>.json`, `botplacementsystem/Data/<profile id>.json` - named after profile IDs.

Final check (`command grep -r` over the finished package for the profile IDs, names, `/home`, `/mnt`,
e-mail pattern, non-local IPs and the secret keywords) returned no hits other than the harmless ones above.
