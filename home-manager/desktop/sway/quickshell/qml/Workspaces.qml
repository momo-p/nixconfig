import Quickshell.I3
import QtQuick
import QtQuick.Layouts
import "."

Pill {
    property string screenName

    Repeater {
        model: I3.workspaces

        Rectangle {
            required property var modelData

            visible: modelData.monitor && screenName
                ? modelData.monitor.name === screenName
                : true
            Layout.preferredWidth: modelData.focused ? 26 : 8
            Layout.preferredHeight: 8
            radius: height / 2
            color: modelData.urgent
                ? Theme.red
                : modelData.focused
                    ? Theme.accent
                    : Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b,
                              modelData.active ? 0.62 : 0.22)

            Behavior on Layout.preferredWidth {
                NumberAnimation {
                    duration: 260
                    easing.type: Easing.OutCubic
                }
            }

            TapHandler {
                onTapped: I3.dispatch("workspace " + modelData.name)
            }
        }
    }
}
