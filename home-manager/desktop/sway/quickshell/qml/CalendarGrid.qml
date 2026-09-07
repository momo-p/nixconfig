import QtQuick
import QtQuick.Layouts
import "."

// the month grid on its own: the bar popup shows this month, the rail lets
// you walk through others
ColumnLayout {
    id: grid

    property date shown: new Date()
    property int hovered: 0
    property int selected: 0

    // walking to another month would otherwise keep a day of the old one picked
    onShownChanged: selected = 0

    spacing: 2

    readonly property var weekdays: ["月", "火", "水", "木", "金", "土", "日"]

    // monday-first cells, 0 meaning an empty pad cell
    readonly property var cells: {
        const y = shown.getFullYear();
        const m = shown.getMonth();
        const lead = (new Date(y, m, 1).getDay() + 6) % 7;
        const len = new Date(y, m + 1, 0).getDate();
        const out = [];
        for (let i = 0; i < lead; i++)
            out.push(0);
        for (let d = 1; d <= len; d++)
            out.push(d);
        while (out.length % 7 !== 0)
            out.push(0);
        return out;
    }

    function dateKey(d) {
        const m = shown.getMonth() + 1;
        return shown.getFullYear() + "-" + (m < 10 ? "0" + m : m) + "-" + (d < 10 ? "0" + d : d);
    }

    function isToday(d) {
        const n = new Date();
        return d === n.getDate()
            && shown.getMonth() === n.getMonth()
            && shown.getFullYear() === n.getFullYear();
    }

    // columns align by construction, not by monospace luck
    GridLayout {
        Layout.fillWidth: true
        columns: 7
        columnSpacing: 0
        rowSpacing: 2

        Repeater {
            model: grid.weekdays

            Text {
                required property int index
                required property string modelData
                Layout.fillWidth: true
                Layout.bottomMargin: 4
                horizontalAlignment: Text.AlignHCenter
                text: modelData
                font.family: "Noto Sans CJK JP"
                font.pixelSize: 11
                color: index === 5
                    ? Theme.blue
                    : index === 6 ? Theme.red : Theme.overlay
            }
        }

        Repeater {
            model: grid.cells

            Item {
                required property int index
                required property int modelData
                Layout.fillWidth: true
                Layout.preferredHeight: 34

                // a cell only clears its own day: moving between two cells
                // can deliver the leave after the enter
                HoverHandler {
                    onHoveredChanged: {
                        if (hovered)
                            grid.hovered = parent.modelData;
                        else if (grid.hovered === parent.modelData)
                            grid.hovered = 0;
                    }
                }

                TapHandler {
                    enabled: parent.modelData !== 0
                    onTapped: grid.selected = grid.selected === parent.modelData
                        ? 0
                        : parent.modelData
                }

                // rain sits under the day, so the grid read for events is
                // also the thing a week is planned around
                Rectangle {
                    readonly property int rain: parent.modelData === 0
                        ? -1
                        : Weather.rainOn(grid.dateKey(parent.modelData))

                    anchors.fill: parent
                    anchors.margins: 2
                    radius: 7
                    visible: rain >= 0
                    opacity: Weather.stale ? 0.45 : 1
                    color: Theme.fade(Theme.blue, 0.06 + rain / 100 * 0.4)
                }

                // events as dots under the number, capped at three: more
                // than that is a calendar app, not a glance
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 2
                    spacing: 3

                    Repeater {
                        model: parent.parent.modelData === 0
                            ? []
                            : Agenda.on(grid.dateKey(parent.parent.modelData)).slice(0, 3)

                        Rectangle {
                            required property var modelData
                            width: 3
                            height: 3
                            radius: 1.5
                            color: Agenda.colorOf(modelData.cal)
                        }
                    }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: 26
                    height: 26
                    radius: height / 2
                    visible: grid.isToday(parent.modelData)
                    color: Theme.accent
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: 26
                    height: 26
                    radius: height / 2
                    visible: parent.modelData !== 0 && grid.selected === parent.modelData
                    color: "transparent"
                    border.width: 1
                    border.color: Theme.text
                }

                Text {
                    anchors.centerIn: parent
                    text: modelData === 0 ? "" : modelData
                    font.family: "SF Pro Display"
                    font.pixelSize: 13
                    color: grid.isToday(modelData)
                        ? Theme.base
                        : index % 7 === 5
                            ? Theme.blue
                            : index % 7 === 6 ? Theme.red : Theme.text
                    font.bold: grid.isToday(modelData)
                }
            }
        }
    }
}
