import Quickshell
import QtQuick
import "."

Pill {
    id: root

    property alias date: clock.date
    signal toggled

    pad: 18

    readonly property var jpDays: ["日", "月", "火", "水", "木", "金", "土"]

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        text: Qt.formatDateTime(clock.date, "HH:mm")
        color: Theme.text
        font.family: "SF Pro Display"
        font.pixelSize: 15
        font.bold: true
        verticalAlignment: Text.AlignVCenter
    }

    Text {
        text: Qt.formatDateTime(clock.date, "yyyy/MM/dd")
        color: Theme.subtext
        font.family: "SF Pro Display"
        font.pixelSize: 13
        verticalAlignment: Text.AlignVCenter
    }

    Text {
        text: root.jpDays[clock.date.getDay()]
        color: Theme.accent
        font.family: "Noto Sans CJK JP"
        font.pixelSize: 13
        font.bold: true
        verticalAlignment: Text.AlignVCenter
    }

    TapHandler {
        onTapped: root.toggled()
    }
}
