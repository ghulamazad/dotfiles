// Compact CPU and RAM readout for the bar. Click opens the dashboard.
import QtQuick
import qs.components
import qs.services
import qs.themes

BarButton {
    onClicked: UIState.toggle("dashboard")

    Txt { text: Icons.cpu; color: Theme.subtext }
    Txt { text: Math.round(SysInfo.cpu * 100) + "%"; width: 34; horizontalAlignment: Text.AlignRight }
    Txt { text: "RAM"; color: Theme.subtext }
    Txt { text: Math.round(SysInfo.ramFraction * 100) + "%"; width: 34; horizontalAlignment: Text.AlignRight }
}
