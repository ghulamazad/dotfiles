pragma Singleton
// Desktop notifications. Quickshell itself is the notification daemon
// (org.freedesktop.Notifications), so do NOT run mako, dunst or swaync at the
// same time: only one program can own that D-Bus name.
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    readonly property var popups: server.trackedNotifications

    NotificationServer {
        id: server
        keepOnReload: false
        actionsSupported: true
        bodySupported: true
        imageSupported: true

        // Tracking keeps the notification alive; untracked ones are dropped.
        onNotification: notification => { notification.tracked = true; }
    }
}
