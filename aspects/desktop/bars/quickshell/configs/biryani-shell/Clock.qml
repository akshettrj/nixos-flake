import QtQuick

Text {
    id: clock

    color: Theme.on_surface
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize

    function update() {
        clock.text = Qt.formatDateTime(new Date(), "ddd dd MMM  hh:mm");
    }

    Component.onCompleted: update()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: clock.update()
    }
}
