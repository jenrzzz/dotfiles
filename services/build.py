#!/usr/bin/env python3
"""Install macOS Quick Action (Services menu) .workflow bundles.

These are text services: select text in any app, right-click -> Services ->
<name>, and the selection is piped (stdin) through a shell script. Output is
handled by the script itself (here: convert + paste rich text), so the workflow
declares no return type.

This script is the source of truth AND the installer. It writes *real* bundle
files straight into ~/Library/Services/ (default) -- NOT symlinks. That matters:
sandboxed apps like Notes.app refuse to follow a symlink out to ~/.dotfiles
(outside their container), so the service must be real files at a path the
sandbox allows. This is why `services` is not a stow package.

Usage:
    python3 build.py            # install into ~/Library/Services and flush cache
    python3 build.py --out DIR  # write bundles into DIR instead (e.g. to inspect)

macOS-only (relies on the system python3, which is always present).
"""
import os
import sys
import uuid
import plistlib
import subprocess

DEFAULT_OUT = os.path.expanduser("~/Library/Services")

# --- service definitions ----------------------------------------------------
# Each entry -> one "<name>.workflow" bundle. `script` runs with the selected
# text on stdin (bash). Add more entries here for new text services.
SERVICES = [
    {
        "name": "Render Markdown",
        "script": r'''#!/bin/bash
# Render Markdown: selected Markdown text (on stdin) -> rich text pasted back.

# 1. Find a Markdown -> HTML converter (prefer cmark-gfm for tables/GFM).
GFM=""
for c in /opt/homebrew/bin/cmark-gfm /usr/local/bin/cmark-gfm; do
  [ -x "$c" ] && GFM="$c" && break
done
[ -z "$GFM" ] && GFM="$(command -v cmark-gfm 2>/dev/null || true)"

MD=""
for c in /opt/homebrew/bin/markdown /usr/local/bin/markdown; do
  [ -x "$c" ] && MD="$c" && break
done
[ -z "$MD" ] && MD="$(command -v markdown 2>/dev/null || true)"

tmp="$(mktemp -t rendermd)"

# 2. Markdown -> HTML. cmark-gfm gives tables, strikethrough, task lists,
#    fenced code and autolinks; Markdown.pl is a fallback; <pre> is last resort.
if [ -n "$GFM" ]; then
  "$GFM" -e table -e strikethrough -e autolink -e tasklist -e tagfilter > "$tmp.html"
elif [ -n "$MD" ]; then
  "$MD" > "$tmp.html"
else
  { printf '<pre>'; cat; printf '</pre>'; } > "$tmp.html"
fi

# 3. Add a blank line between adjacent paragraphs (double-spaced look). Only
#    touches paragraph->paragraph boundaries, so headings/lists/tables keep
#    their normal spacing. The &#160; (nbsp) keeps the empty paragraph from
#    being collapsed.
/usr/bin/perl -0777 -i -pe 's{</p>\s*<p>}{</p>\n<p>&#160;</p>\n<p>}g' "$tmp.html"

# 4. HTML -> RTF via built-in textutil (renders tables as real RTF tables).
/usr/bin/textutil -convert rtf -format html -inputencoding UTF-8 "$tmp.html" -output "$tmp.rtf"

# 5. Put the RTF on the clipboard and paste it over the selection.
/usr/bin/osascript <<OSA
set the clipboard to (read (POSIX file "$tmp.rtf") as «class RTF »)
delay 0.15
tell application "System Events" to keystroke "v" using command down
OSA

rm -f "$tmp" "$tmp.html" "$tmp.rtf"
''',
    },
]


def build_workflow(script: str) -> dict:
    """Return the document.wflow plist for a Run Shell Script quick action."""
    action = {
        "action": {
            "AMAccepts": {
                "Container": "List",
                "Optional": True,
                "Types": ["com.apple.cocoa.string"],
            },
            "AMActionVersion": "2.0.3",
            "AMApplication": ["Automator"],
            "AMParameterProperties": {
                "COMMAND_STRING": {},
                "CheckedForUserDefaultShell": {},
                "inputMethod": {},
                "shell": {},
                "source": {},
            },
            "AMProvides": {
                "Container": "List",
                "Types": ["com.apple.cocoa.string"],
            },
            "ActionBundlePath": "/System/Library/Automator/Run Shell Script.action",
            "ActionName": "Run Shell Script",
            "ActionParameters": {
                "COMMAND_STRING": script,
                "CheckedForUserDefaultShell": True,
                "inputMethod": 0,  # 0 = pass input to stdin
                "shell": "/bin/bash",
                "source": "",
            },
            "BundleIdentifier": "com.apple.RunShellScript",
            "CFBundleVersion": "2.0.3",
            "CanShowSelectedItemsWhenRun": False,
            "CanShowWhenRun": True,
            "Category": ["AMCategoryUtilities"],
            "Class Name": "RunShellScriptAction",
            "InputUUID": str(uuid.uuid4()).upper(),
            "Keywords": ["Shell", "Script", "Command", "Run", "Unix"],
            "OutputUUID": str(uuid.uuid4()).upper(),
            "UUID": str(uuid.uuid4()).upper(),
            "UnlocalizedApplications": ["Automator"],
            "arguments": {},
            "isViewVisible": 1,
            "location": "309.000000:253.000000",
            "nibPath": "/System/Library/Automator/Run Shell Script.action/Contents/Resources/Base.lproj/main.nib",
        },
        "isViewVisible": 1,
    }
    return {
        "AMApplicationBuild": "521",
        "AMApplicationVersion": "2.10",
        "AMDocumentVersion": "2",
        "actions": [action],
        "connectors": {},
        "workflowMetaData": {
            "applicationBundleIDsByPath": {},
            "applicationPaths": [],
            "inputTypeIdentifier": "com.apple.Automator.text",
            "outputTypeIdentifier": "com.apple.Automator.nothing",
            "presentationMode": 11,
            "processesInput": 0,
            "serviceApplicationBundleID": "",
            "serviceApplicationPath": "",
            "serviceInputTypeIdentifier": "com.apple.Automator.text",
            "serviceOutputTypeIdentifier": "com.apple.Automator.nothing",
            "serviceProcessesInput": 0,
            "systemImageName": "NSTouchBarTextListTemplate",
            "useAutomaticInputType": 0,
            "workflowTypeIdentifier": "com.apple.Automator.servicesMenu",
        },
    }


def build_info(name: str) -> dict:
    """Return the Info.plist registering the service in the Services menu."""
    return {
        "NSServices": [
            {
                "NSMenuItem": {"default": name},
                "NSMessage": "runWorkflowAsService",
                "NSRequiredContext": {"NSTextContent": "Text"},
                "NSSendFileTypes": [],
                "NSSendTypes": ["NSStringPboardType"],
            }
        ]
    }


def main(argv: list) -> None:
    out = DEFAULT_OUT
    if "--out" in argv:
        out = os.path.abspath(argv[argv.index("--out") + 1])
    os.makedirs(out, exist_ok=True)

    for svc in SERVICES:
        name = svc["name"]
        contents = os.path.join(out, f"{name}.workflow", "Contents")
        os.makedirs(contents, exist_ok=True)
        with open(os.path.join(contents, "document.wflow"), "wb") as f:
            plistlib.dump(build_workflow(svc["script"]), f)
        with open(os.path.join(contents, "Info.plist"), "wb") as f:
            plistlib.dump(build_info(name), f)
        print(f"installed: {os.path.join(out, name + '.workflow')}")

    # Refresh the Services menu when we wrote to the live location on macOS.
    if out == DEFAULT_OUT and sys.platform == "darwin":
        subprocess.run(
            ["/System/Library/CoreServices/pbs", "-flush"],
            check=False,
            stderr=subprocess.DEVNULL,
        )


if __name__ == "__main__":
    main(sys.argv[1:])
