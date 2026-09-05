pragma Singleton
import Quickshell
import Quickshell.Io

// one copy of each watcher, shared by every bar
Singleton {
    id: root

    property string ime: ""

    function cycleIme(): void {
        const list = Theme.inputMethods;
        const next = list[(list.indexOf(ime) + 1) % list.length];
        ime = next;
        Quickshell.execDetached([Theme.fcitxRemote, "-s", next]);
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
}
