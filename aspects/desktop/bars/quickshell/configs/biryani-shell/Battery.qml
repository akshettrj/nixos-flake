import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower

RowLayout {
    id: battery

    readonly property var device: UPower.displayDevice
    readonly property int pct: device ? Math.round(device.percentage * 100) : 0
    readonly property bool charging: device && device.state === UPowerDeviceState.Charging
    readonly property bool full: device
        && (device.state === UPowerDeviceState.FullyCharged || battery.pct >= 100)

    readonly property bool warn: !battery.charging && !battery.full
    readonly property color statusColor: (battery.warn && battery.pct < 15) ? Theme.critical
        : (battery.warn && battery.pct < 40) ? Theme.warning
        : Theme.on_surface

    function icon() {
        if (battery.charging)
            return "\u{F0084}"; // 󰂄 charging
        if (battery.full || battery.pct >= 95)
            return "\u{F0079}"; // 󰁹 full
        if (battery.pct >= 85)
            return "\u{F0082}";
        if (battery.pct >= 75)
            return "\u{F0081}";
        if (battery.pct >= 65)
            return "\u{F0080}";
        if (battery.pct >= 55)
            return "\u{F007F}";
        if (battery.pct >= 45)
            return "\u{F007E}";
        if (battery.pct >= 35)
            return "\u{F007D}";
        if (battery.pct >= 25)
            return "\u{F007C}";
        if (battery.pct >= 15)
            return "\u{F007B}";
        return "\u{F007A}";
    }

    spacing: 6

    Text {
        text: battery.icon()
        color: battery.statusColor
        font.family: Theme.fontFamily
        font.pixelSize: Theme.iconSize
    }

    Text {
        text: battery.full ? "Full" : (battery.pct + "%")
        color: battery.statusColor
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }
}
