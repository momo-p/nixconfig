import QtQuick
import QtQuick.Layouts
import "."

Image {
    property int size: Theme.iconSize

    Layout.preferredWidth: size
    Layout.preferredHeight: size
    sourceSize.width: size * 2
    sourceSize.height: size * 2
    fillMode: Image.PreserveAspectFit
    smooth: true
}
