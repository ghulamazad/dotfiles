// Battery panel: charge level, state, time left, and the power profile
// (Power saver / Balanced / Performance, through power-profiles-daemon).
// UNTESTED at runtime.
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.components
import qs.config
import qs.services
import qs.themes

Variants {
    model: Quickshell.screens

    PopPanel {
        id: win
        required property var modelData
        screen: modelData
        name: "battery"

        readonly property bool full: Battery.present && Battery.device !== null
                                     && Battery.device.state === UPowerDeviceState.FullyCharged
        readonly property string stateText: !Battery.present ? "NO BATTERY"
            : Battery.charging ? "CHARGING" : (full ? "FULLY CHARGED" : "ON BATTERY")

        PanelHeader { title: "Battery" }

        SectionLabel { text: win.stateText; width: parent.width; color: Battery.charging ? Theme.green : Theme.subtext }

        Txt {
            width: parent.width
            visible: Battery.present
            text: Battery.percent + "%"
            font.pixelSize: Config.px(34)
            font.bold: true
            color: Battery.low ? Theme.red : Theme.text
        }

        Meter {
            visible: Battery.present
            label: Battery.timeText === "" ? "" : (Battery.charging ? "TIME TO FULL" : "TIME LEFT")
            valueText: Battery.timeText
            fraction: Battery.fraction
            barColor: Battery.low ? Theme.red : (Battery.charging ? Theme.green : Theme.accent)
        }

        Divider { visible: Battery.present }

        Column {
            width: parent.width
            spacing: Config.px(8)
            visible: Battery.present

            SectionLabel { text: "POWER PROFILE" }
            Row {
                width: parent.width
                spacing: Config.px(6)
                Choice {
                    count: PowerProfiles.hasPerformanceProfile ? 3 : 2
                    label: "Saver"
                    active: PowerProfiles.profile === PowerProfile.PowerSaver
                    onClicked: PowerProfiles.profile = PowerProfile.PowerSaver
                }
                Choice {
                    count: PowerProfiles.hasPerformanceProfile ? 3 : 2
                    label: "Balanced"
                    active: PowerProfiles.profile === PowerProfile.Balanced
                    onClicked: PowerProfiles.profile = PowerProfile.Balanced
                }
                Choice {
                    visible: PowerProfiles.hasPerformanceProfile
                    count: 3
                    label: "Performance"
                    active: PowerProfiles.profile === PowerProfile.Performance
                    onClicked: PowerProfiles.profile = PowerProfile.Performance
                }
            }
        }

        Txt {
            width: parent.width
            visible: !Battery.present
            wrapMode: Text.WordWrap
            text: "No battery found on this machine."
            color: Theme.subtext
        }
    }
}
