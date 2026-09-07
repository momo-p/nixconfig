pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import "."

// quickshell is the notification daemon itself, so every change arrives as a
// signal and nothing has to be polled
Singleton {
    id: root

    readonly property alias live: server.trackedNotifications

    property var history: []
    property bool dnd: false

    property int missed: 0
    property bool historyOpen: false
    property var historyScreen: null

    // also the writer, so saving before the restore writes back the read
    property bool restored: false

    onHistoryChanged: if (restored) save()
    onMissedChanged: if (restored) save()

    function save(): void {
        store.setText(JSON.stringify({
            history: history,
            missed: missed
        }));
    }

    FileView {
        id: store
        path: Theme.notifCache
        printErrors: false
        atomicWrites: true

        onLoaded: {
            try {
                const d = JSON.parse(store.text());
                if (d.history)
                    root.history = d.history;
                root.missed = d.missed || 0;
            } catch (e) {
            }
            root.restored = true;
        }

        onLoadFailed: root.restored = true
    }

    // consecutive notifications from one app are one event
    readonly property var grouped: {
        const out = [];
        for (let i = 0; i < history.length; i++) {
            const row = history[i];
            const last = out.length ? out[out.length - 1] : null;
            if (last && last.appName === row.appName) {
                last.count += 1;
                continue;
            }
            out.push({
                appName: row.appName,
                summary: row.summary,
                body: row.body || "",
                urgency: row.urgency,
                time: row.time,
                count: 1,
                at: i
            });
        }
        return out;
    }

    function drop(at, count): void {
        const out = history.slice();
        out.splice(at, count);
        history = out;
    }

    function toggleDnd(): void {
        dnd = !dnd;
        if (!dnd)
            missed = 0;
    }

    function toggleHistory(screen): void {
        if (screen)
            historyScreen = screen;
        historyOpen = !historyOpen;
        if (historyOpen)
            missed = 0;
    }

    function clear(): void {
        history = [];
        missed = 0;
    }

    function rule(urgency) {
        return urgency === NotificationUrgency.Critical
            ? Theme.red
            : urgency === NotificationUrgency.Low
                ? Theme.hairline(0.35)
                : Theme.accent;
    }

    function since(ms) {
        const mins = Math.floor((Date.now() - ms) / 60000);
        if (mins < 1)
            return "now";
        if (mins < 60)
            return mins + "m";
        const hours = Math.floor(mins / 60);
        return hours < 24 ? hours + "h" : Math.floor(hours / 24) + "d";
    }

    // the server advertises actions over dbus, so a click has to actually
    // reach one: the default action is what the sending app expects a tap on
    // the body to mean, and only with none does the tap just get rid of it
    function activate(n): void {
        const acts = n.actions;
        for (let i = 0; i < acts.length; i++) {
            if (acts[i].identifier === "default") {
                acts[i].invoke();
                if (!n.resident)
                    n.dismiss();
                return;
            }
        }
        n.dismiss();
    }

    // an action that is not the default is a button, not a body tap
    function buttons(n) {
        const out = [];
        const acts = n.actions;
        for (let i = 0; i < acts.length; i++)
            if (acts[i].identifier !== "default")
                out.push(acts[i]);
        return out;
    }

    NotificationServer {
        id: server

        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true

        onNotification: n => {
            root.history = [
                {
                    appName: n.appName || "unknown",
                    summary: n.summary,
                    body: n.body || "",
                    urgency: n.urgency,
                    time: Date.now()
                }
            ].concat(root.history).slice(0, 50);

            // critical breaks through, which is what makes silencing safe
            if (root.dnd && n.urgency !== NotificationUrgency.Critical) {
                root.missed += 1;
                return;
            }
            n.tracked = true;
        }
    }
}
