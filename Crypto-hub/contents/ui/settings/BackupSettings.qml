pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import QtQuick.Dialogs as QtDialogs
import QtCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support

// qmllint disable unqualified
// qmllint disable missing-property

Kirigami.ScrollablePage {
    id: backupPage
    title: i18n("Backup & Restore")
    topPadding: Kirigami.Units.smallSpacing

    readonly property string cfg_alertsJsonDefault: "{\"alerts\":[]}"
    readonly property int cfg_desktopCardTypeDefault: 0
    readonly property string cfg_favoriteCoinsDefault: ""
    readonly property bool cfg_showAnalysisCardsDefault: true
    readonly property bool cfg_showHalvingDefault: true
    readonly property bool cfg_showMiniCardsDefault: true
    readonly property bool cfg_showSummaryDefault: true
    readonly property bool cfg_showTablesDefault: true
    readonly property bool cfg_showTickerDefault: true
    readonly property int cfg_updateIntervalDefault: 5
    readonly property string cfg_vsCurrencyDefault: "usd"
    readonly property string cfg_portfolioJsonDefault: "{\"enabled\":false,\"hideBalance\":false,\"items\":[]}"

    property string cfg_alertsJson: "{\"alerts\":[]}"
    property int cfg_desktopCardType: 0
    property string cfg_favoriteCoins: ""
    property bool cfg_showAnalysisCards: true
    property bool cfg_showHalving: true
    property bool cfg_showMiniCards: true
    property bool cfg_showSummary: true
    property bool cfg_showTables: true
    property bool cfg_showTicker: true
    property int cfg_updateInterval: 5
    property string cfg_vsCurrency: "usd"
    property string cfg_portfolioJson: "{\"enabled\":false,\"hideBalance\":false,\"items\":[]}"

    property string statusMessage: ""
    property bool statusIsError: false
    property string lastSavedFileName: ""
    property string lastSavedFolderPath: ""

    property string loadedFileName: ""
    property string pendingFileName: ""
    property var loadedBundlePreview: null

    function getDownloadsPath() {
        try {
            var p = StandardPaths.writableLocation(StandardPaths.DownloadLocation);
            return p ? p.toString() : "";
        } catch(e) {
            return "";
        }
    }

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: function(sourceName, data) {
            disconnectSource(sourceName);
            var exitCode = data["exit code"] || 0;
            var stdout = (data["stdout"] || "").trim();

            if (sourceName.indexOf("base64 -w 0") !== -1) {
                if (exitCode === 0 && stdout.length > 0) {
                    try {
                        var decodedJson = decodeURIComponent(escape(Qt.atob(stdout)));
                        backupPage.parseBundleText(decodedJson, backupPage.pendingFileName);
                    } catch(e) {
                        backupPage.showStatus(i18n("Failed to parse JSON file: %1").arg(e.message), true);
                    }
                } else {
                    backupPage.showStatus(i18n("Could not read the selected file."), true);
                }
            } else if (sourceName.indexOf("mkdir -p") !== -1) {
                if (exitCode === 0) {
                    backupPage.showStatus(i18n("File \"%1\" successfully saved in %2!").arg(backupPage.lastSavedFileName).arg(backupPage.lastSavedFolderPath), false);
                } else {
                    backupPage.showStatus(i18n("Failed to write file (error code: %1)").arg(exitCode), true);
                }
            }
        }
        function exec(cmd) {
            executable.connectSource(cmd);
        }
    }

    Timer {
        id: statusClearTimer
        interval: 6000
        running: false
        repeat: false
        onTriggered: backupPage.statusMessage = ""
    }

    function showStatus(msg, isErr) {
        backupPage.statusMessage = msg;
        backupPage.statusIsError = isErr;
        statusClearTimer.restart();
    }

    function getFormattedDate() {
        var d = new Date();
        var pad = function(n) { return n < 10 ? "0" + n : n; };
        return d.getFullYear() + "-" + pad(d.getMonth() + 1) + "-" + pad(d.getDate());
    }

    function getDefaultBackupFileName() {
        return "crypto-hub-backup-" + getFormattedDate() + ".json";
    }

    function extractPathFromUrl(fileUrl) {
        if (!fileUrl) return "";
        var str = fileUrl.toString();
        if (str.indexOf("file://") === 0) {
            str = str.substring(7);
        }
        return decodeURIComponent(str);
    }

    function getSetting(key, fallback) {
        if (typeof Plasmoid !== "undefined" && Plasmoid && Plasmoid.configuration) {
            var v = Plasmoid.configuration[key];
            if (v !== undefined && v !== null) return v;
        }
        var pageVal = backupPage["cfg_" + key];
        if (pageVal !== undefined && pageVal !== null) return pageVal;
        return fallback;
    }

    function generateBackupBundle() {
        var favs = getSetting("favoriteCoins", "");
        var vsCur = getSetting("vsCurrency", "usd");
        var interval = getSetting("updateInterval", 5);
        var cardType = getSetting("desktopCardType", 0);
        var ticker = getSetting("showTicker", true);
        var summary = getSetting("showSummary", true);
        var mini = getSetting("showMiniCards", true);
        var analysis = getSetting("showAnalysisCards", true);
        var tables = getSetting("showTables", true);
        var halving = getSetting("showHalving", true);

        var alertsRaw = getSetting("alertsJson", "{\"alerts\":[]}");
        var portRaw = getSetting("portfolioJson", "{\"enabled\":false,\"hideBalance\":false,\"items\":[]}");

        var alertsObj = {"alerts": []};
        var portObj = {"enabled": false, "hideBalance": false, "items": []};

        try { alertsObj = JSON.parse(alertsRaw); } catch(e) {}
        try { portObj = JSON.parse(portRaw); } catch(e) {}

        var bundle = {
            "app": "Crypto-hub",
            "version": "1.1.0",
            "exportedAt": new Date().toISOString(),
            "settings": {
                "vsCurrency": vsCur,
                "updateInterval": interval,
                "desktopCardType": cardType,
                "showTicker": ticker,
                "showSummary": summary,
                "showMiniCards": mini,
                "showAnalysisCards": analysis,
                "showTables": tables,
                "showHalving": halving
            },
            "favoriteCoins": favs,
            "alerts": alertsObj,
            "portfolio": portObj
        };

        return JSON.stringify(bundle, null, 2);
    }

    function openSaveDialog() {
        var defaultFileName = getDefaultBackupFileName();
        var targetDir = backupPage.lastSavedFolderPath !== "" ? backupPage.lastSavedFolderPath : getDownloadsPath();
        if (!targetDir || targetDir === "") targetDir = "$HOME/Downloads";

        saveFileDialog.currentFolder = targetDir.indexOf("file://") === 0 ? targetDir : ("file://" + targetDir);
        saveFileDialog.currentFile = saveFileDialog.currentFolder + "/" + defaultFileName;
        saveFileDialog.open();
    }

    function openRestoreDialog() {
        var targetDir = backupPage.lastSavedFolderPath !== "" ? backupPage.lastSavedFolderPath : getDownloadsPath();
        if (targetDir && targetDir !== "") {
            openBackupDialog.currentFolder = targetDir.indexOf("file://") === 0 ? targetDir : ("file://" + targetDir);
        }
        openBackupDialog.open();
    }

    function saveToSelectedFile(fileUrl) {
        var fullPath = extractPathFromUrl(fileUrl);
        if (!fullPath) return;

        if (!fullPath.endsWith(".json")) {
            fullPath += ".json";
        }

        var fileName = fullPath.substring(fullPath.lastIndexOf('/') + 1);
        var folderPath = fullPath.substring(0, fullPath.lastIndexOf('/'));

        backupPage.lastSavedFileName = fileName;
        backupPage.lastSavedFolderPath = folderPath;

        var bundleText = generateBackupBundle();
        var utf8Text = unescape(encodeURIComponent(bundleText));
        var b64Data = Qt.btoa(utf8Text);

        var shellCmd = "bash -c 'mkdir -p \"" + folderPath + "\" && echo \"" + b64Data + "\" | base64 -d > \"" + fullPath + "\"'";
        executable.exec(shellCmd);
    }

    function parseBundleText(content, sourceName) {
        try {
            var bundle = JSON.parse(content);
            if (!bundle || typeof bundle !== "object") {
                showStatus(i18n("Invalid JSON backup structure."), true);
                return;
            }

            backupPage.loadedFileName = sourceName || "crypto-hub-backup.json";
            backupPage.loadedBundlePreview = bundle;
            showStatus(i18n("File \"%1\" verified! Click 'Restore from Selected File' to apply.").arg(backupPage.loadedFileName), false);
        } catch(e) {
            showStatus(i18n("Failed to parse JSON file: %1").arg(e.message), true);
        }
    }

    function readBackupFile(fileUrl) {
        var fullPath = extractPathFromUrl(fileUrl);
        if (!fullPath) {
            showStatus(i18n("Could not read the selected file."), true);
            return;
        }

        var cleanName = fullPath.substring(fullPath.lastIndexOf('/') + 1);
        backupPage.pendingFileName = cleanName;

        var cmd = "bash -c 'base64 -w 0 \"" + fullPath + "\"'";
        executable.exec(cmd);
    }

    function applyRestoration(bundle) {
        if (!bundle || typeof bundle !== "object") {
            showStatus(i18n("Invalid backup bundle."), true);
            return;
        }

        try {
            var hasPlasmoid = (typeof Plasmoid !== "undefined" && Plasmoid && Plasmoid.configuration);

            // 1. Налаштування
            var s = bundle.settings || {};
            var vsCur = s.vsCurrency !== undefined ? s.vsCurrency : (bundle.vsCurrency !== undefined ? bundle.vsCurrency : "usd");
            var interval = s.updateInterval !== undefined ? parseInt(s.updateInterval) : (bundle.updateInterval !== undefined ? parseInt(bundle.updateInterval) : 5);
            var cardType = s.desktopCardType !== undefined ? parseInt(s.desktopCardType) : (bundle.desktopCardType !== undefined ? parseInt(bundle.desktopCardType) : 0);
            var ticker = s.showTicker !== undefined ? !!s.showTicker : (bundle.showTicker !== undefined ? !!bundle.showTicker : true);
            var summary = s.showSummary !== undefined ? !!s.showSummary : (bundle.showSummary !== undefined ? !!bundle.showSummary : true);
            var mini = s.showMiniCards !== undefined ? !!s.showMiniCards : (bundle.showMiniCards !== undefined ? !!bundle.showMiniCards : true);
            var analysis = s.showAnalysisCards !== undefined ? !!s.showAnalysisCards : (bundle.showAnalysisCards !== undefined ? !!bundle.showAnalysisCards : true);
            var tables = s.showTables !== undefined ? !!s.showTables : (bundle.showTables !== undefined ? !!bundle.showTables : true);
            var halving = s.showHalving !== undefined ? !!s.showHalving : (bundle.showHalving !== undefined ? !!bundle.showHalving : true);

            backupPage.cfg_vsCurrency = vsCur;
            backupPage.cfg_updateInterval = interval;
            backupPage.cfg_desktopCardType = cardType;
            backupPage.cfg_showTicker = ticker;
            backupPage.cfg_showSummary = summary;
            backupPage.cfg_showMiniCards = mini;
            backupPage.cfg_showAnalysisCards = analysis;
            backupPage.cfg_showTables = tables;
            backupPage.cfg_showHalving = halving;

            if (hasPlasmoid) {
                Plasmoid.configuration.vsCurrency = vsCur;
                Plasmoid.configuration.updateInterval = interval;
                Plasmoid.configuration.desktopCardType = cardType;
                Plasmoid.configuration.showTicker = ticker;
                Plasmoid.configuration.showSummary = summary;
                Plasmoid.configuration.showMiniCards = mini;
                Plasmoid.configuration.showAnalysisCards = analysis;
                Plasmoid.configuration.showTables = tables;
                Plasmoid.configuration.showHalving = halving;
            }

            // 2. Список монет
            var cStr = "";
            if (bundle.favoriteCoins !== undefined) {
                cStr = typeof bundle.favoriteCoins === "string" ? bundle.favoriteCoins.trim() : (Array.isArray(bundle.favoriteCoins) ? bundle.favoriteCoins.join(",") : "");
            }
            backupPage.cfg_favoriteCoins = cStr;
            if (hasPlasmoid) Plasmoid.configuration.favoriteCoins = cStr;

            // 3. Сповіщення
            var aStr = "{\"alerts\":[]}";
            if (bundle.alerts !== undefined) {
                aStr = typeof bundle.alerts === "string" ? bundle.alerts : JSON.stringify(bundle.alerts);
            }
            backupPage.cfg_alertsJson = aStr;
            if (hasPlasmoid) Plasmoid.configuration.alertsJson = aStr;

            // 4. Портфель
            var pStr = "{\"enabled\":false,\"hideBalance\":false,\"items\":[]}";
            if (bundle.portfolio !== undefined) {
                pStr = typeof bundle.portfolio === "string" ? bundle.portfolio : JSON.stringify(bundle.portfolio);
            }
            backupPage.cfg_portfolioJson = pStr;
            if (hasPlasmoid) Plasmoid.configuration.portfolioJson = pStr;

            var coinCount = cStr !== "" ? cStr.split(",").filter(function(x){return x.trim()!=="";}).length : 0;
            showStatus(i18n("Backup successfully restored! Watchlist (%1 coins) and all settings are applied.").arg(coinCount), false);

            backupPage.loadedFileName = "";
            backupPage.loadedBundlePreview = null;
        } catch(e) {
            showStatus(i18n("Failed to parse JSON file: %1").arg(e.message), true);
        }
    }

    function resetToDefaults() {
        var hasPlasmoid = (typeof Plasmoid !== "undefined" && Plasmoid && Plasmoid.configuration);

        backupPage.cfg_vsCurrency = backupPage.cfg_vsCurrencyDefault;
        backupPage.cfg_updateInterval = backupPage.cfg_updateIntervalDefault;
        backupPage.cfg_desktopCardType = backupPage.cfg_desktopCardTypeDefault;
        backupPage.cfg_showTicker = backupPage.cfg_showTickerDefault;
        backupPage.cfg_showSummary = backupPage.cfg_showSummaryDefault;
        backupPage.cfg_showMiniCards = backupPage.cfg_showMiniCardsDefault;
        backupPage.cfg_showAnalysisCards = backupPage.cfg_showAnalysisCardsDefault;
        backupPage.cfg_showTables = backupPage.cfg_showTablesDefault;
        backupPage.cfg_showHalving = backupPage.cfg_showHalvingDefault;
        backupPage.cfg_favoriteCoins = backupPage.cfg_favoriteCoinsDefault;
        backupPage.cfg_alertsJson = backupPage.cfg_alertsJsonDefault;
        backupPage.cfg_portfolioJson = backupPage.cfg_portfolioJsonDefault;

        if (hasPlasmoid) {
            Plasmoid.configuration.vsCurrency = backupPage.cfg_vsCurrencyDefault;
            Plasmoid.configuration.updateInterval = backupPage.cfg_updateIntervalDefault;
            Plasmoid.configuration.desktopCardType = backupPage.cfg_desktopCardTypeDefault;
            Plasmoid.configuration.showTicker = backupPage.cfg_showTickerDefault;
            Plasmoid.configuration.showSummary = backupPage.cfg_showSummaryDefault;
            Plasmoid.configuration.showMiniCards = backupPage.cfg_showMiniCardsDefault;
            Plasmoid.configuration.showAnalysisCards = backupPage.cfg_showAnalysisCardsDefault;
            Plasmoid.configuration.showTables = backupPage.cfg_showTablesDefault;
            Plasmoid.configuration.showHalving = backupPage.cfg_showHalvingDefault;
            Plasmoid.configuration.favoriteCoins = backupPage.cfg_favoriteCoinsDefault;
            Plasmoid.configuration.alertsJson = backupPage.cfg_alertsJsonDefault;
            Plasmoid.configuration.portfolioJson = backupPage.cfg_portfolioJsonDefault;
        }

        showStatus(i18n("All settings have been reset to defaults."), false);
    }

    readonly property int favCoinsCount: {
        var s = getSetting("favoriteCoins", "").trim();
        if (s === "") return 0;
        return s.split(",").filter(function(x) { return x.trim() !== ""; }).length;
    }

    readonly property int alertsCount: {
        try {
            var a = JSON.parse(getSetting("alertsJson", "{\"alerts\":[]}") || "{}");
            return Array.isArray(a.alerts) ? a.alerts.length : 0;
        } catch(e) { return 0; }
    }

    readonly property int portfolioAssetsCount: {
        try {
            var p = JSON.parse(getSetting("portfolioJson", "{\"enabled\":false,\"hideBalance\":false,\"items\":[]}") || "{}");
            return Array.isArray(p.items) ? p.items.length : 0;
        } catch(e) { return 0; }
    }

    QtDialogs.FileDialog {
        id: saveFileDialog
        title: i18n("Save Backup File (.json)")
        fileMode: QtDialogs.FileDialog.SaveFile
        nameFilters: [ i18n("JSON Backup files (*.json)"), i18n("All files (*)") ]
        defaultSuffix: "json"
        onAccepted: {
            if (selectedFile) {
                backupPage.saveToSelectedFile(selectedFile);
            }
        }
    }

    QtDialogs.FileDialog {
        id: openBackupDialog
        title: i18n("Select Backup File (.json)")
        fileMode: QtDialogs.FileDialog.OpenFile
        nameFilters: [ i18n("JSON Backup files (*.json)"), i18n("All files (*)") ]
        onAccepted: {
            if (selectedFile) {
                backupPage.readBackupFile(selectedFile);
            }
        }
    }

    ColumnLayout {
        width: parent.width
        spacing: Kirigami.Units.mediumSpacing

        // Статусне повідомлення
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: statusLbl.implicitHeight + 16
            visible: backupPage.statusMessage !== ""
            radius: 8
            color: backupPage.statusIsError
            ? Qt.rgba(Kirigami.Theme.negativeTextColor.r, Kirigami.Theme.negativeTextColor.g, Kirigami.Theme.negativeTextColor.b, 0.16)
            : Qt.rgba(Kirigami.Theme.positiveTextColor.r, Kirigami.Theme.positiveTextColor.g, Kirigami.Theme.positiveTextColor.b, 0.16)
            border.color: backupPage.statusIsError ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.positiveTextColor
            border.width: 1

            PlasmaComponents.Label {
                id: statusLbl
                anchors.fill: parent
                anchors.margins: 8
                text: backupPage.statusMessage
                font.bold: true
                font.pointSize: 9
                color: backupPage.statusIsError ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.positiveTextColor
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
            }
        }

        // БЛОК 1: ЗБЕРЕЖЕННЯ
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: saveCol.implicitHeight + Kirigami.Units.mediumSpacing * 2
            color: Kirigami.Theme.alternateBackgroundColor
            radius: 10
            border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
            border.width: 1

            ColumnLayout {
                id: saveCol
                anchors.fill: parent
                anchors.margins: Kirigami.Units.mediumSpacing
                spacing: Kirigami.Units.smallSpacing

                RowLayout {
                    spacing: 8
                    Kirigami.Icon {
                        source: "document-save-as"
                        implicitWidth: 18
                        implicitHeight: 18
                        color: Kirigami.Theme.highlightColor
                    }
                    Controls.Label {
                        text: i18n("Save Backup to File (.json)")
                        font.bold: true
                        font.pointSize: 10
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.largeSpacing

                    PlasmaComponents.Label {
                        text: i18n("Watchlist: %1 coins").arg(backupPage.favCoinsCount)
                        font.pointSize: 8.5
                        opacity: 0.8
                    }

                    PlasmaComponents.Label {
                        text: i18n("Portfolio: %1 assets").arg(backupPage.portfolioAssetsCount)
                        font.pointSize: 8.5
                        opacity: 0.8
                    }

                    PlasmaComponents.Label {
                        text: i18n("Alerts: %1 rules").arg(backupPage.alertsCount)
                        font.pointSize: 8.5
                        opacity: 0.8
                    }
                }

                RowLayout {
                    spacing: Kirigami.Units.smallSpacing
                    Layout.topMargin: 4

                    Controls.Button {
                        text: i18n("Save Backup to File (.json)...")
                        icon.name: "document-save-as"
                        onClicked: backupPage.openSaveDialog()
                    }
                }
            }
        }

        // БЛОК 2: ВІДНОВЛЕННЯ
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: restoreCol.implicitHeight + Kirigami.Units.mediumSpacing * 2
            color: Kirigami.Theme.alternateBackgroundColor
            radius: 10
            border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
            border.width: 1

            ColumnLayout {
                id: restoreCol
                anchors.fill: parent
                anchors.margins: Kirigami.Units.mediumSpacing
                spacing: Kirigami.Units.smallSpacing

                RowLayout {
                    spacing: 8
                    Kirigami.Icon {
                        source: "document-open"
                        implicitWidth: 18
                        implicitHeight: 18
                        color: Kirigami.Theme.highlightColor
                    }
                    Controls.Label {
                        text: i18n("Restore from File (.json)")
                        font.bold: true
                        font.pointSize: 10
                    }
                }

                RowLayout {
                    spacing: Kirigami.Units.smallSpacing
                    Layout.fillWidth: true

                    Controls.Button {
                        text: i18n("Choose Backup File (.json)...")
                        icon.name: "document-open"
                        onClicked: backupPage.openRestoreDialog()
                    }

                    PlasmaComponents.Label {
                        text: backupPage.loadedFileName !== "" ? backupPage.loadedFileName : i18n("No file chosen")
                        font.pointSize: 8.5
                        opacity: backupPage.loadedFileName !== "" ? 1.0 : 0.5
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                }

                // Попередній перегляд знайдених даних
                Rectangle {
                    Layout.fillWidth: true
                    visible: backupPage.loadedBundlePreview !== null
                    implicitHeight: previewCol.implicitHeight + 14
                    radius: 6
                    color: Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.08)
                    border.color: Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.25)
                    border.width: 1

                    ColumnLayout {
                        id: previewCol
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 4

                        PlasmaComponents.Label {
                            text: i18n("Valid Backup File Detected:")
                            font.bold: true
                            font.pointSize: 8.5
                            color: Kirigami.Theme.highlightColor
                        }

                        RowLayout {
                            spacing: Kirigami.Units.largeSpacing

                            PlasmaComponents.Label {
                                text: i18n("Coins: %1").arg(
                                    backupPage.loadedBundlePreview && backupPage.loadedBundlePreview.favoriteCoins
                                    ? backupPage.loadedBundlePreview.favoriteCoins.split(",").filter(function(x){return x.trim()!=="";}).length
                                    : 0
                                )
                                font.pointSize: 8
                                opacity: 0.85
                            }

                            PlasmaComponents.Label {
                                text: i18n("Portfolio: %1 assets").arg(
                                    backupPage.loadedBundlePreview && backupPage.loadedBundlePreview.portfolio && Array.isArray(backupPage.loadedBundlePreview.portfolio.items)
                                    ? backupPage.loadedBundlePreview.portfolio.items.length
                                    : 0
                                )
                                font.pointSize: 8
                                opacity: 0.85
                            }

                            PlasmaComponents.Label {
                                text: i18n("Alerts: %1 rules").arg(
                                    backupPage.loadedBundlePreview && backupPage.loadedBundlePreview.alerts && Array.isArray(backupPage.loadedBundlePreview.alerts.alerts)
                                    ? backupPage.loadedBundlePreview.alerts.alerts.length
                                    : 0
                                )
                                font.pointSize: 8
                                opacity: 0.85
                            }
                        }
                    }
                }

                RowLayout {
                    spacing: Kirigami.Units.smallSpacing
                    visible: backupPage.loadedBundlePreview !== null
                    Layout.topMargin: 2

                    Controls.Button {
                        text: i18n("Restore from Selected File")
                        icon.name: "document-revert"
                        onClicked: backupPage.applyRestoration(backupPage.loadedBundlePreview)
                    }

                    Controls.Button {
                        text: i18n("Cancel")
                        icon.name: "dialog-cancel"
                        onClicked: {
                            backupPage.loadedFileName = "";
                            backupPage.loadedBundlePreview = null;
                        }
                    }
                }
            }
        }

        // БЛОК 3: СКИДАННЯ ДО ДЕФОЛТУ
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Factory Reset")
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.mediumSpacing

            Controls.Button {
                text: i18n("Reset All to Defaults")
                icon.name: "edit-delete"
                onClicked: resetConfirmDialog.open()
            }

            Controls.Label {
                text: i18n("Clears watchlist, alerts, portfolio, and restores initial settings.")
                font.pointSize: 8
                opacity: 0.6
                Layout.fillWidth: true
                wrapMode: Text.Wrap
            }
        }

        Kirigami.PromptDialog {
            id: resetConfirmDialog
            title: i18n("Reset All Settings?")
            subtitle: i18n("Are you sure you want to reset all Crypto-hub settings, watchlist, alerts, and portfolio to default values? This action cannot be undone unless you have a backup.")
            standardButtons: Kirigami.Dialog.Yes | Kirigami.Dialog.No
            onAccepted: backupPage.resetToDefaults()
        }
    }
}
