#!/usr/bin/env python3
"""Static validator for rental_performance_analysis.sql.

Parses every statement in the analysis script under the MySQL dialect
without needing a running database. This catches syntax errors, missing
terminators, and dialect issues before the script is run against a real
Sakila instance.

Usage:
    pip install sqlglot
    python validate_sql.py

Exits 0 if all statements parse, 1 otherwise.
"""
from __future__ import annotations

import os
import sys

SCRIPT = os.path.join(
    os.path.dirname(os.path.abspath(__file__)),
    "rental_performance_analysis.sql",
)


def main() -> int:
    try:
        import sqlglot
        from sqlglot.errors import ParseError
    except ImportError:
        print("sqlglot is required: pip install sqlglot", file=sys.stderr)
        return 2

    with open(SCRIPT, encoding="utf-8") as handle:
        sql = handle.read()

    try:
        statements = [s for s in sqlglot.parse(sql, read="mysql") if s is not None]
    except ParseError as exc:
        print(f"FAIL: could not parse {os.path.basename(SCRIPT)}", file=sys.stderr)
        print(exc, file=sys.stderr)
        return 1

    # Re-serialize each statement so structural (not just tokenization)
    # problems surface.
    for index, statement in enumerate(statements, start=1):
        try:
            statement.sql(dialect="mysql")
        except Exception as exc:  # noqa: BLE001 - report any rendering failure
            print(f"FAIL: statement {index} did not re-serialize: {exc}", file=sys.stderr)
            return 1

    selects = sum(1 for s in statements if s.key == "select")
    print(f"OK: {len(statements)} statements parsed ({selects} SELECT) under the mysql dialect")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
