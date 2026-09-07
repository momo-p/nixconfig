pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import "."

Singleton {
    id: root

    property var forecast: ({})
    property bool stale: true

    readonly property bool known: forecast.now !== undefined
    readonly property int temp: known ? forecast.now.temp : 0
    readonly property string cond: known ? forecast.now.cond : ""

    onForecastChanged: root.check()

    function check(): void {
        stale = !forecast.ts || Date.now() / 1000 - forecast.ts > 5400;
    }

    // null past the horizon, so the tint stops rather than fades
    function dayOn(date) {
        const days = forecast.days;
        if (!days)
            return null;
        for (let i = 0; i < days.length; i++)
            if (days[i].date === date)
                return days[i];
        return null;
    }

    function rainOn(date) {
        const day = dayOn(date);
        return day ? day.rain : -1;
    }

    FileView {
        id: file
        path: Theme.weatherCache
        watchChanges: true
        printErrors: false

        onLoaded: root.forecast = JSON.parse(file.text())
        onFileChanged: file.reload()
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.check()
    }
}
