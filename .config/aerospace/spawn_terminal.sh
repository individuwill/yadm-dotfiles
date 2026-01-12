#!/bin/bash

# Define the order of preference
if open -Ra "Ghostty" >/dev/null 2>&1; then
    open -n -a "Ghostty"
elif open -Ra "iTerm" >/dev/null 2>&1; then
    open -n -a "iTerm"
else
    open -n -a "Terminal"
fi
