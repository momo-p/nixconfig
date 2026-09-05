import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import "."

Pill {
    id: root

    property var barWindow

    pad: 12
    visible: shownCount > 0

    readonly property int shownCount: {
        let n = 0;
        const items = SystemTray.items.values;
        for (let i = 0; i < items.length; i++)
            if (!Theme.trayHidden(items[i].id, items[i].title))
                n++;
        return n;
    }

    Repeater {
        model: SystemTray.items

        Icon {
            id: trayIcon
            required property var modelData

            visible: !Theme.trayHidden(modelData.id, modelData.title)
            // a hidden item would still try to resolve its icon
            source: visible
                ? Theme.trayIconFor(modelData.id, modelData.title, modelData.icon)
                : ""

            QsMenuAnchor {
                id: trayMenu
                menu: trayIcon.modelData.menu
                anchor.item: trayIcon
                anchor.rect.y: Theme.pillHeight
            }

            TapHandler {
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onTapped: (point, button) => {
                    const item = trayIcon.modelData;
                    if ((button === Qt.RightButton || item.onlyMenu) && item.hasMenu)
                        trayMenu.visible = true;
                    else if (!item.onlyMenu)
                        item.activate();
                }
            }
        }
    }
}
