import QtQuick
import QtQuick.Layouts
import "."

// seven columns, not seven icons. each day is one track with its six-hour
// windows merged into runs, so a warm stretch or a wet stretch is drawn as a
// single connected piece rather than four blocks that happen to touch
RowLayout {
    id: strip

    readonly property var days: Weather.forecast.days
        ? Weather.forecast.days.slice(0, 7)
        : []

    // one scale for the row, or a mild day would look as tall as a hot one
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

    // consecutive true values become one {at, len}, which is what turns four
    // windows into one pill instead of four
    function runs(flags) {
        const out = [];
        let i = 0;
        while (i < flags.length) {
            if (!flags[i]) {
                i++;
                continue;
            }
            let n = 0;
            while (i + n < flags.length && flags[i + n])
                n++;
            out.push({at: i, len: n});
            i += n;
        }
        return out;
    }

    function warmRuns(tparts) {
        const span = Math.max(1, ceiling - floor);
        const flags = [];
        for (let i = 0; i < tparts.length; i++)
            flags.push(!!tparts[i] && (tparts[i].hi - floor) / span >= 0.5);
        return runs(flags);
    }

    function wetRuns(parts) {
        const flags = [];
        for (let i = 0; i < parts.length; i++)
            flags.push(parts[i] >= 50);
        return runs(flags);
    }

    visible: days.length > 0
    spacing: 2

    Repeater {
        model: strip.days

        ColumnLayout {
            id: day

            required property var modelData

            readonly property int dow: new Date(modelData.date + "T00:00:00").getDay()

            // equal shares: without a preferred width the columns size to
            // their text and the numbers run into each other
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            spacing: 3

            //土 blue, 日 red, matching the grid below
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

            // one track a day, with the warm stretch drawn over it
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

            // the same windows as rain, merged the same way: a wet afternoon
            // and evening is one piece, not two
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
