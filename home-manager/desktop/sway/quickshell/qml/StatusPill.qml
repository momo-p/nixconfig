import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Networking
import QtQuick.Layouts
import QtQuick
import "."

Pill {
    id: root

    property var barWindow

    pad: 14

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }

    Icon {
        readonly property var src: Pipewire.defaultAudioSource
        visible: src && src.audio ? src.audio.muted : false
        source: Theme.iconMicOff
    }

    Icon {
        readonly property var dev: {
            const list = Networking.devices.values;
            for (let i = 0; i < list.length; i++)
                if (list[i].connected)
                    return list[i];
            return null;
        }
        source: !dev
            ? Theme.iconNetOff
            : ("scannerEnabled" in dev ? Theme.iconWifi : Theme.iconWired)
    }

    Text {
        id: ime

        Layout.preferredWidth: Theme.iconSize
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: Sys.ime === "anthy" ? "あ" : Sys.ime === "bamboo" ? "VI" : "EN"
        color: Sys.ime === "" || Sys.ime === "keyboard-us" ? Theme.text : Theme.accent
        font.family: "Noto Sans CJK JP"
        font.pixelSize: 13
        font.bold: true

        TapHandler {
            onTapped: Sys.cycleIme()
        }

        HoverHandler {
            id: imeHover
        }
    }

    Icon {
        id: volume
        readonly property var sink: Pipewire.defaultAudioSink

        source: sink && sink.audio && sink.audio.muted
            ? Theme.iconVolOff
            : Theme.iconVol

        readonly property string label: {
            const a = volume.sink ? volume.sink.audio : null;
            if (!a)
                return "no sink";
            return a.muted ? "muted" : Math.round(a.volume * 100) + "%";
        }

        function step(delta) {
            const a = volume.sink ? volume.sink.audio : null;
            if (!a)
                return;
            a.muted = false;
            a.volume = Math.max(0, Math.min(1, a.volume + delta));
        }

        TapHandler {
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onTapped: (point, button) => {
                const a = volume.sink ? volume.sink.audio : null;
                if (button === Qt.RightButton)
                    Quickshell.execDetached([Theme.pavucontrol]);
                else if (a)
                    a.muted = !a.muted;
            }
        }

        WheelHandler {
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: event => volume.step(event.angleDelta.y > 0 ? 0.05 : -0.05)
        }

        HoverHandler {
            id: volumeHover
        }
    }

    Icon {
        readonly property var batt: UPower.displayDevice
        visible: batt ? batt.isLaptopBattery : false
        source: !batt
            ? Theme.iconBattery
            : batt.percentage <= 0.15
                ? Theme.iconBatteryCrit
                : batt.percentage <= 0.25
                    ? Theme.iconBatteryLow
                    : Theme.iconBattery
    }

    Tooltip {
        targetWindow: root.barWindow
        target: volume
        text: volume.label
        visible: volumeHover.hovered
    }

    Tooltip {
        targetWindow: root.barWindow
        target: ime
        text: Sys.ime === "" ? "input method" : Sys.ime
        visible: imeHover.hovered
    }

}
