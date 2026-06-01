import QtQuick
import QtQuick.Layouts

Rectangle {
    id: island

    default property alias content: inner.data

    implicitWidth: inner.implicitWidth + 24
    implicitHeight: Theme.islandHeight
    radius: Theme.islandRadius
    color: Theme.island
    border.width: 1
    border.color: Theme.islandBorder

    RowLayout {
        id: inner
        anchors.centerIn: parent
        spacing: 10
    }
}
