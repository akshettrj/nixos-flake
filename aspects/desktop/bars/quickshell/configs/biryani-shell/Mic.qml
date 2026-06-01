import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

Item {
    id: mic

    readonly property var source: Pipewire.defaultAudioSource
    readonly property bool muted: source && source.audio ? source.audio.muted : false
    readonly property real volume: source && source.audio ? source.audio.volume : 0

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    PwObjectTracker {
        objects: mic.source ? [mic.source] : []
    }

    RowLayout {
        id: row
        anchors.fill: parent
        spacing: 6

        Text {
            text: mic.muted ? "\u{F036D}" : "\u{F036C}" // 󰍭 off / 󰍬 on
            color: mic.muted ? Theme.warning : Theme.on_surface
            font.family: Theme.fontFamily
            font.pixelSize: Theme.iconSize
        }

        Text {
            text: mic.muted ? "muted" : (Math.round(mic.volume * 100) + "%")
            color: Theme.on_surface
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (mic.source && mic.source.audio)
                mic.source.audio.muted = !mic.source.audio.muted;
        }
    }
}
