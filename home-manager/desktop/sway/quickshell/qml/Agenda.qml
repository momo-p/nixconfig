pragma Singleton
import Quickshell
import Quickshell.Io
import "."

// same shape as the forecast: a timer syncs and writes the file, the shell
// only reads it
Singleton {
    id: root

    property var data: ({})

    readonly property var events: data.events ? data.events : []

    // a stable colour per calendar without naming them here: the order comes
    // from the file, which only changes when an account is added
    readonly property var calendars: {
        const out = [];
        for (let i = 0; i < events.length; i++)
            if (out.indexOf(events[i].cal) === -1)
                out.push(events[i].cal);
        out.sort();
        return out;
    }

    function colorOf(cal) {
        const i = calendars.indexOf(cal);
        return i <= 0 ? Theme.accent : i === 1 ? Theme.blue : Theme.green;
    }

    function on(date) {
        const out = [];
        for (let i = 0; i < events.length; i++)
            if (events[i].date === date)
                out.push(events[i]);
        return out;
    }

    FileView {
        id: file
        path: Theme.agendaCache
        watchChanges: true
        printErrors: false

        onLoaded: root.data = JSON.parse(file.text())
        onFileChanged: file.reload()
    }
}
