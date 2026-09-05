pragma Singleton
import Quickshell
import Quickshell.Io

// one copy of each watcher, shared by every bar
Singleton {
    id: root

    property string ime: ""
    property string vpn: "Disconnected"
    property bool dnd: false

    function cycleIme(): void {
        const list = Theme.inputMethods;
        const next = list[(list.indexOf(ime) + 1) % list.length];
        ime = next;
        Quickshell.execDetached([Theme.fcitxRemote, "-s", next]);
    }

    function toggleDnd(): void {
        dnd = !dnd;
        Quickshell.execDetached([Theme.makoctl, "mode", "-t", "do-not-disturb"]);
    }

    IpcHandler {
        target: "focus"
        function toggle(): void {
            root.toggleDnd();
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

    // mako keeps its mode across a shell restart, so read it once at startup
    Process {
        running: true
        command: [Theme.makoctl, "mode"]
        stdout: SplitParser {
            onRead: data => {
                if (data.trim() === "do-not-disturb")
                    root.dnd = true;
            }
        }
    }
}
