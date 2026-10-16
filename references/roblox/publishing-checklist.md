# Publishing checklist (Creator Hub)

The user does the clicks; give them this list filled in with the game's values, in their language, and
wait for confirmation. Items marked (code) are yours.

## Before first publish
- [ ] Place published as **Private** (File → Publish to Roblox), then **Game Settings**.
- [ ] Basic info: name, description (loop in one sentence + controls), genre, icon 512×512 (no text), thumbnails 1920×1080 (3+).
- [ ] Permissions: Private for soft launch → Public at M4.
- [ ] Places: **Max players** per GDD; server fill (default is fine for most).
- [ ] Security: **Enable Studio Access to API Services** (needed to test DataStores in Studio); **Allow HTTP Requests** off unless used; **Third Party Sales** off unless designed.
- [ ] Avatar: R15, scaling, animation overrides per GDD/art bible.
- [ ] Communication: voice chat and camera per GDD; text chat on/off.
- [ ] Monetization: game passes and developer products created with GDD names/prices; **ids copied into `Config.luau`** (code).
- [ ] Age recommendation questionnaire completed honestly (affects distribution and features).
- [ ] Localization: source language set; auto-translate if desired.

## Project file (code)
- [ ] `default.project.json` carries Lighting/StarterPlayer/Workspace settings (not only the place).
- [ ] `Config.Debug = false`; DebugService gated by `RunService:IsStudio()`.
- [ ] Loading screen in `ReplicatedFirst` preloads key assets.
- [ ] Analytics events wired; config flags defaulted for launch.

## Soft launch verification (production)
- [ ] Two accounts, two servers: data saves, loads, no duplicate on rejoin.
- [ ] A real purchase of the cheapest product in production; receipt processed once; refund via Creator Hub test if needed.
- [ ] Phone: first minute, controls, text, safe areas.
- [ ] Console (if GDD): gamepad navigation of all screens.
- [ ] Developer Console on a live server: no error loops; memory stable over 10 minutes.
- [ ] Analytics dashboard shows events within the expected delay.

## Go public
- [ ] Permissions → Public. Social links set. Group ownership if the game belongs to a group (payouts, collaborators).
- [ ] First update already planned (date, content, flag).
- [ ] Watch errors and retention for 48 h; write `docs/gamedev/iteration-brief.md` at day 7.
