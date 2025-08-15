#!/usr/bin/env bash

set -euo pipefail

QMLFORMAT_BIN=${QMLFORMAT_BIN:-qmlformat}
TMPDIR=$(mktemp -d)

find . -type f -name "*.qml" | while read -r file; do
    original="$file"
    tmp="$TMPDIR/formatted.qml"
    pragmas="$TMPDIR/pragmas.txt"
    errfile="$TMPDIR/qmlformat.err"

    grep '^pragma ' "$original" > "$pragmas" || true
    grep -v '^pragma ' "$original" > "$tmp"

    if ! "$QMLFORMAT_BIN" -i "$tmp" 2> "$errfile"; then
        echo "$original:"
        cat "$errfile"
        echo

        # Extract all line numbers from error log
        grep -oE 'formatted\.qml:([0-9]+)' "$errfile" | cut -d: -f2 | sort -n | uniq | while read -r lineno; do
            echo "---- formatted.qml line $lineno (with context) ----"
            # Show 2 lines before and after, numbering all lines
            start=$((lineno - 2))
            end=$((lineno + 2))
            sed -n "${start},${end}p" "$tmp" | nl -ba
            echo
        done

        echo "---- end of $original ----"
        echo
        continue
    fi

    if [[ -s "$pragmas" ]]; then
        { cat "$pragmas"; echo; cat "$tmp"; } > "$original"
    else
        cat "$tmp" > "$original"
    fi
done

rm -rf "$TMPDIR"
