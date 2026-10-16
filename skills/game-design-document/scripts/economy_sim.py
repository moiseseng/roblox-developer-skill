#!/usr/bin/env python3
"""Greedy-player economy simulator for a GDD. Dependency-free.

Usage:
  economy_sim.py --example                 # print an example spec (JSON) to start from
  economy_sim.py --spec docs/gamedev/economy.json [--minutes 30] [--markdown]

Spec (JSON):
{
  "currency": "goo",
  "start_balance": 0,
  "income_per_sec": "2 * (1 + 0.5 * level)",     # Python expression of `level` and `pots`
  "upgrades": [
    {"name": "seed", "var": "level", "cost": "40 * 1.7 ** n", "max": 20},
    {"name": "pot",  "var": "pots",  "cost": "120 * 1.8 ** n", "max": 6, "start": 1}
  ],
  "offline_cap_hours": 8,
  "offline_rate": 0.125,
  "report_levels": [1, 2, 3, 5, 10]
}
A greedy player buys the cheapest affordable upgrade every second. `n` in a cost expression is the
number already bought of that upgrade. The report shows minute by minute what they own and can afford,
when each upgrade level is reached, and whether time-to-next-purchase stays bounded.
"""
import argparse
import json
import math
import sys

EXAMPLE = {
    "currency": "goo",
    "start_balance": 0,
    "income_per_sec": "2 * (1 + 0.5 * level) * pots",
    "upgrades": [
        {"name": "seed", "var": "level", "cost": "40 * 1.7 ** n", "max": 20},
        {"name": "pot", "var": "pots", "cost": "120 * 1.8 ** n", "max": 6, "start": 1},
    ],
    "offline_cap_hours": 8,
    "offline_rate": 0.125,
    "report_levels": [1, 2, 3, 5, 10],
}


def evaluate(expr, **names):
    env = {"math": math, "min": min, "max": max, "floor": math.floor, "ceil": math.ceil}
    env.update(names)
    return float(eval(expr, {"__builtins__": {}}, env))  # spec is author-controlled


def simulate(spec, minutes):
    state = {u["var"]: int(u.get("start", 0)) for u in spec["upgrades"]}
    bought = {u["name"]: int(u.get("start", 0)) for u in spec["upgrades"]}
    balance = float(spec.get("start_balance", 0))
    seconds = int(minutes * 60)
    rows, reached, gaps = [], {}, []
    for u in spec["upgrades"]:
        if int(u.get("start", 0)) > 0:
            reached[(u["name"], int(u["start"]))] = 0
    last_purchase = 0
    for sec in range(seconds + 1):
        if sec > 0:
            balance += evaluate(spec["income_per_sec"], **state)
        # greedy: cheapest affordable upgrade first, repeat while affordable
        while True:
            options = []
            for u in spec["upgrades"]:
                if bought[u["name"]] >= u.get("max", 10**9):
                    continue
                cost = evaluate(u["cost"], n=bought[u["name"]], **state)
                options.append((cost, u))
            options.sort(key=lambda o: o[0])
            if not options or options[0][0] > balance:
                break
            cost, u = options[0]
            balance -= cost
            bought[u["name"]] += 1
            state[u["var"]] = bought[u["name"]]
            reached.setdefault((u["name"], bought[u["name"]]), sec)
            gaps.append(sec - last_purchase)
            last_purchase = sec
        if sec % 60 == 0:
            cheapest = None
            for u in spec["upgrades"]:
                if bought[u["name"]] < u.get("max", 10**9):
                    c = evaluate(u["cost"], n=bought[u["name"]], **state)
                    cheapest = c if cheapest is None else min(cheapest, c)
            rows.append({
                "minute": sec // 60,
                "balance": balance,
                "income_per_min": evaluate(spec["income_per_sec"], **state) * 60,
                "owned": dict(bought),
                "next_cost": cheapest,
            })
    return rows, reached, gaps, bought


def fmt(x):
    if x is None:
        return "—"
    if x >= 1e6:
        return f"{x/1e6:.2f}M"
    if x >= 1e3:
        return f"{x/1e3:.1f}K"
    return f"{x:.0f}"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--spec")
    ap.add_argument("--minutes", type=float, default=30)
    ap.add_argument("--example", action="store_true")
    ap.add_argument("--markdown", action="store_true", help="markdown tables (default: plain)")
    a = ap.parse_args()
    if a.example:
        print(json.dumps(EXAMPLE, indent=2))
        return 0
    if not a.spec:
        ap.error("--spec or --example required")
    spec = json.load(open(a.spec, encoding="utf-8"))
    rows, reached, gaps, bought = simulate(spec, a.minutes)
    cur = spec.get("currency", "coins")
    names = [u["name"] for u in spec["upgrades"]]
    sep = " | " if a.markdown else "  "
    head = ["min", f"{cur}", f"{cur}/min"] + names + ["next cost"]
    print(sep.join(head))
    if a.markdown:
        print("|".join(["---"] * len(head)))
    for r in rows:
        print(sep.join([str(r["minute"]), fmt(r["balance"]), fmt(r["income_per_min"])]
                       + [str(r["owned"][n]) for n in names] + [fmt(r["next_cost"])]))
    print()
    print("Reached:")
    for u in spec["upgrades"]:
        for lvl in spec.get("report_levels", [1, 5, 10, 20]):
            t = reached.get((u["name"], lvl))
            print(f"  {u['name']} {lvl}: " + (f"{t/60:.1f} min" if t is not None else f"not within {a.minutes:g} min"))
    if gaps:
        print(f"Purchases: {len(gaps)}; longest wait between purchases: {max(gaps)/60:.1f} min; "
              f"first purchase at {gaps[0]/60:.1f} min")
    if "offline_cap_hours" in spec:
        inc = rows[-1]["income_per_min"] * 60
        offline = inc * spec["offline_cap_hours"] * spec.get("offline_rate", 1.0)
        print(f"Offline (cap {spec['offline_cap_hours']} h at rate {spec.get('offline_rate', 1.0)}): "
              f"≈ {fmt(offline)} {cur} on return, vs next cost {fmt(rows[-1]['next_cost'])}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
