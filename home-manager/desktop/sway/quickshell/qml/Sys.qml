pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.I3
import Quickshell.Wayland
import "."

Singleton {
    id: root

    property string ime: ""
    property string vpn: "Disconnected"

    function screenNamed(name) {
        for (const s of Quickshell.screens)
            if (s.name === name)
                return s;
        return null;
    }

    // connector names get reassigned; monitor identity does not
    readonly property var mainScreen: {
        const mons = I3.monitors.values;
        for (const m of mons) {
            const o = m.lastIpcObject;
            if (o && o.make + " " + o.model + " " + o.serial === Theme.mainMonitor)
                return screenNamed(m.name);
        }
        const list = Quickshell.screens;
        return list.length ? list[0] : null;
    }

    // sway leaves representation empty exactly when a workspace holds nothing
    readonly property bool desktopEmpty: {
        const sc = mainScreen;
        if (!sc)
            return false;
        const list = I3.workspaces.values;
        for (let i = 0; i < list.length; i++) {
            const w = list[i];
            if (!w.active || !w.monitor || w.monitor.name !== sc.name)
                continue;
            const o = w.lastIpcObject;
            return !o || !o.representation || o.representation === "";
        }
        return false;
    }

    readonly property var busyScreens: {
        const out = [];
        for (const t of ToplevelManager.toplevels.values) {
            if (!t.fullscreen)
                continue;
            for (const s of t.screens)
                if (out.indexOf(s) === -1)
                    out.push(s);
        }
        return out;
    }

    readonly property var toastScreen: {
        if (busyScreens.indexOf(mainScreen) === -1)
            return mainScreen;
        for (const s of Quickshell.screens)
            if (s !== mainScreen && busyScreens.indexOf(s) === -1)
                return s;
        return mainScreen;
    }

    readonly property var focusedScreen: {
        const mon = I3.focusedMonitor;
        if (!mon)
            return mainScreen;
        for (const s of Quickshell.screens)
            if (s.name === mon.name)
                return s;
        return mainScreen;
    }

    function cycleIme(): void {
        const list = Theme.inputMethods;
        const next = list[(list.indexOf(ime) + 1) % list.length];
        ime = next;
        Quickshell.execDetached([Theme.fcitxRemote, "-s", next]);
    }

    IpcHandler {
        target: "focus"
        function toggle(): void {
            Notifs.toggleDnd();
        }
    }

    IpcHandler {
        target: "notifications"
        function toggle(): void {
            Notifs.toggleHistory(root.focusedScreen);
        }
        function clear(): void {
            Notifs.clear();
        }
    }

    // fcitx emits no signal on switch, so it has to be polled
    Process {
        running: true
        command: [Theme.fcitxWatch]
        stdout: SplitParser {
            onRead: data => root.ime = data.trim()
        }
    }

    // mullvad streams state changes; its detail lines are indented
    Process {
        running: true
        command: [Theme.mullvad, "status", "listen"]
        stdout: SplitParser {
            onRead: data => {
                if (data && data[0] !== " " && data.trim() !== "")
                    root.vpn = data.trim().split(" ")[0];
            }
        }
    }

    property string generation: ""
    property string genAge: ""

    readonly property string today: {
        const d = new Date();
        const m = d.getMonth() + 1;
        const day = d.getDate();
        return d.getFullYear() + "-" + (m < 10 ? "0" + m : m) + "-" + (day < 10 ? "0" + day : day);
    }

    Process {
        id: gen
        running: true
        command: [Theme.stat, "-c", "%N %Y", "/nix/var/nix/profiles/system"]
        stdout: SplitParser {
            onRead: data => {
                const m = data.match(/system-(\d+)-link/);
                if (m)
                    root.generation = "#" + m[1];
                const t = data.match(/ (\d+)$/);
                if (t) {
                    const days = Math.floor((Date.now() / 1000 - parseInt(t[1])) / 86400);
                    root.genAge = days < 1 ? "today" : days + "d";
                }
            }
        }
    }

    Timer {
        interval: 300000
        running: true
        repeat: true
        onTriggered: gen.running = true
    }

    readonly property int staleInputs: {
        const cutoff = Date.now() / 1000 - 30 * 86400;
        let n = 0;
        for (let i = 0; i < Theme.inputTimes.length; i++)
            if (Theme.inputTimes[i] < cutoff)
                n++;
        return n;
    }
}
