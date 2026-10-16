# UI and UX

## Layout rules

- **Scale, not offset,** for everything that must fit every screen: `Size = UDim2.fromScale`,
  `AnchorPoint`, `UIAspectRatioConstraint` for things that must keep shape, `UISizeConstraint` for min/max.
  Offset only for hairlines and padding.
- **Safe areas**: `ScreenGui.IgnoreGuiInset = false` unless full-screen art; keep interactive elements
  out of the top-left (Roblox menu) and respect notches via `GuiService:GetGuiInset()` and
  `ScreenGui.SafeAreaCompatibility`.
- **Touch targets ≥ 44 px** at 1x, with `UIPadding`; mobile jump/thumbstick regions (bottom corners)
  stay free of custom buttons.
- **Text**: `TextScaled` with `UITextSizeConstraint` (min 14, max ~40), one font family, 3 sizes
  (title, body, label). `RichText` for inline emphasis. Localize via `LocalizationService` when the GDD
  lists more than one language.
- **Z-order and layering**: one `ScreenGui` per screen with `DisplayOrder`; `ZIndexBehavior = Sibling`.
- **Screens are data-driven**: a controller shows/hides a screen; content comes from attributes and shared
  tables. No gameplay logic in UI code.

## Input

- Support mouse+keyboard, touch and gamepad from M1. `UserInputService` + `ContextActionService` for
  actions with on-screen touch buttons (`CreateButton`), `GuiService.SelectedObject` and
  `NextSelectionUp/Down` for gamepad navigation of menus; test every screen with a controller if the
  GDD lists console.
- Use `UserInputService.TouchEnabled`/`GamepadEnabled` to adapt prompts ("Toca" vs "Pulsa E").
- Camera: `CameraMaxZoomDistance`, custom camera only when the GDD demands it; mobile users rotate
  with a drag so keep buttons off the right half when a custom camera needs drag.

## Onboarding (first 60 seconds)

Minute 0 to 1 decides retention more than anything else. Pattern that works on Roblox:

1. Spawn facing the first action, within 3 seconds of join (loading screen covers the rest).
2. One prompt, one verb ("Recoge la gema"), with an arrow/beam to it. No wall of text.
3. First reward in under 30 seconds, first purchase affordable in under 1 minute.
4. Tutorial steps are attributes on the player (`TutorialStep`) so they persist and QA can set them.
5. Skip for returning players; never gate the hub.

Track the funnel with analytics events per step (see `analytics-liveops.md`).

## Feedback

Every action has three channels: visual (tween, particle, color flash), audio (short SFX), UI (number
pop, bar fill). Tweens via `TweenService` with 0.1 to 0.3 s for UI; `Sound` with slight pitch
variation. Juice is cheap; use it on the core loop first.

## Accessibility

Color is never the only signal (icon or shape too); flashing under 3 Hz; text contrast ≥ 4.5:1; an
option to reduce motion/particles; subtitles for any voice.

## Checklist for QA

Each screen on phone (portrait is not supported by most games; landscape only), tablet, PC 1080p,
gamepad: readable, reachable, no overlap with Roblox core UI, back/close always available, state after
rejoin correct.
