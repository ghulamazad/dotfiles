pragma Singleton
// Battery through UPower (Quickshell.Services.UPower). Hidden entirely on
// machines without a laptop battery, such as a VM or desktop.
import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root

    // True only if some real device is a laptop battery.
    // Array.from: a QML `list` is array-like but not guaranteed to have array methods.
    readonly property bool present: Array.from(UPower.devices.values).some(d => d.isLaptopBattery)

    readonly property var device: UPower.displayDevice
    // Quickshell reports percentage as a fraction 0.0 to 1.0 (verified in its
    // source: the D-Bus value is multiplied by 0.01), not 0 to 100.
    readonly property real fraction: present && device ? device.percentage : 0
    readonly property int percent: Math.round(fraction * 100)
    readonly property bool charging: present && device !== null && device.state === UPowerDeviceState.Charging
    readonly property bool low: present && !charging && fraction <= 0.15
}
