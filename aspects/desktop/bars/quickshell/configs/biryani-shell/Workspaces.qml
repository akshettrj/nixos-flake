import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

RowLayout {
    id: root

    required property var screen
    readonly property var monitor: Hyprland.monitorFor(root.screen)

    spacing: 6

    Repeater {
        model: Hyprland.workspaces

        Rectangle {
            id: ws

            required property var modelData
            readonly property bool focused: Hyprland.focusedWorkspace
                && Hyprland.focusedWorkspace.id === modelData.id

            visible: ws.modelData.monitor === root.monitor

            implicitWidth: 22
            implicitHeight: 22
            radius: 4
            color: ws.focused ? Theme.primary : Theme.islandActive

            Text {
                anchors.centerIn: parent
                text: ws.modelData.id
                color: ws.focused ? Theme.on_primary : Theme.on_surface
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: ws.modelData.activate()
            }
        }
    }
}
