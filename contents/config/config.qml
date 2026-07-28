pragma ComponentBehavior: Bound

import QtQuick
import org.kde.plasma.configuration
import org.kde.plasma.plasmoid

ConfigModel {
    ConfigCategory {
        name: i18n("General")
        icon: "configure"
        source: "settings/GeneralSettings.qml"
    }
    ConfigCategory {
        name: i18n("Coin List")
        icon: "list-add"
        source: "settings/CoinsSettings.qml"
        // Гарантуємо, що visible отримує строге булеве значення (true/false), а не undefined
        visible: (typeof Plasmoid !== "undefined" && Plasmoid && Plasmoid.formFactor !== undefined)
        ? (Plasmoid.formFactor !== 0)
        : true
    }
    ConfigCategory {
        name: i18n("Alerts")
        icon: "preferences-desktop-notification"
        source: "settings/AlertsSettings.qml"
    }
    ConfigCategory {
        name: i18n("Support & Info")
        icon: "help-donate"
        source: "settings/SupportSettings.qml"
    }
}
