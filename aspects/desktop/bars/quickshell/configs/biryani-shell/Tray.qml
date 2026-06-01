import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell.Widgets

RowLayout {
    spacing: 8

    Repeater {
        model: SystemTray.items

        IconImage {
            id: item

            required property var modelData

            implicitSize: 18
            source: item.modelData.icon

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: mouse => {
                    if (mouse.button === Qt.LeftButton)
                        item.modelData.activate();
                    else
                        item.modelData.secondaryActivate();
                }
            }
        }
    }
}
