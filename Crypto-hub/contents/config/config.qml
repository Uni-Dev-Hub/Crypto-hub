pragma ComponentBehavior: Bound

import QtQuick
import org.kde.plasma.configuration
import org.kde.plasma.plasmoid

ConfigModel {
    ConfigCategory {
        name: i18nd("plasma_applet_org.kde.cryptohub", "General")
        icon: "configure"
        source: "settings/GeneralSettings.qml"
    }
    ConfigCategory {
        name: i18nd("plasma_applet_org.kde.cryptohub", "Coin List")
        icon: "list-add"
        source: "settings/CoinsSettings.qml"
        visible: (typeof Plasmoid !== "undefined" && Plasmoid && Plasmoid.formFactor !== undefined)
        ? (Plasmoid.formFactor !== 0)
        : true
    }
    ConfigCategory {
        name: i18nd("plasma_applet_org.kde.cryptohub", "Portfolio")
        icon: "wallet-open"
        source: "settings/PortfolioSettings.qml"
    }
    ConfigCategory {
        name: i18nd("plasma_applet_org.kde.cryptohub", "Alerts")
        icon: "preferences-desktop-notification"
        source: "settings/AlertsSettings.qml"
    }
    ConfigCategory {
        name: i18nd("plasma_applet_org.kde.cryptohub", "Backup & Restore")
        icon: "document-save-all"
        source: "settings/BackupSettings.qml"
    }
    ConfigCategory {
        name: i18nd("plasma_applet_org.kde.cryptohub", "Support & Info")
        icon: "help-donate"
        source: "settings/SupportSettings.qml"
    }
}
