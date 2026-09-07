import QtQuick
import QtQuick.Layouts
import "."

ColumnLayout {
    id: hours

    property var day: null

    readonly property var temps: day && day.hours ? day.hours.t : []
    readonly property var rain: day && day.hours ? day.hours.p : []

    readonly property real floor: {
        let lo = 999;
        for (let i = 0; i < temps.length; i++)
            if (temps[i] !== null)
                lo = Math.min(lo, temps[i]);
        return lo === 999 ? 0 : lo;
    }

    readonly property real ceiling: {
        let hi = -999;
        for (let i = 0; i < temps.length; i++)
            if (temps[i] !== null)
                hi = Math.max(hi, temps[i]);
        return hi === -999 ? 1 : hi;
    }

    readonly property var warm: {
        const span = Math.max(1, ceiling - floor);
        const flags = [];
        for (let i = 0; i < temps.length; i++)
            flags.push(temps[i] !== null && (temps[i] - floor) / span >= 0.5);
        return Theme.runs(flags);
    }

    readonly property var wet: {
        const flags = [];
        for (let i = 0; i < rain.length; i++)
            flags.push(rain[i] >= 50);
        return Theme.runs(flags);
    }

    property int at: -1

    readonly property int atTemp: at >= 0 && temps[at] !== null && temps[at] !== undefined
        ? Math.round(temps[at])
        : 0
    readonly property int atRain: at >= 0 && rain[at] !== undefined ? rain[at] : 0

    HoverHandler {
        id: probe

        onPointChanged: {
            if (!probe.hovered || hours.width <= 0) {
                hours.at = -1;
                return;
            }
            const i = Math.floor(probe.point.position.x / (hours.width / 24));
            hours.at = Math.min(23, Math.max(0, i));
        }

        onHoveredChanged: if (!hovered) hours.at = -1
    }

    spacing: 3

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 8

        readonly property real cell: width / 24

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: Theme.hairline(0.12)
        }

        Repeater {
            model: hours.warm

            Rectangle {
                required property var modelData

                height: parent.height
                radius: height / 2
                color: Theme.accent
                x: modelData.at * parent.cell
                width: modelData.len * parent.cell
            }
        }

        Rectangle {
            visible: hours.at >= 0
            width: parent.cell
            height: parent.height
            radius: height / 2
            color: Theme.fade(Theme.text, 0.5)
            x: hours.at * parent.cell
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 6

        readonly property real cell: width / 24

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: Theme.hairline(0.10)
        }

        Repeater {
            model: hours.wet

            Rectangle {
                required property var modelData

                height: parent.height
                radius: height / 2
                color: Theme.blue
                x: modelData.at * parent.cell
                width: modelData.len * parent.cell
            }
        }

        Rectangle {
            visible: hours.at >= 0
            width: parent.cell
            height: parent.height
            radius: height / 2
            color: Theme.fade(Theme.text, 0.5)
            x: hours.at * parent.cell
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 0

        Repeater {
            model: [0, 6, 12, 18]

            Text {
                required property var modelData

                Layout.fillWidth: true
                Layout.preferredWidth: 1
                text: modelData + "時"
                color: Theme.overlay
                font.family: "Noto Sans CJK JP"
                font.pixelSize: 9
            }
        }
    }
}
