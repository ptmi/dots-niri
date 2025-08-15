#!/usr/bin/env bash

# https://github.com/jesperhh/qmlfmt
find . -name "*.qml" -exec qmlfmt -t 2 -i 2 -w {} \;
