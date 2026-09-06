import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "."

// history appears where the toasts appeared, because it is the same thing
// returning: top right, same width, the rows are the toasts shrunk
PanelWindow {
    id: panel

    WlrLayershell.namespace: "quickshell-popup"

    screen: Notifs.historyScreen ? Notifs.historyScreen : Sys.mainScreen

    // the surface covers the output so a click anywhere off the card dismisses it
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore

    color: "transparent"
    visible: Notifs.historyOpen

    // the bar keeps its own clicks, so the pill that opened this can close it
    mask: Region {
        y: Theme.barHeight
        width: panel.width
        height: panel.height - Theme.barHeight
    }

    TapHandler {
        onTapped: point => {
            const p = card.mapFromItem(null, point.position);
            if (p.x < 0 || p.y < 0 || p.x > card.width || p.y > card.height)
                Notifs.historyOpen = false;
        }
    }

    // a glance surface, not an inbox
    readonly property int shown: 4
    readonly property var rows: Notifs.grouped.slice(0, shown)
    readonly property int older: Notifs.grouped.length - rows.length

    Rectangle {
        id: card
        width: Theme.cardWidth
        x: parent.width - width - Theme.edge
        y: Theme.barHeight + 4
        implicitHeight: layout.implicitHeight + 32
        radius: 24
        color: Theme.pill(0.72)
        border.width: 1
        border.color: Theme.hairline(0.18)

        ColumnLayout {
            id: layout
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: Notifs.dnd ? "silenced" : "notifications"
                    color: Notifs.dnd ? Theme.accent : Theme.overlay
                    font.family: "SF Pro Display"
                    font.pixelSize: 11
                }

                Text {
                    visible: Notifs.history.length > 0
                    text: "clear"
                    color: clearHover.hovered ? Theme.text : Theme.overlay
                    font.family: "SF Pro Display"
                    font.pixelSize: 11

                    TapHandler {
                        onTapped: Notifs.clear()
                    }

                    HoverHandler {
                        id: clearHover
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                visible: Notifs.history.length === 0
                text: "nothing missed"
                color: Theme.overlay
                font.family: "SF Pro Display"
                font.pixelSize: 13
            }

            Repeater {
                model: panel.rows

                RowLayout {
                    required property var modelData

                    Layout.fillWidth: true
                    spacing: 11

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 3
                        radius: 1.5
                        color: Notifs.rule(modelData.urgency)
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Text {
                                text: modelData.appName
                                color: Theme.overlay
                                elide: Text.ElideRight
                                font.family: "SF Pro Display"
                                font.pixelSize: 11
                            }

                            Text {
                                visible: modelData.count > 1
                                text: "×" + modelData.count
                                color: Theme.accent
                                font.family: "SF Pro Display"
                                font.pixelSize: 11
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                text: Notifs.since(modelData.time)
                                color: Theme.overlay
                                font.family: "SF Pro Display"
                                font.pixelSize: 11
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.summary
                            color: Theme.text
                            elide: Text.ElideRight
                            font.family: "SF Pro Display"
                            font.pixelSize: 13
                        }
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                visible: panel.older > 0
                text: "+" + panel.older + " older"
                color: Theme.overlay
                font.family: "SF Pro Display"
                font.pixelSize: 11
            }
        }
    }
}
