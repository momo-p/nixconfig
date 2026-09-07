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

    Toasts {
        screen: Sys.toastScreen
    }

    NotifHistory {}

    Rail {
        screen: Sys.mainScreen
    }

    Credit {
        screen: Sys.mainScreen
    }
}
