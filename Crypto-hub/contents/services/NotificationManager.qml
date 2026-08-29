pragma ComponentBehavior: Bound

import QtQuick
import org.kde.notification as KNotification

Item {
    id: notificationManager

    KNotification.Notification {
        id: sysNotification
        componentName: "plasma_workspace"
        eventId: "warning"
        title: i18n("Crypto-hub")
        text: ""
        iconName: "notifications-symbolic"
    }

    function sendNotification(titleText, bodyText) {
        sysNotification.title = titleText;
        sysNotification.text = bodyText;
        sysNotification.sendEvent();
    }

    function sendTestNotification() {
        sendNotification(
            i18n("Crypto-hub"),
                         i18n("Test notification is working correctly!")
        );
    }
}
