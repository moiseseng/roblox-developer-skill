# Monetization

The GDD records a stance before any item is designed: cosmetics only, soft pay-to-progress, or hybrid.
Players tolerate paying for time and looks; they punish paying to win against others. Follow the stance;
don't let the shop drift.

## Instruments

| Instrument | Use for | Notes |
|---|---|---|
| **Game Pass** | permanent perks: 2x coins, VIP, extra slot, auto-collect | Check with `MarketplaceService:UserOwnsGamePassAsync` (cache per session; it yields). Promote with `PromptGamePassPurchase`; handle `PromptGamePassPurchaseFinished`. |
| **Developer Product** | consumables: currency packs, skips, revives, boosts | `PromptProductPurchase`; grant in `ProcessReceipt` only. |
| **Subscriptions** | recurring perks | `PromptSubscriptionPurchase`, `GetUserSubscriptionStatusAsync` **(verify availability for your account/region)**. |
| **Premium Payouts** | passive: engagement of Premium users | Design for session time; `PlayerMembershipChanged`, optional Premium perks. |
| **Immersive ads** | ad units in the world | Age/policy constraints **(verify)**; optional, usually later. |

## ProcessReceipt (the only place a product grants)

```lua
MarketplaceService.ProcessReceipt = function(receipt)
	local player = Players:GetPlayerByUserId(receipt.PlayerId)
	if not player then return Enum.ProductPurchaseDecision.NotProcessedYet end
	local profile = DataService.Get(player)
	if not profile then return Enum.ProductPurchaseDecision.NotProcessedYet end
	if profile.purchases[receipt.PurchaseId] then
		return Enum.ProductPurchaseDecision.PurchaseGranted -- idempotent
	end
	local ok = grant(profile, receipt.ProductId) -- from the data table
	if not ok then return Enum.ProductPurchaseDecision.NotProcessedYet end
	profile.purchases[receipt.PurchaseId] = os.time()
	local saved = DataService.SaveNow(player)
	return if saved then Enum.ProductPurchaseDecision.PurchaseGranted else Enum.ProductPurchaseDecision.NotProcessedYet
end
```

Set it once, in MonetizationService. Products and passes live in a data table with id, Robux price (for
display), effect, and the stance category. Prune `purchases` older than ~30 days to keep profiles small.

## Policy

- `PolicyService:GetPolicyInfoForPlayerAsync(player)`: respect `ArePaidRandomItemsRestricted` (no loot
  boxes for those players, or show odds and use an alternative), `AllowedExternalLinkReferences`,
  `IsSubjectToChinaPolicies`, `IsPaidItemTradingAllowed`. Cache per player.
- Paid random items need disclosed odds where allowed at all **(verify current rules)**.
- No misleading store copy, no "free Robux", no gambling with Robux.
- Robux prices display with the Robux icon; the GDD's price proposals are `[PROP]` until the user sets
  them in Creator Hub (the user does that; ids go in `Config`).
- Children-heavy audiences: age guidelines questionnaire affects which features are available; design
  so the game works with purchases unavailable.

## Design guidance

- First purchase offer appears after the player has felt the loop (minute 3 to 10), not at spawn.
- Value framing: show what the pass does in the player's numbers ("+2x: 1 200 → 2 400 /min").
- Soft currency packs sized to the cost curve (one pack ≈ the next meaningful upgrade).
- Never sell the thing the pillar says is earned.
- Everything purchasable has a free path unless it is cosmetic.

## Economics to remember **(verify before quoting)**

Roblox takes a share of each Robux transaction; DevEx converts earned Robux to money at a published
rate; engagement-based payouts reward Premium playtime. Don't quote figures from memory; link the
Creator Docs page.
