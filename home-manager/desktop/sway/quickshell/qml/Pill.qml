import QtQuick
import QtQuick.Layouts
import "."

Rectangle {
    default property alias content: inner.data
    property int pad: 14

    implicitWidth: inner.implicitWidth + pad * 2
    implicitHeight: Theme.pillHeight
    radius: height / 2
    color: Theme.pill(0.52)
    border.width: 1
    border.color: Theme.hairline(0.16)

    RowLayout {
        id: inner
        anchors.centerIn: parent
        spacing: 14
    }
}
