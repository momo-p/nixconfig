import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import "."

PanelWindow {
    id: credit

    property string file: ""

    readonly property string connector: Sys.mainScreen ? Sys.mainScreen.name : ""
    readonly property string named: Theme.wallpaperCredits[file] || ""

    WlrLayershell.namespace: "quickshell-credit"

    anchors.bottom: true
    anchors.left: true
    margins.bottom: Theme.edge
    margins.left: Theme.edge
    exclusionMode: ExclusionMode.Ignore

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight
    color: "transparent"

    // not off the label: the probe fills it, so that would loop
    visible: Sys.desktopEmpty
    onVisibleChanged: if (visible && connector !== "") probe.running = true

    mask: Region {}

    Process {
        id: probe
        command: [Theme.wpaperctl, "get-wallpaper", credit.connector]
        stdout: StdioCollector {
            onStreamFinished: {
                const p = text.trim();
                credit.file = p === "" ? "" : p.slice(p.lastIndexOf("/") + 1);
            }
        }
    }

    Timer {
        interval: 300000
        running: credit.visible
        repeat: true
        onTriggered: if (credit.connector !== "") probe.running = true
    }

    Text {
        id: label
        text: credit.file === "" ? "" : credit.named === "" ? credit.file + "  ·  Mod+W" : credit.file + "  ·  " + credit.named + "  ·  Mod+W"
        color: Theme.text
        opacity: 0.42
        font.family: "SF Pro Display"
        font.pixelSize: 11
    }
}
