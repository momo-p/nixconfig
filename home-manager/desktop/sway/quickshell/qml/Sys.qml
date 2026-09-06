pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.I3
import "."

// one copy of each watcher, shared by every bar
Singleton {
    id: root

    property string ime: ""
    property string vpn: "Disconnected"

    // surfaces that exist once rather than per bar live on this output
    readonly property var mainScreen: {
        const list = Quickshell.screens;
        for (const s of list)
            if (s.name !== Theme.subOutput)
                return s;
        return list.length ? list[0] : null;
    }

    // mod+n has no pointer to start from, so it follows the keyboard
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

    // fcitx emits no signal on switch, so one long-lived poller that
    // only writes a line when the value actually changes
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
}
