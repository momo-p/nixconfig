import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "."

PanelWindow {
    id: panel

    WlrLayershell.namespace: "quickshell-popup"

    screen: Notifs.historyScreen ? Notifs.historyScreen : Sys.mainScreen

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore

    color: "transparent"
    visible: Notifs.historyOpen

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

                Rectangle {
                    id: entry

                    required property var modelData

                    Layout.fillWidth: true
                    implicitHeight: line.implicitHeight + 10
                    radius: 10
                    color: entryHover.hovered ? Theme.hairline(0.10) : "transparent"

                    HoverHandler {
                        id: entryHover
                    }

                    TapHandler {
                        onTapped: Notifs.drop(entry.modelData.at, entry.modelData.count)
                    }

                    RowLayout {
                        id: line
                        anchors.fill: parent
                        anchors.leftMargin: 6
                        anchors.rightMargin: 6
                        spacing: 11

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.topMargin: 5
                            Layout.bottomMargin: 5
                            Layout.preferredWidth: 3
                            radius: 1.5
                            color: Notifs.rule(entry.modelData.urgency)
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                Text {
                                    text: entry.modelData.appName
                                    color: Theme.overlay
                                    elide: Text.ElideRight
                                    font.family: "SF Pro Display"
                                    font.pixelSize: 11
                                }

                                Text {
                                    visible: entry.modelData.count > 1
                                    text: "×" + entry.modelData.count
                                    color: Theme.accent
                                    font.family: "SF Pro Display"
                                    font.pixelSize: 11
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                Text {
                                    visible: !entryHover.hovered
                                    text: Notifs.since(entry.modelData.time)
                                    color: Theme.overlay
                                    font.family: "SF Pro Display"
                                    font.pixelSize: 11
                                }

                                Text {
                                    visible: entryHover.hovered
                                    text: "✕"
                                    color: Theme.text
                                    font.family: "SF Pro Display"
                                    font.pixelSize: 11
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: entry.modelData.summary
                                color: Theme.text
                                elide: Text.ElideRight
                                font.family: "SF Pro Display"
                                font.pixelSize: 13
                            }

                            Text {
                                Layout.fillWidth: true
                                visible: entry.modelData.body !== ""
                                text: entry.modelData.body
                                color: Theme.subtext
                                textFormat: Text.StyledText
                                elide: Text.ElideRight
                                maximumLineCount: 2
                                wrapMode: Text.Wrap
                                font.family: "SF Pro Display"
                                font.pixelSize: 12
                            }
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
