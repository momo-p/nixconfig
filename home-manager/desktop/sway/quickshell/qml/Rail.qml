import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import "."

// bottom right, growing upward: the peek content keeps its pixels when the
// rail expands, so it reads as one object opening rather than two layouts
PanelWindow {
    id: rail

    property bool expanded: false

    WlrLayershell.namespace: "quickshell-rail"

    anchors.bottom: true
    anchors.right: true
    margins.bottom: Theme.edge
    margins.right: Theme.edge
    exclusionMode: ExclusionMode.Ignore

    implicitWidth: rail.expanded ? Theme.cardWidth : Theme.railWidth
    implicitHeight: card.implicitHeight
    color: "transparent"

    visible: Sys.desktopEmpty
    onVisibleChanged: if (!visible) expanded = false

    readonly property var todayRows: Agenda.on(Sys.today)

    // a player that exists but has nothing loaded has nothing to say
    readonly property bool hasTrack: player && player.trackTitle !== ""

    // mpris carries art for most players; the lookup is only for the ones
    // that do not, and it answers from a cache after the first time
    property int tick: 0
    property string fetchedArt: ""
    readonly property string art: {
        if (player && player.trackArtUrl !== "")
            return player.trackArtUrl;
        return fetchedArt === "" ? "" : "file://" + fetchedArt;
    }

    onHasTrackChanged: rail.lookUp()

    function control(what): void {
        if (!player)
            return;
        if (what === "toggle")
            player.togglePlaying();
        else if (what === "next")
            player.next();
        else
            player.previous();
    }

    function lookUp(): void {
        fetchedArt = "";
        if (!hasTrack || player.trackArtUrl !== "" || player.trackArtist === "")
            return;
        cover.command = [Theme.coverFetch, player.trackArtist, player.trackAlbum];
        cover.running = true;
    }

    Timer {
        interval: 1000
        running: rail.visible
        repeat: true
        onTriggered: {
            rail.tick++;
            rail.pick();
        }
    }

    Process {
        id: cover
        stdout: StdioCollector {
            onStreamFinished: rail.fetchedArt = text.trim()
        }
    }

    // hold on to the player being shown rather than re-picking on every
    // state change: a browser tab pausing would otherwise swap the whole row
    property var chosen: null
    readonly property var player: chosen

    function pick(): void {
        const list = Mpris.players.values;
        if (chosen && list.indexOf(chosen) !== -1 && chosen.trackTitle !== "")
            return;
        for (let i = 0; i < list.length; i++) {
            if (list[i].isPlaying) {
                chosen = list[i];
                return;
            }
        }
        chosen = list.length ? list[0] : null;
    }

    Component.onCompleted: rail.pick()

    Connections {
        target: Mpris.players

        function onValuesChanged() {
            rail.pick();
        }
    }

    Rectangle {
        id: card
        width: parent.width
        implicitHeight: column.implicitHeight + 28
        radius: 22
        color: Theme.pill(0.40)
        border.width: 1
        border.color: Theme.hairline(0.24)

        ColumnLayout {
            id: column
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            // current conditions, then the week: the bar answers "do I need a
            // jacket", this answers "which day should I do this on"
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                visible: rail.expanded && Weather.known

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: Weather.temp + "°"
                        color: Theme.text
                        opacity: Weather.stale ? 0.45 : 1
                        font.family: "SF Pro Display"
                        font.pixelSize: 18
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.leftMargin: 6
                        text: Weather.cond
                        color: Theme.subtext
                        opacity: Weather.stale ? 0.45 : 1
                        font.family: "Noto Sans CJK JP"
                        font.pixelSize: 11
                    }
                }

                WeatherStrip {
                    Layout.fillWidth: true
                    opacity: Weather.stale ? 0.45 : 1
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Theme.hairline(0.18)
                }
            }

            // the rail's calendar is the one you browse: the bar popup stays
            // fixed on this month, this one walks
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                visible: rail.expanded

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        // a glyph is a small target, so the cell is the button
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 26
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: "‹"
                        color: prevHover.hovered ? Theme.text : Theme.subtext
                        font.family: "SF Pro Display"
                        font.pixelSize: 15

                        TapHandler {
                            onTapped: railGrid.shown = new Date(railGrid.shown.getFullYear(), railGrid.shown.getMonth() - 1, 1)
                        }

                        HoverHandler {
                            id: prevHover
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: railGrid.shown.getFullYear() + "年" + (railGrid.shown.getMonth() + 1) + "月"
                        color: Theme.text
                        font.family: "Noto Sans CJK JP"
                        font.pixelSize: 13
                        font.bold: true
                    }

                    Text {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 26
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: "›"
                        color: nextHover.hovered ? Theme.text : Theme.subtext
                        font.family: "SF Pro Display"
                        font.pixelSize: 15

                        TapHandler {
                            onTapped: railGrid.shown = new Date(railGrid.shown.getFullYear(), railGrid.shown.getMonth() + 1, 1)
                        }

                        HoverHandler {
                            id: nextHover
                        }
                    }
                }

                CalendarGrid {
                    id: railGrid
                    Layout.fillWidth: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Theme.hairline(0.18)
                }
            }

            // expanding only ever adds at the top
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                visible: rail.expanded && rail.todayRows.length > 0

                Repeater {
                    model: rail.todayRows.slice(0, 4)

                    RowLayout {
                        required property var modelData
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            visible: modelData.time !== ""
                            text: modelData.time
                            color: Theme.subtext
                            font.family: "SF Pro Display"
                            font.pixelSize: 11
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.title
                            color: Theme.text
                            elide: Text.ElideRight
                            font.family: "SF Pro Display"
                            font.pixelSize: 12
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Theme.hairline(0.18)
                }
            }

            // the always-there row is the handle, so the calendar above keeps
            // its own clicks. three columns, as in the sketch: what it is,
            // what it says, and the number that matters
            RowLayout {
                id: statusRow
                Layout.fillWidth: true
                Layout.preferredHeight: 22

                TapHandler {
                    onTapped: rail.expanded = !rail.expanded
                }

                Text {
                    Layout.preferredWidth: 42
                    text: "gen"
                    color: Theme.subtext
                    font.family: "SF Pro Display"
                    font.pixelSize: 11
                }

                Text {
                    Layout.fillWidth: true
                    text: Sys.genAge === ""
                        ? Sys.generation
                        : Sys.generation + " · " + Sys.genAge
                    color: Theme.text
                    font.family: "SF Pro Display"
                    font.pixelSize: 12
                }

                Text {
                    text: Sys.staleInputs + " stale"
                    color: Sys.staleInputs > 0 ? Theme.yellow : Theme.subtext
                    font.family: "SF Pro Display"
                    font.pixelSize: 11
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                visible: rail.hasTrack
                color: Theme.hairline(0.18)
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                visible: rail.hasTrack

                // circular, per the sketch; MultiEffect because a Rectangle
                // cannot clip an image to a rounded shape
                Item {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: 42
                    Layout.preferredHeight: 42

                    // the disc stays whatever happens, so a track without a
                    // cover has the same shape as one with it
                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: Theme.hairline(0.10)
                        border.width: 1
                        border.color: Theme.hairline(0.14)

                        Text {
                            anchors.centerIn: parent
                            visible: !cov.ready
                            text: "♪"
                            color: Theme.overlay
                            font.family: "Noto Sans CJK JP"
                            font.pixelSize: 15
                        }
                    }

                    Image {
                        id: cov
                        readonly property bool ready: rail.art !== "" && status === Image.Ready
                        anchors.fill: parent
                        source: rail.art
                        fillMode: Image.PreserveAspectCrop
                        visible: false
                    }

                    Rectangle {
                        id: covMask
                        anchors.fill: parent
                        radius: width / 2
                        visible: false
                        layer.enabled: true
                    }

                    MultiEffect {
                        anchors.fill: parent
                        visible: cov.ready
                        source: cov
                        maskEnabled: true
                        maskSource: covMask
                    }
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        Layout.fillWidth: true
                        text: rail.player ? rail.player.trackTitle : ""
                        color: Theme.text
                        elide: Text.ElideRight
                        font.family: "SF Pro Display"
                        font.pixelSize: 12
                    }

                    Text {
                        Layout.fillWidth: true
                        text: rail.player ? rail.player.trackArtist : ""
                        color: Theme.subtext
                        elide: Text.ElideRight
                        font.family: "SF Pro Display"
                        font.pixelSize: 11
                    }

                    // the sketch has a progress line under the artist; mpris
                    // only moves position when asked, so it is read on a tick
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 3
                        Layout.preferredHeight: 2
                        radius: 1
                        // the track stays put; only the fill answers to length,
                        // which reads zero for a moment between songs
                        visible: rail.hasTrack
                        color: Theme.hairline(0.22)

                        Rectangle {
                            width: {
                                const p = rail.player;
                                if (!p || !p.length)
                                    return 0;
                                rail.tick;
                                return parent.width * Math.min(1, p.position / p.length);
                            }
                            height: parent.height
                            radius: 1
                            color: Theme.accent
                        }
                    }
                }

                // the rail only shows on an empty workspace, so these are a
                // convenience; the media keys are the control that always works
                RowLayout {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 2
                    visible: rail.player

                    Repeater {
                        model: ["previous", "toggle", "next"]

                        Item {
                            required property string modelData

                            Layout.preferredWidth: 22
                            Layout.preferredHeight: 22

                            Icon {
                                anchors.centerIn: parent
                                size: 12
                                opacity: hover.hovered ? 1 : 0.55
                                source: modelData === "previous"
                                    ? Theme.iconPrev
                                    : modelData === "next"
                                        ? Theme.iconNext
                                        : rail.player && rail.player.isPlaying
                                            ? Theme.iconPause
                                            : Theme.iconPlay
                            }

                            TapHandler {
                                onTapped: rail.control(modelData)
                            }

                            HoverHandler {
                                id: hover
                            }
                        }
                    }
                }
            }
        }
    }
}
