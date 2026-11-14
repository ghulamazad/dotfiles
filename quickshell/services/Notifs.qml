pragma Singleton
// Desktop notifications. Quickshell itself is the notification daemon
// (org.freedesktop.Notifications), so do NOT run mako, dunst or swaync at the
// same time. Only one program can own that D-Bus name.
//
// tracked notifications  -> shown as popups (NotificationPopups.qml)
// history                -> plain copies kept for the notification center
// dnd                    -> suppresses popups except Critical ones
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    property bool dnd: false
    property var history: []   // newest first: { appName, summary, body, time }
    readonly property var popups: server.trackedNotifications

    function clearHistory() { history = []; }

    function dismissAll() {
        // Copy first: dismissing mutates the model while we iterate.
        for (const n of Array.from(server.trackedNotifications.values)) n.dismiss();
    }

    NotificationServer {
        id: server
        keepOnReload: false
        actionsSupported: true
        bodySupported: true
        imageSupported: true

        onNotification: notification => {
            root.history = [{
                appName: notification.appName,
                summary: notification.summary,
                body: notification.body,
                time: new Date()
            }].concat(root.history).slice(0, 50);

            // Do Not Disturb: keep it in history but never show a popup,
            // unless the sender marked it Critical.
            if (root.dnd && notification.urgency !== NotificationUrgency.Critical) return;

            // Tracking keeps the notification alive; untracked ones are dropped.
            notification.tracked = true;
        }
    }
}
