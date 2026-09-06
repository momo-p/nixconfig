"""Expand subscribed iCal feeds into the flat cache the shell reads."""

import json
import os
import sys
import time
import urllib.request
from datetime import date, datetime, timedelta

import icalendar
import recurring_ical_events

SOURCES = os.environ.get("AGENDA_SOURCES", "/run/secrets/ical")
OUT = os.environ["AGENDA_CACHE"]
# the grid shows a whole month, so cover it from the first rather than from
# today, and look far enough ahead to fill the next one
DAYS = int(os.environ.get("AGENDA_DAYS", "60"))

events = []
ok = 0
failed = 0

if os.path.exists(SOURCES):
    with open(SOURCES) as fh:
        lines = [ln.strip() for ln in fh]

    for line in lines:
        if not line or line.startswith("#"):
            continue
        # a url never contains a space, so split from the right and let the
        # name keep any it has
        name, _, url = line.rpartition(" ")
        name = name.strip() or "calendar"
        if not url:
            continue

        # one unreachable feed must not take the others down with it
        try:
            raw = urllib.request.urlopen(url, timeout=20).read()
            cal = icalendar.Calendar.from_ical(raw)
            today = date.today()
            found = recurring_ical_events.of(cal).between(today.replace(day=1), today + timedelta(days=DAYS))
        except Exception as err:
            print(f"{name}: {err}", file=sys.stderr)
            failed += 1
            continue

        for ev in found:
            when = ev["DTSTART"].dt
            timed = isinstance(when, datetime)
            if timed:
                when = when.astimezone()
            events.append({
                "date": (when.date() if timed else when).isoformat(),
                "time": when.strftime("%H:%M") if timed else "",
                "title": str(ev.get("SUMMARY", "")).strip(),
                "cal": name,
            })
        ok += 1

# keep yesterday's answer rather than replacing it with nothing
if failed and not ok:
    sys.exit(f"every feed failed ({failed}), keeping the previous cache")

events.sort(key=lambda e: (e["date"], e["time"]))

tmp = OUT + ".tmp"
with open(tmp, "w") as fh:
    json.dump({"events": events, "ts": int(time.time())}, fh)
os.replace(tmp, OUT)
