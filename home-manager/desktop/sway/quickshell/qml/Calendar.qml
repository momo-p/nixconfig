import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "."

// a layer surface rather than a popup: swayfx only applies layer_effects
// to layers, so a popup would get no blur
PanelWindow {
    id: popup

    property date shown: new Date()

    WlrLayershell.namespace: "quickshell-popup"

    anchors.top: true
    margins.top: Theme.barHeight + 4
    exclusionMode: ExclusionMode.Ignore

    implicitWidth: 320
    implicitHeight: card.implicitHeight
    color: "transparent"
    visible: false

    onVisibleChanged: if (visible) shown = new Date()

    readonly property var weekdays: ["月", "火", "水", "木", "金", "土", "日"]

    // monday-first cells, 0 meaning an empty pad cell
    readonly property var cells: {
        const y = shown.getFullYear();
        const m = shown.getMonth();
        const lead = (new Date(y, m, 1).getDay() + 6) % 7;
        const len = new Date(y, m + 1, 0).getDate();
        const out = [];
        for (let i = 0; i < lead; i++)
            out.push(0);
        for (let d = 1; d <= len; d++)
            out.push(d);
        while (out.length % 7 !== 0)
            out.push(0);
        return out;
    }

    function isToday(d) {
        const n = new Date();
        return d === n.getDate()
            && shown.getMonth() === n.getMonth()
            && shown.getFullYear() === n.getFullYear();
    }

    Rectangle {
        id: card
        width: parent.width
        implicitHeight: layout.implicitHeight + 36
        radius: 24
        color: Theme.pill(0.72)
        border.width: 1
        border.color: Theme.hairline(0.18)

        ColumnLayout {
            id: layout
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: popup.shown.getFullYear() + "年" + (popup.shown.getMonth() + 1) + "月"
                color: Theme.text
                font.family: "Noto Sans CJK JP"
                font.pixelSize: 15
                font.bold: true
            }

            // columns align by construction, not by monospace luck
            GridLayout {
                Layout.fillWidth: true
                columns: 7
                columnSpacing: 0
                rowSpacing: 2

                Repeater {
                    model: popup.weekdays

                    Text {
                        required property int index
                        required property string modelData
                        Layout.fillWidth: true
                        Layout.bottomMargin: 4
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData
                        font.family: "Noto Sans CJK JP"
                        font.pixelSize: 11
                        color: index === 5
                            ? Theme.blue
                            : index === 6 ? Theme.red : Theme.overlay
                    }
                }

                Repeater {
                    model: popup.cells

                    Item {
                        required property int index
                        required property int modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30

                        Rectangle {
                            anchors.centerIn: parent
                            width: 26
                            height: 26
                            radius: height / 2
                            visible: popup.isToday(parent.modelData)
                            color: Theme.accent
                        }

                        Text {
                            anchors.centerIn: parent
                            text: modelData === 0 ? "" : modelData
                            font.family: "SF Pro Display"
                            font.pixelSize: 13
                            color: popup.isToday(modelData)
                                ? Theme.base
                                : index % 7 === 5
                                    ? Theme.blue
                                    : index % 7 === 6 ? Theme.red : Theme.text
                            font.bold: popup.isToday(modelData)
                        }
                    }
                }
            }
        }
    }
}
