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
            Layout.preferredWidth: modelData.active ? 26 : 8
            Layout.preferredHeight: 8
            radius: height / 2
            // sway focuses one workspace globally, across all outputs
            color: modelData.urgent
                ? Theme.red
                : modelData.active
                    ? Theme.fade(Theme.accent, modelData.focused ? 1 : 0.45)
                    : Theme.hairline(0.22)

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
