#!/usr/bin/env python3
# =============================================================================
# migrate_currency_formatter.py — T11-5a (Task-11 wave)  [v2 — scanner-based]
# -----------------------------------------------------------------------------
# WHAT THIS SCRIPT IS:
#   Mechanical, auditable migration of money-display call sites from manual
#   `X.toStringAsFixed(d)` to the central `CurrencyFormatter.format(X, decimals: d)`
#   (lib/src/helper/currency_formatter.dart). Grouping is added; decimal
#   precision is preserved EXACTLY (the original decimals expression is carried
#   over verbatim as the `decimals:` argument).
#
# WHY v2.1: v2 kept the `?` of a null-aware `?.` inside the receiver slice,
#   producing `expr?` (invalid Dart). v2.1 slices the receiver to end before
#   the `?` while KEEPING `!` for bang receivers (identical null semantics).
#
# EXACTLY WHAT IT DOES (per occurrence of `.toStringAsFixed(`):
#   1. Extract the decimals argument via forward paren matching.
#   2. Extract the receiver via backward scanning:
#        `)`  -> walk to matching `(`, then absorb a leading chain like `a.b!`
#        `]`  -> walk to matching `[`, then absorb the leading chain
#        else -> absorb the identifier chain [A-Za-z0-9_.$!?]*
#      A trailing `?.` marks a NULL-AWARE call and is transformed to
#        (recv != null ? CurrencyFormatter.format(recv, decimals: d) : null)
#      so any surrounding `?? fallback` keeps its exact semantics. Receivers
#      here are pure expressions (tryParse / property chains), so the doubled
#      evaluation is safe. Non-null-aware calls become
#        CurrencyFormatter.format(recv, decimals: d)
#      (format accepts num?, so a previously-crashing null now renders "0").
#   3. Insert the CurrencyFormatter import after the LAST import line, ONLY in
#      files where at least one replacement happened.
#   4. Report per-file counts; sanity: brace balance unchanged per file and no
#      leftover toStringAsFixed in allowlisted files.
#
# SCOPE DECISIONS (documented, deliberate):
#   * Controllers other than the 6 bill controllers are NOT migrated — their
#     toStringAsFixed may feed payloads, not display (zero-risk policy).
#   * remittance/* and exchange/* are NOT migrated — they already use audited,
#     API-driven formatters (RemittanceController.formatAmount, MoneyDisplayText).
#   * travel/* uses its own intl-based rendering — untouched.
# =============================================================================
import sys
from pathlib import Path

ROOT = Path("/home/z/my-project/ecardo_userapp_v1")
IMPORT = "import 'package:ecardo_user/src/helper/currency_formatter.dart';"
SRC = "lib/src/presentation/screens"
MARK = ".toStringAsFixed("
CHAIN_CHARS = set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_.$!?")

ALLOWLIST = [
    # transfer
    f"{SRC}/transfer/view/sub_sections/transfer_review_step_section.dart",
    f"{SRC}/transfer/view/sub_sections/transfer_success_step_section.dart",
    # withdraw
    f"{SRC}/withdraw/view/sub_sections/withdraw_amount_step_section.dart",
    f"{SRC}/withdraw/view/sub_sections/withdraw_review_step_section.dart",
    f"{SRC}/withdraw/view/sub_sections/withdraw_success_step_section.dart",
    # add_money
    f"{SRC}/add_money/view/sub_sections/add_money_amount_step_section.dart",
    f"{SRC}/add_money/view/sub_sections/add_money_review_step_section.dart",
    f"{SRC}/add_money/view/sub_sections/add_money_success_step_section.dart",
    f"{SRC}/add_money/view/sub_sections/add_money_pending_step_section.dart",
    # cash_out
    f"{SRC}/cash_out/view/sub_sections/cash_out_review_step_section.dart",
    f"{SRC}/cash_out/view/sub_sections/cash_out_success_step_section.dart",
    # make_payment
    f"{SRC}/make_payment/view/sub_sections/make_payment_review_step_section.dart",
    f"{SRC}/make_payment/view/sub_sections/make_payment_success_step_section.dart",
    # request_money
    f"{SRC}/request_money/view/sub_sections/request_money_review_step_section.dart",
    f"{SRC}/request_money/view/sub_sections/request_money_success_step_section.dart",
    f"{SRC}/request_money/view/received_request/received_request.dart",
    f"{SRC}/request_money/view/received_request/sub_sections/received_request_details.dart",
    f"{SRC}/request_money/view/received_request/sub_sections/accept_request_dropdown.dart",
    f"{SRC}/request_money/view/request_money_history/request_money_history.dart",
    f"{SRC}/request_money/view/request_money_history/sub_sections/request_money_history_details.dart",
    # gift_code + gift_card
    f"{SRC}/gift_code/view/sub_sections/create_gift_review_section.dart",
    f"{SRC}/gift_code/view/sub_sections/create_gift_success_step_section.dart",
    f"{SRC}/gift_code/view/sub_sections/gift_history.dart",
    f"{SRC}/gift_code/view/gift_redeem_history/gift_redeem_history.dart",
    f"{SRC}/gift_card/view/sub_sections/gift_card_review_details_section.dart",
    # bill_payment views (6 services) + review sections + controllers
    *[f"{SRC}/bill_payment/view/{s}/{s}.dart" for s in
      ("airtime", "cable", "data_bundle", "electricity", "internet", "toll")],
    *[f"{SRC}/bill_payment/view/{s}/sub_sections/{s}_review_step_section.dart" for s in
      ("airtime", "cable", "data_bundle", "electricity", "internet", "toll")],
    *[f"{SRC}/bill_payment/controller/{s}_controller.dart" for s in
      ("airtime", "cable", "data_bundle", "electricity", "internet", "toll")],
    # p2p
    f"{SRC}/p2p/widgets/p2p_ad_card.dart",
]


def match_backward(s: str, i: int, open_ch: str, close_ch: str) -> int:
    """s[i] == close_ch; return index of the matching open_ch, or -1."""
    depth = 0
    while i >= 0:
        c = s[i]
        if c == close_ch:
            depth += 1
        elif c == open_ch:
            depth -= 1
            if depth == 0:
                return i
        i -= 1
    return -1


def absorb_chain(s: str, i: int) -> tuple[str, int]:
    """Absorb a dotted/nullable identifier chain ending at index i (inclusive).
    Returns (chain, index_of_first_char_of_chain - 1)."""
    j = i
    while j >= 0 and s[j] in CHAIN_CHARS:
        j -= 1
    return s[j + 1:i + 1], j


def find_receiver(s: str, dot_pos: int) -> tuple[str, int, bool]:
    """Receiver expression ends just before s[dot_pos] (which is '.').
    Returns (receiver_text, start_index, null_aware).
    Trailing operator handling: `?` of a null-aware `?.` is EXCLUDED from the
    receiver (it is the operator marker); a bang `!` is KEPT inside the
    receiver so the original crash-on-null semantics are preserved."""
    i = dot_pos - 1
    null_aware = False
    while i >= 0 and s[i] in "?!":
        if s[i] == "?":
            null_aware = True
        i -= 1
    # i now points at the last receiver character (or -1)
    end_inclusive = i
    if i >= 0 and s[i] == ")":
        opener = match_backward(s, i, "(", ")")
        if opener < 0:
            raise RuntimeError("unbalanced parens at %d" % dot_pos)
        chain, j = absorb_chain(s, opener - 1)
        start = j + 1
    elif i >= 0 and s[i] == "]":
        opener = match_backward(s, i, "[", "]")
        if opener < 0:
            raise RuntimeError("unbalanced brackets at %d" % dot_pos)
        chain, j = absorb_chain(s, opener - 1)
        start = j + 1
    else:
        chain, j = absorb_chain(s, i)
        start = j + 1
    # null-aware: receiver ends BEFORE the `?`; otherwise keep through dot_pos-1
    receiver_end = (end_inclusive + 1) if null_aware else dot_pos
    receiver = s[start:receiver_end]
    return receiver, start, null_aware


def transform_text(src: str, rel: str) -> tuple[str, int]:
    out = []
    pos = 0
    count = 0
    while True:
        k = src.find(MARK, pos)
        if k < 0:
            out.append(src[pos:])
            break
        dot_pos = k  # s[k] == '.'
        name_start = k + 1
        assert src[name_start:].startswith("toStringAsFixed")
        open_paren = name_start + len("toStringAsFixed")
        # forward match of the argument parens
        depth = 0
        p = open_paren
        while p < len(src):
            if src[p] == "(":
                depth += 1
            elif src[p] == ")":
                depth -= 1
                if depth == 0:
                    break
            p += 1
        if depth != 0:
            raise RuntimeError("unbalanced args at %s:%d" % (rel, k))
        args = src[open_paren + 1:p].strip()

        receiver, start, null_aware = find_receiver(src, dot_pos)
        recv_clean = receiver.strip()
        if null_aware:
            replacement = (
                f"({recv_clean} != null ? "
                f"CurrencyFormatter.format({recv_clean}, decimals: {args}) : null)"
            )
        else:
            replacement = f"CurrencyFormatter.format({recv_clean}, decimals: {args})"

        out.append(src[pos:start])
        out.append(replacement)
        pos = p + 1
        count += 1
    return "".join(out), count


def migrate(rel: str) -> int:
    path = ROOT / rel
    if not path.exists():
        print(f"MISSING (report): {rel}")
        return -1
    src = path.read_text(encoding="utf-8")
    if MARK not in src:
        return 0
    before_braces = src.count("{") - src.count("}")
    before_parens = src.count("(") - src.count(")")
    new_src, n = transform_text(src, rel)
    after_braces = new_src.count("{") - new_src.count("}")
    after_parens = new_src.count("(") - new_src.count(")")
    if before_braces != after_braces or before_parens != after_parens:
        print(f"BALANCE FAIL (skipped, manual review needed): {rel}")
        return -1
    if IMPORT not in new_src:
        lines = new_src.splitlines(keepends=True)
        last_import = max(i for i, ln in enumerate(lines) if ln.startswith("import "))
        lines.insert(last_import + 1, IMPORT + "\n")
        new_src = "".join(lines)
    path.write_text(new_src, encoding="utf-8")
    print(f"{n:2d} site(s) migrated -> {rel}")
    return n


def main() -> int:
    ok = True
    grand = 0
    changed = 0
    for rel in ALLOWLIST:
        n = migrate(rel)
        if n < 0:
            ok = False
            continue
        grand += n
        changed += 1 if n > 0 else 0
    print("-" * 60)
    print(f"files changed: {changed} / allowlisted: {len(ALLOWLIST)}")
    print(f"total sites migrated: {grand}")
    leftovers = [rel for rel in ALLOWLIST
                 if (ROOT / rel).exists() and MARK in (ROOT / rel).read_text(encoding="utf-8")]
    if leftovers:
        print("LEFTOVER .toStringAsFixed( (manual review):")
        for rel in leftovers:
            print(f"  - {rel}")
    print("SANITY: " + ("CLEAN" if not leftovers else f"{len(leftovers)} file(s) with leftovers"))
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
