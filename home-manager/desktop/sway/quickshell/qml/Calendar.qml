import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "."

// a layer surface rather than a popup: swayfx only applies layer_effects
// to layers, so a popup would get no blur
PanelWindow {
    id: popup

    property date shown: new Date()
    property int hovered: 0

    // hovering a day reports that day rather than today, so one gesture
    // drives both the forecast line and the agenda below
    readonly property int agendaDay: hovered > 0 ? hovered : new Date().getDate()
    readonly property var agendaRows: Agenda.on(dateKey(agendaDay))

    WlrLayershell.namespace: "quickshell-popup"

    // the surface covers the output so a click anywhere off the card dismisses it
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore

    color: "transparent"
    visible: false

    // the bar keeps its own clicks, so the pill that opened this can close it
    // and the opening click cannot land here and dismiss it at once
    mask: Region {
        y: Theme.barHeight
        width: popup.width
        height: popup.height - Theme.barHeight
    }

    TapHandler {
        onTapped: point => {
            const p = card.mapFromItem(null, point.position);
            if (p.x < 0 || p.y < 0 || p.x > card.width || p.y > card.height)
                popup.visible = false;
        }
    }

    onVisibleChanged: {
        if (!visible)
            return;
        shown = new Date();
        // the pointer is not over a day when this opens
        hovered = 0;
    }

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

    Rectangle {
        id: card
        width: 320
        anchors.horizontalCenter: parent.horizontalCenter
        y: Theme.barHeight + 4
        implicitHeight: layout.implicitHeight + 36
        radius: 24
        color: Theme.pill(0.72)
        border.width: 1
        border.color: Theme.hairline(0.18)

        ColumnLayout {
            id: layout
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: popup.shown.getFullYear() + "年" + (popup.shown.getMonth() + 1) + "月"
                color: Theme.text
                font.family: "Noto Sans CJK JP"
                font.pixelSize: 15
                font.bold: true
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: -8
                visible: Weather.known
                // the header says more rather than the grid growing a row
                text: {
                    const d = popup.hovered;
                    if (d <= 0)
                        return Weather.cond;
                    const day = Weather.dayOn(popup.dateKey(d));
                    const head = (popup.shown.getMonth() + 1) + "/" + d + "  ";
                    return day
                        ? head + day.hi + "°/" + day.lo + "°  降水" + day.rain + "%"
                        : head + "予報なし";
                }
                color: Theme.overlay
                opacity: Weather.stale ? 0.45 : 1
                font.family: "Noto Sans CJK JP"
                font.pixelSize: 12
            }

            // columns align by construction, not by monospace luck
            GridLayout {
                Layout.fillWidth: true
                columns: 7
                columnSpacing: 0
                rowSpacing: 2

                Repeater {
                    model: popup.weekdays

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
                    model: popup.cells

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
                                    popup.hovered = parent.modelData;
                                else if (popup.hovered === parent.modelData)
                                    popup.hovered = 0;
                            }
                        }

                        // rain sits under the day, so the grid read for
                        // events is also the thing a week is planned around
                        Rectangle {
                            readonly property int rain: parent.modelData === 0
                                ? -1
                                : Weather.rainOn(popup.dateKey(parent.modelData))

                            anchors.fill: parent
                            anchors.margins: 2
                            radius: 7
                            visible: rain >= 0
                            opacity: Weather.stale ? 0.45 : 1
                            color: Theme.fade(Theme.blue, 0.06 + rain / 100 * 0.4)
                        }

                        Rectangle {
                            anchors.centerIn: parent
                            width: 26
                            height: 26
                            radius: height / 2
                            visible: popup.isToday(parent.modelData)
                            color: Theme.accent
                        }

                        // events as dots under the number, capped at three:
                        // more than that is a calendar app, not a glance
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 2
                            spacing: 3

                            Repeater {
                                model: parent.parent.modelData === 0
                                    ? []
                                    : Agenda.on(popup.dateKey(parent.parent.modelData)).slice(0, 3)

                                Rectangle {
                                    required property var modelData
                                    width: 3
                                    height: 3
                                    radius: 1.5
                                    color: Agenda.colorOf(modelData.cal)
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: modelData === 0 ? "" : modelData
                            font.family: "SF Pro Display"
                            font.pixelSize: 13
                            color: popup.isToday(modelData)
                                ? Theme.base
                                : index % 7 === 5
                                    ? Theme.blue
                                    : index % 7 === 6 ? Theme.red : Theme.text
                            font.bold: popup.isToday(modelData)
                        }
                    }
                }
            }

            // today only: anything richer is a calendar app
            Repeater {
                model: popup.agendaRows.slice(0, 3)

                RowLayout {
                    required property var modelData

                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        Layout.preferredWidth: 3
                        Layout.fillHeight: true
                        radius: 1.5
                        color: Agenda.colorOf(modelData.cal)
                    }

                    Text {
                        visible: modelData.time !== ""
                        text: modelData.time
                        color: Theme.overlay
                        font.family: "SF Pro Display"
                        font.pixelSize: 11
                    }

                    Text {
                        Layout.fillWidth: true
                        text: modelData.title
                        color: Theme.text
                        elide: Text.ElideRight
                        font.family: "SF Pro Display"
                        font.pixelSize: 12
                    }
                }

            }
            Text {
                Layout.fillWidth: true
                visible: popup.hovered > 0 && popup.agendaRows.length === 0
                text: "予定なし"
                color: Theme.overlay
                font.family: "Noto Sans CJK JP"
                font.pixelSize: 12
            }

            Text {
                Layout.fillWidth: true
                visible: popup.agendaRows.length > 3
                text: "他 " + (popup.agendaRows.length - 3) + " 件"
                color: Theme.overlay
                font.family: "Noto Sans CJK JP"
                font.pixelSize: 11
            }
        }
    }
}
