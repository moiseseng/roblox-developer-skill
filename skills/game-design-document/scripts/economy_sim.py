#!/usr/bin/env python3
"""Greedy-player economy simulator for a GDD. Dependency-free.

Usage:
  economy_sim.py --example                 # print an example spec (JSON) to start from
  economy_sim.py --spec docs/gamedev/economy.json [--minutes 30] [--markdown]

Spec (JSON):
{
  "currency": "goo",
  "start_balance": 0,
  "income_per_sec": "2 * (1 + 0.5 * level) * pots",   # arithmetic expression of the upgrade variables
  "upgrades": [
    {"name": "seed", "var": "level", "cost": "40 * 1.7 ** n", "max": 20},
    {"name": "pot",  "var": "pots",  "cost": "120 * 1.8 ** n", "max": 6, "start": 1}
  ],
  "offline_cap_hours": 8,
  "offline_rate": 0.125,
  "report_levels": [1, 2, 3, 5, 10]
}
A greedy player buys the cheapest affordable upgrade every second. `n` in a cost expression is the
number already bought of that upgrade (the first purchase is n = 0, matching Economy.upgradeCost(level)).
Expressions allow numbers, + - * / // % **, parentheses, the upgrade variables, `n`, and the functions
min max abs floor ceil sqrt log log2 log10 exp pow round. Nothing else is evaluated.
"""
import argparse
import ast
import json
import math
import operator
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

DEFAULT_MAX = 1000
BIN_OPS = {ast.Add: operator.add, ast.Sub: operator.sub, ast.Mult: operator.mul, ast.Div: operator.truediv,
           ast.FloorDiv: operator.floordiv, ast.Mod: operator.mod, ast.Pow: operator.pow}
UNARY_OPS = {ast.USub: operator.neg, ast.UAdd: operator.pos}
FUNCS = {"min": min, "max": max, "abs": abs, "floor": math.floor, "ceil": math.ceil, "sqrt": math.sqrt,
         "log": math.log, "log2": math.log2, "log10": math.log10, "exp": math.exp, "pow": math.pow, "round": round}


class SpecError(Exception):
    pass


def compile_expr(expr):
    """Parse an arithmetic expression into a closure over a names dict. Whitelisted AST only."""
    try:
        tree = ast.parse(str(expr), mode="eval")
    except SyntaxError as e:
        raise SpecError(f"cannot parse expression {expr!r}: {e.msg}")

    def build(node):
        if isinstance(node, ast.Expression):
            return build(node.body)
        if isinstance(node, ast.Constant) and isinstance(node.value, (int, float)) and not isinstance(node.value, bool):
            v = float(node.value)
            return lambda names: v
        if isinstance(node, ast.Name):
            name = node.id
            return lambda names: _lookup(names, name, expr)
        if isinstance(node, ast.BinOp) and type(node.op) in BIN_OPS:
            left, right, op = build(node.left), build(node.right), BIN_OPS[type(node.op)]
            return lambda names: op(left(names), right(names))
        if isinstance(node, ast.UnaryOp) and type(node.op) in UNARY_OPS:
            operand, op = build(node.operand), UNARY_OPS[type(node.op)]
            return lambda names: op(operand(names))
        if isinstance(node, ast.Call) and isinstance(node.func, ast.Name) and node.func.id in FUNCS and not node.keywords:
            fn, args = FUNCS[node.func.id], [build(a) for a in node.args]
            return lambda names: fn(*(a(names) for a in args))
        raise SpecError(f"unsupported syntax in expression {expr!r}: {ast.dump(node)[:40]}")

    fn = build(tree)

    def evaluate(**names):
        try:
            value = fn(names)
        except ZeroDivisionError:
            raise SpecError(f"division by zero in {expr!r} with {names}")
        except (OverflowError, ValueError) as e:
            raise SpecError(f"math error in {expr!r} with {names}: {e}")
        if isinstance(value, complex) or value != value:
            raise SpecError(f"expression {expr!r} produced a non-real value with {names}")
        return float(value)

    return evaluate


def _lookup(names, name, expr):
    if name not in names:
        raise SpecError(f"unknown name {name!r} in {expr!r}; known: {sorted(names)}")
    return names[name]


def validate(spec):
    for key in ("income_per_sec", "upgrades"):
        if key not in spec:
            raise SpecError(f"spec is missing {key!r}")
    if not isinstance(spec["upgrades"], list) or not spec["upgrades"]:
        raise SpecError("upgrades must be a non-empty list")
    for u in spec["upgrades"]:
        for key in ("name", "var", "cost"):
            if key not in u:
                raise SpecError(f"upgrade {u} is missing {key!r}")


def simulate(spec, minutes):
    validate(spec)
    if minutes <= 0:
        raise SpecError("--minutes must be positive")
    income = compile_expr(spec["income_per_sec"])
    costs = {u["name"]: compile_expr(u["cost"]) for u in spec["upgrades"]}
    state = {u["var"]: int(u.get("start", 0)) for u in spec["upgrades"]}
    bought = {u["name"]: int(u.get("start", 0)) for u in spec["upgrades"]}
    maxes = {u["name"]: int(u.get("max", DEFAULT_MAX)) for u in spec["upgrades"]}
    balance = float(spec.get("start_balance", 0))
    seconds = int(minutes * 60)
    rows, reached, gaps = [], {}, []
    for u in spec["upgrades"]:
        if int(u.get("start", 0)) > 0:
            reached[(u["name"], int(u["start"]))] = 0
    last_purchase = 0

    def cost_of(u):
        c = costs[u["name"]](n=bought[u["name"]], **state)
        if c <= 0:
            raise SpecError(f"cost of {u['name']!r} is {c} at n={bought[u['name']]}; costs must be positive")
        return c

    for sec in range(seconds + 1):
        if sec > 0:
            inc = income(**state)
            if inc < 0:
                raise SpecError(f"income is negative ({inc}) with {state}")
            balance += inc
        while True:
            options = sorted((cost_of(u), u) for u in spec["upgrades"] if bought[u["name"]] < maxes[u["name"]])
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
            cheapest = min((cost_of(u) for u in spec["upgrades"] if bought[u["name"]] < maxes[u["name"]]), default=None)
            rows.append({"minute": sec // 60, "balance": balance, "income_per_min": income(**state) * 60,
                         "owned": dict(bought), "next_cost": cheapest})
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
    ap.add_argument("--markdown", action="store_true", help="emit a markdown table (paste into the GDD)")
    a = ap.parse_args()
    if a.example:
        print(json.dumps(EXAMPLE, indent=2))
        return 0
    if not a.spec:
        ap.error("--spec or --example required")
    try:
        with open(a.spec, encoding="utf-8") as f:
            spec = json.load(f)
    except (OSError, json.JSONDecodeError) as e:
        print(f"error: cannot read spec: {e}", file=sys.stderr)
        return 2
    try:
        rows, reached, gaps, bought = simulate(spec, a.minutes)
    except SpecError as e:
        print(f"error: {e}", file=sys.stderr)
        return 2
    cur = spec.get("currency", "coins")
    names = [u["name"] for u in spec["upgrades"]]
    head = ["min", f"{cur}", f"{cur}/min"] + names + ["next cost"]

    def line(cells):
        return "| " + " | ".join(cells) + " |" if a.markdown else "  ".join(cells)

    print(line(head))
    if a.markdown:
        print("|" + "---|" * len(head))
    for r in rows:
        print(line([str(r["minute"]), fmt(r["balance"]), fmt(r["income_per_min"])]
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
    else:
        print("warning: no purchase was ever affordable; income or costs are off by orders of magnitude")
    if "offline_cap_hours" in spec:
        inc = rows[-1]["income_per_min"] * 60
        offline = inc * float(spec["offline_cap_hours"]) * float(spec.get("offline_rate", 1.0))
        print(f"Offline (cap {spec['offline_cap_hours']} h at rate {spec.get('offline_rate', 1.0)}): "
              f"≈ {fmt(offline)} {cur} on return, vs next cost {fmt(rows[-1]['next_cost'])}")
        nxt = rows[-1]["next_cost"]
        if nxt and offline > 3 * nxt:
            print("  warning: offline return exceeds 3x the next cost; the return moment buys everything at once "
                  "and the session has no goal. Lower the cap or rate, or make the next cost scale with time away.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
