import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower

PanelWindow {
    id: bar

    required property var modelData
    screen: modelData

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Theme.barHeight
    color: Theme.barBackground

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 8

        Island {
            Layout.alignment: Qt.AlignVCenter

            Workspaces {
                screen: bar.modelData
            }
        }

        Item {
            Layout.fillWidth: true
        }

        Island {
            Layout.alignment: Qt.AlignVCenter

            Clock {}
        }

        Item {
            Layout.fillWidth: true
        }

        Island {
            Layout.alignment: Qt.AlignVCenter

            Audio {}

            Mic {}
        }

        Island {
            Layout.alignment: Qt.AlignVCenter
            visible: UPower.displayDevice && UPower.displayDevice.isPresent

            Battery {}
        }

        Island {
            Layout.alignment: Qt.AlignVCenter

            Tray {}
        }
    }
}
