pragma Singleton
import Quickshell
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

    // consecutive notifications from one app are one event
    readonly property var grouped: {
        const out = [];
        for (const row of history) {
            const last = out.length ? out[out.length - 1] : null;
            if (last && last.appName === row.appName) {
                last.count += 1;
                continue;
            }
            out.push({
                appName: row.appName,
                summary: row.summary,
                urgency: row.urgency,
                time: row.time,
                count: 1
            });
        }
        return out;
    }

    function toggleDnd(): void {
        dnd = !dnd;
        if (!dnd)
            missed = 0;
    }

    function toggleHistory(): void {
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
