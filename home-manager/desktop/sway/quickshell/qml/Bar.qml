import Quickshell
import Quickshell.Wayland
import Quickshell.I3
import QtQuick
import "."

PanelWindow {
    id: bar

    // swayfx matches layer_effects on this
    WlrLayershell.namespace: "quickshell-bar"

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Theme.barHeight
    color: "transparent"

    readonly property bool isMain: !Sys.mainScreen || screen === Sys.mainScreen

    Row {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: Theme.edge
        anchors.topMargin: Theme.edge
        spacing: 12

        Pill {
            id: launcher
            pad: 10

            Icon {
                source: Theme.iconLauncher
                size: 20
            }

            // without this the handler lands in the row, not the pill
            TapHandler {
                parent: launcher
                onTapped: I3.dispatch("exec " + Theme.launcher)
            }
        }

        Workspaces {
            screenName: bar.screen ? bar.screen.name : ""
        }
    }

    ClockPill {
        id: clockPill
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Theme.edge
        onToggled: calendar.visible = !calendar.visible
    }

    Calendar {
        id: calendar
        screen: bar.screen
    }

    Row {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: Theme.edge
        anchors.topMargin: Theme.edge
        spacing: 12

        TrayPill {
            barWindow: bar
            visible: bar.isMain
        }

        StatusPill {
            barWindow: bar
        }
    }
}
