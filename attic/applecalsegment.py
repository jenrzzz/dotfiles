from __future__ import (unicode_literals, division, absolute_import, print_function)
from powerline.lib.shell import run_cmd


def next_event(pl, format="{title}"):
    event_title = run_cmd(pl, ['/Users/jenner/bin/next-apple-calendar-event'])
    return format.format(title=event_title)
