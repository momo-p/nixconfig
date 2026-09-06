import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "."

// a layer surface rather than a popup: swayfx only applies layer_effects
// to layers, so a popup would get no blur
PanelWindow {
    id: popup

    // hovering a day reports that day rather than today, so one gesture
    // drives both the forecast line and the agenda below
    readonly property int agendaDay: grid.hovered > 0 ? grid.hovered : new Date().getDate()
    readonly property var agendaRows: Agenda.on(grid.dateKey(agendaDay))

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
        grid.shown = new Date();
        // the pointer is not over a day when this opens
        grid.hovered = 0;
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
                text: grid.shown.getFullYear() + "年" + (grid.shown.getMonth() + 1) + "月"
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
                    const d = grid.hovered;
                    if (d <= 0)
                        return Weather.cond;
                    const day = Weather.dayOn(grid.dateKey(d));
                    const head = (grid.shown.getMonth() + 1) + "/" + d + "  ";
                    return day
                        ? head + day.hi + "°/" + day.lo + "°  降水" + day.rain + "%"
                        : head + "予報なし";
                }
                color: Theme.overlay
                opacity: Weather.stale ? 0.45 : 1
                font.family: "Noto Sans CJK JP"
                font.pixelSize: 12
            }

            CalendarGrid {
                id: grid
                Layout.fillWidth: true
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
                visible: grid.hovered > 0 && popup.agendaRows.length === 0
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
