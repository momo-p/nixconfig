import Quickshell
import QtQuick
import "."

PopupWindow {
    id: tip

    property Item target
    property var targetWindow
    property string text: ""

    implicitWidth: label.implicitWidth + 22
    implicitHeight: 26
    color: "transparent"

    anchor {
        window: tip.targetWindow
        rect.x: target
            ? target.mapToItem(null, target.width / 2, 0).x - tip.implicitWidth / 2
            : 0
        rect.y: Theme.barHeight + 2
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Theme.pill(0.78)
        border.width: 1
        border.color: Theme.hairline(0.18)

        Text {
            id: label
            anchors.centerIn: parent
            text: tip.text
            color: Theme.text
            font.family: "SF Pro Display"
            font.pixelSize: 12
        }
    }
}
