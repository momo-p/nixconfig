import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "."

// a layer, not a popup: swayfx only blurs layers
PanelWindow {
    id: popup

    readonly property int agendaDay: grid.selected > 0
        ? grid.selected
        : grid.hovered > 0 ? grid.hovered : Sys.now.getDate()
    readonly property var agendaRows: Agenda.on(grid.dateKey(agendaDay))

    WlrLayershell.namespace: "quickshell-popup"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore

    color: "transparent"
    visible: false

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
        grid.hovered = 0;
        grid.selected = 0;
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
                text: {
                    const d = grid.selected > 0 ? grid.selected : grid.hovered;
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
                visible: (grid.selected > 0 || grid.hovered > 0) && popup.agendaRows.length === 0
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
