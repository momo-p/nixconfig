import Quickshell
import "."

ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {
            required property var modelData
            screen: modelData
        }
    }

    // one set of notification surfaces, not one per bar
    Toasts {
        screen: Sys.mainScreen
    }

    NotifHistory {
        screen: Sys.mainScreen
    }
}
