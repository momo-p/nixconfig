import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import "."

// swayfx blurs this namespace, so the cards carry the same glass as the bar
PanelWindow {
    id: toasts

    WlrLayershell.namespace: "notifications"

    anchors.top: true
    anchors.right: true
    margins.top: Theme.barHeight + 4
    margins.right: Theme.edge
    exclusionMode: ExclusionMode.Ignore

    implicitWidth: Theme.cardWidth
    implicitHeight: Math.max(1, column.implicitHeight)
    color: "transparent"
    // the panel shows the same cards shrunk, so never both at once
    visible: !Notifs.historyOpen && Notifs.live.values.length > 0

    // only the cards take the pointer, the gaps between them stay click-through
    mask: Region {
        item: column
    }

    Column {
        id: column
        width: parent.width
        spacing: 10

        // arrive from the right, the same direction they leave in
        add: Transition {
            NumberAnimation {
                property: "x"
                from: toasts.width
                to: 0
                duration: 220
                easing.type: Easing.OutCubic
            }
        }

        move: Transition {
            NumberAnimation {
                properties: "y"
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        Repeater {
            model: Notifs.live

            Rectangle {
                required property var modelData

                width: column.width
                implicitHeight: Math.max(56, body.implicitHeight + 24)
                radius: 18
                color: Theme.pill(0.72)
                border.width: 1
                border.color: Theme.hairline(0.18)

                // a critical notification is the one thing that must not vanish
                Timer {
                    running: modelData.urgency !== NotificationUrgency.Critical
                    interval: modelData.expireTimeout > 0 ? modelData.expireTimeout : 10000
                    onTriggered: modelData.expire()
                }

                TapHandler {
                    onTapped: Notifs.activate(modelData)
                }

                RowLayout {
                    id: body
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 11

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 3
                        radius: 1.5
                        color: Notifs.rule(modelData.urgency)
                    }

                    Item {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        Layout.alignment: Qt.AlignTop
                        visible: modelData.image !== ""

                        Image {
                            id: avatar
                            anchors.fill: parent
                            source: modelData.image
                            fillMode: Image.PreserveAspectCrop
                            visible: false
                        }

                        Rectangle {
                            id: avatarMask
                            anchors.fill: parent
                            radius: 6
                            visible: false
                            layer.enabled: true
                        }

                        MultiEffect {
                            anchors.fill: parent
                            source: avatar
                            maskEnabled: true
                            maskSource: avatarMask
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            Layout.fillWidth: true
                            text: modelData.appName
                            color: Theme.overlay
                            elide: Text.ElideRight
                            font.family: "SF Pro Display"
                            font.pixelSize: 11
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.summary
                            color: Theme.text
                            elide: Text.ElideRight
                            font.family: "SF Pro Display"
                            font.pixelSize: 13
                            font.bold: true
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: modelData.body !== ""
                            text: modelData.body
                            color: Theme.subtext
                            textFormat: Text.StyledText
                            wrapMode: Text.Wrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                            font.family: "SF Pro Display"
                            font.pixelSize: 12
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.topMargin: 4
                            spacing: 6
                            visible: repeater.count > 0

                            Repeater {
                                id: repeater
                                model: Notifs.buttons(modelData)

                                Rectangle {
                                    required property var modelData

                                    implicitWidth: label.implicitWidth + 18
                                    implicitHeight: 22
                                    radius: 11
                                    color: press.hovered ? Theme.hairline(0.22) : Theme.hairline(0.12)

                                    Text {
                                        id: label
                                        anchors.centerIn: parent
                                        text: parent.modelData.text
                                        color: Theme.text
                                        font.family: "SF Pro Display"
                                        font.pixelSize: 11
                                    }

                                    // stops the body tap underneath from also firing
                                    TapHandler {
                                        gesturePolicy: TapHandler.WithinBounds
                                        onTapped: parent.modelData.invoke()
                                    }

                                    HoverHandler {
                                        id: press
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }
        }
    }
}
