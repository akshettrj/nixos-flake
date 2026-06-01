import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

Item {
    id: audio

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume: sink && sink.audio ? sink.audio.volume : 0
    readonly property bool muted: sink && sink.audio ? sink.audio.muted : false

    function icon() {
        if (audio.muted || audio.volume === 0)
            return "\u{F075F}"; // 󰝟 mute
        if (audio.volume < 0.34)
            return "\u{F057F}"; // 󰕿 low
        if (audio.volume < 0.67)
            return "\u{F0580}"; // 󰖀 medium
        return "\u{F057E}"; // 󰕾 high
    }

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    PwObjectTracker {
        objects: audio.sink ? [audio.sink] : []
    }

    RowLayout {
        id: row
        anchors.fill: parent
        spacing: 6

        Text {
            text: audio.icon()
            color: audio.muted ? Theme.warning : Theme.on_surface
            font.family: Theme.fontFamily
            font.pixelSize: Theme.iconSize
        }

        Text {
            text: Math.round(audio.volume * 100) + "%"
            color: Theme.on_surface
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (audio.sink && audio.sink.audio)
                audio.sink.audio.muted = !audio.sink.audio.muted;
        }
    }
}
