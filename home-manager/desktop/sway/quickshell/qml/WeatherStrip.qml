import QtQuick
import QtQuick.Layouts
import "."

RowLayout {
    id: strip

    readonly property var days: Weather.forecast.days
        ? Weather.forecast.days.slice(0, 7)
        : []

    readonly property int floor: {
        let lo = 99;
        for (let i = 0; i < days.length; i++)
            lo = Math.min(lo, days[i].lo);
        return days.length ? lo : 0;
    }

    readonly property int ceiling: {
        let hi = -99;
        for (let i = 0; i < days.length; i++)
            hi = Math.max(hi, days[i].hi);
        return days.length ? hi : 1;
    }

    readonly property var jpDays: ["日", "月", "火", "水", "木", "金", "土"]

    function warmRuns(tparts) {
        const span = Math.max(1, ceiling - floor);
        const flags = [];
        for (let i = 0; i < tparts.length; i++)
            flags.push(!!tparts[i] && (tparts[i].hi - floor) / span >= 0.5);
        return Theme.runs(flags);
    }

    function wetRuns(parts) {
        const flags = [];
        for (let i = 0; i < parts.length; i++)
            flags.push(parts[i] >= 50);
        return Theme.runs(flags);
    }

    visible: days.length > 0
    spacing: 2

    Repeater {
        model: strip.days

        ColumnLayout {
            id: day

            required property var modelData

            readonly property int dow: new Date(modelData.date + "T00:00:00").getDay()

            // fillWidth alone splits surplus, not the whole row
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            spacing: 3

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: strip.jpDays[day.dow]
                color: day.dow === 6
                    ? Theme.blue
                    : day.dow === 0 ? Theme.red : Theme.subtext
                font.family: "Noto Sans CJK JP"
                font.pixelSize: 10
            }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: day.modelData.hi + "°"
                color: Theme.text
                font.family: "SF Pro Display"
                font.pixelSize: 10
            }

            Item {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 6
                Layout.preferredHeight: 68

                readonly property real cell: height / 4

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: Theme.hairline(0.12)
                }

                Repeater {
                    model: strip.warmRuns(day.modelData.tparts)

                    Rectangle {
                        required property var modelData

                        width: parent.width
                        radius: width / 2
                        color: Theme.accent
                        y: modelData.at * parent.cell
                        height: modelData.len * parent.cell
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: day.modelData.lo + "°"
                color: Theme.subtext
                font.family: "SF Pro Display"
                font.pixelSize: 10
            }

            Item {
                Layout.fillWidth: true
                Layout.leftMargin: 1
                Layout.rightMargin: 1
                Layout.preferredHeight: 6

                readonly property real cell: width / 4

                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: Theme.hairline(0.10)
                }

                Repeater {
                    model: strip.wetRuns(day.modelData.parts)

                    Rectangle {
                        required property var modelData

                        height: parent.height
                        radius: height / 2
                        color: Theme.blue
                        x: modelData.at * parent.cell
                        width: modelData.len * parent.cell
                    }
                }
            }
        }
    }
}
