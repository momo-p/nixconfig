import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import "."

PanelWindow {
    id: rail

    property bool expanded: false

    WlrLayershell.namespace: "quickshell-rail"

    anchors.bottom: true
    anchors.right: true
    margins.bottom: Theme.edge
    margins.right: Theme.edge
    exclusionMode: ExclusionMode.Ignore

    implicitWidth: Theme.cardWidth
    implicitHeight: card.implicitHeight
    color: "transparent"

    visible: Sys.desktopEmpty
    onVisibleChanged: {
        if (!visible) {
            expanded = false;
            railGrid.shown = new Date();
            railGrid.selected = 0;
        } else {
            rail.probe();
        }
    }

    readonly property string pickedKey: railGrid.selected > 0
        ? railGrid.dateKey(railGrid.selected)
        : Sys.today

    readonly property var todayRows: Agenda.on(pickedKey)

    readonly property var pickedDay: railGrid.selected > 0
        ? Weather.dayOn(pickedKey)
        : null

    // a cache from before the hourly fields still has the day
    readonly property bool pickedHours: pickedDay !== null
        && pickedDay.hours !== undefined
        && pickedDay.hours.t !== undefined

    property var hosts: []
    property string relay: ""

    readonly property int hostsUp: {
        let n = 0;
        for (let i = 0; i < hosts.length; i++)
            if (hosts[i])
                n++;
        return n;
    }

    function probe(): void {
        ts.running = true;
        mv.running = true;
    }

    Process {
        id: ts
        command: [Theme.tailscale, "status", "--json"]
        stdout: StdioCollector {
            onStreamFinished: {
                let out = [];
                try {
                    const d = JSON.parse(text);
                    if (d.BackendState === "Running") {
                        out.push(d.Self && d.Self.Online === true);
                        for (const k in d.Peer)
                            out.push(d.Peer[k].Online === true);
                    }
                } catch (e) {
                    out = [];
                }
                rail.hosts = out;
            }
        }
    }

    Process {
        id: mv
        command: [Theme.mullvad, "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                const r = text.match(/Relay:\s+(\S+)/);
                rail.relay = r ? r[1] : "";
            }
        }
    }

    Connections {
        target: Sys

        function onVpnChanged() {
            if (rail.visible)
                mv.running = true;
        }
    }

    Timer {
        interval: 60000
        running: rail.visible
        repeat: true
        onTriggered: rail.probe()
    }

    readonly property bool hasTrack: player && player.trackTitle !== ""

    property int tick: 0
    property string fetchedArt: ""
    readonly property string art: {
        if (player && player.trackArtUrl !== "")
            return player.trackArtUrl;
        return fetchedArt === "" ? "" : "file://" + fetchedArt;
    }

    // hasTrack stays true across a track change, and metadata lands field by field
    readonly property string coverKey: hasTrack
        && player.trackArtUrl === ""
        && player.trackArtist !== ""
        ? player.trackArtist + "\n" + player.trackAlbum
        : ""

    onCoverKeyChanged: rail.lookUp()

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
        // the command is ignored while the previous lookup is still running
        cover.running = false;
        if (coverKey === "")
            return;
        cover.key = coverKey;
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
        property string key: ""
        stdout: StdioCollector {
            // a lookup that outlived its track must not overwrite the current art
            onStreamFinished: {
                if (cover.key === rail.coverKey)
                    rail.fetchedArt = text.trim();
            }
        }
    }

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

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                visible: rail.expanded

                RowLayout {
                    Layout.fillWidth: true

                    Text {
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

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 2
                    spacing: 4
                    visible: rail.pickedDay !== null

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: (railGrid.shown.getMonth() + 1) + "/" + railGrid.selected
                            color: Theme.text
                            font.family: "SF Pro Display"
                            font.pixelSize: 11
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: hourly.at >= 0
                                ? hourly.at + "時　" + hourly.atTemp + "°　降水 " + hourly.atRain + "%"
                                : rail.pickedDay
                                    ? rail.pickedDay.hi + "° / " + rail.pickedDay.lo + "°　降水 " + rail.pickedDay.rain + "%"
                                    : ""
                            color: hourly.at >= 0 ? Theme.text : Theme.subtext
                            font.family: "Noto Sans CJK JP"
                            font.pixelSize: 11
                        }
                    }

                    HourStrip {
                        id: hourly
                        Layout.fillWidth: true
                        visible: rail.pickedHours
                        day: rail.pickedDay
                    }
                }

                Text {
                    Layout.fillWidth: true
                    visible: railGrid.selected > 0 && rail.pickedDay === null
                    text: (railGrid.shown.getMonth() + 1) + "/" + railGrid.selected + "　予報なし"
                    color: Theme.overlay
                    font.family: "Noto Sans CJK JP"
                    font.pixelSize: 11
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Theme.hairline(0.18)
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                visible: rail.expanded && (rail.todayRows.length > 0 || railGrid.selected > 0)

                Text {
                    Layout.fillWidth: true
                    visible: rail.todayRows.length === 0
                    text: "予定なし"
                    color: Theme.overlay
                    font.family: "Noto Sans CJK JP"
                    font.pixelSize: 12
                }

                Repeater {
                    model: rail.todayRows.slice(0, 4)

                    RowLayout {
                        required property var modelData
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            Layout.preferredWidth: 3
                            Layout.fillHeight: true
                            radius: 1.5
                            color: Agenda.colorOf(modelData.cal)
                        }

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

                Text {
                    Layout.fillWidth: true
                    visible: rail.todayRows.length > 4
                    text: "他 " + (rail.todayRows.length - 4) + " 件"
                    color: Theme.overlay
                    font.family: "Noto Sans CJK JP"
                    font.pixelSize: 11
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Theme.hairline(0.18)
                }
            }

            ColumnLayout {
                id: statusRow
                Layout.fillWidth: true
                spacing: 3

                TapHandler {
                    onTapped: rail.expanded = !rail.expanded
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 22

                    Text {
                        Layout.preferredWidth: 42
                        text: "vpn"
                        color: Theme.subtext
                        font.family: "SF Pro Display"
                        font.pixelSize: 11
                    }

                    Text {
                        Layout.fillWidth: true
                        text: rail.relay
                        color: Sys.vpn === "Connected" ? Theme.text : Theme.subtext
                        elide: Text.ElideRight
                        font.family: "SF Pro Display"
                        font.pixelSize: 12
                    }

                    Text {
                        text: Sys.vpn.toLowerCase()
                        color: Sys.vpn === "Connected"
                            ? Theme.green
                            : Sys.vpn === "Disconnected"
                                ? Theme.subtext
                                : Sys.vpn === "Blocked"
                                    ? Theme.red
                                    : Theme.yellow
                        font.family: "SF Pro Display"
                        font.pixelSize: 11
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 22
                    visible: rail.hosts.length > 0

                    Text {
                        Layout.preferredWidth: 42
                        text: "hosts"
                        color: Theme.subtext
                        font.family: "SF Pro Display"
                        font.pixelSize: 11
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Repeater {
                            model: rail.hosts

                            Rectangle {
                                required property var modelData

                                implicitWidth: 7
                                implicitHeight: 7
                                radius: 3.5
                                color: modelData ? Theme.green : Theme.hairline(0.25)
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }
                    }

                    Text {
                        text: rail.hostsUp + " / " + rail.hosts.length + " up"
                        color: rail.hostsUp === rail.hosts.length ? Theme.subtext : Theme.yellow
                        font.family: "SF Pro Display"
                        font.pixelSize: 11
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 22

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

                // a Rectangle cannot clip an image to a rounded shape
                Item {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: 42
                    Layout.preferredHeight: 42

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

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 3
                        Layout.preferredHeight: 2
                        radius: 1
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
