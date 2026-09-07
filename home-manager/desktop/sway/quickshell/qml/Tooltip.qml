import Quickshell
import Quickshell.Wayland
import QtQuick
import "."

// a layer surface rather than a popup, so swayfx blurs it like the calendar
PanelWindow {
    id: tip

    property Item target
    property var targetWindow
    property string text: ""

    WlrLayershell.namespace: "quickshell-popup"

    screen: targetWindow ? targetWindow.screen : null
    anchors.top: true
    anchors.left: true
    margins.top: Theme.barHeight + 2

    margins.left: target
        ? Math.round(target.mapToItem(null, target.width / 2, 0).x - tip.implicitWidth / 2)
        : 0

    exclusionMode: ExclusionMode.Ignore

    mask: Region {}

    implicitWidth: label.implicitWidth + 22
    implicitHeight: 26
    color: "transparent"
    visible: false

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
