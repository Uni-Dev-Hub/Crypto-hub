pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import "../services" as Services
import "../code/alertEngine.js" as AlertEngine
import "../code/marketSummary.js" as MarketSummary
import "../code/constants.js" as Constants

// qmllint disable unqualified
// qmllint disable missing-property

PlasmoidItem {
    id: root

    Plasmoid.icon: "office-chart-line-percentage"
    Plasmoid.title: "Crypto-hub"

    // Декларативні тригери локалізації для текстів аналітики
    readonly property var _trTT1: i18n("Market consolidation phase in progress.")
    readonly property var _trTT2: i18n("Extreme market fear with high volatility and panic selling.")
    readonly property var _trTT3: i18n("Strong market growth and active buying momentum.")
    readonly property var _trTT4: i18n("Altseason in full swing as altcoins outperform BTC.")
    readonly property var _trTT5: i18n("Market correction phase. High caution among buyers.")
    readonly property var _trTT6: i18n("Market is in an accumulation and consolidation range.")

    property string summaryStatus: i18n("Accumulation ⚖️")
    property string shortSummaryDesc: i18n("Loading market analytics data...")
    property var currentMarketState: null

    // Нативна спливаюча підказка Plasma 6
    toolTipItem: Item {
        id: tooltipRoot
        implicitWidth: toolTipCol.implicitWidth + 16
        implicitHeight: toolTipCol.implicitHeight + 16

        readonly property color statusColor: {
            if (root.currentMarketState) {
                if (root.currentMarketState.isBearish) return Kirigami.Theme.negativeTextColor;
                if (root.currentMarketState.isBullish) return Kirigami.Theme.positiveTextColor;
                if (root.currentMarketState.isAltseason) return Kirigami.Theme.highlightColor;
                return Kirigami.Theme.neutralTextColor;
            }

            var status = root.summaryStatus || "";
            if (status.indexOf("🐻") !== -1 || status.indexOf("🚨") !== -1 || status.indexOf("😱") !== -1) {
                return Kirigami.Theme.negativeTextColor;
            }
            if (status.indexOf("🚀") !== -1 || status.indexOf("🟢") !== -1 || status.indexOf("🐂") !== -1) {
                return Kirigami.Theme.positiveTextColor;
            }
            if (status.indexOf("⚡") !== -1) {
                return Kirigami.Theme.highlightColor;
            }
            return Kirigami.Theme.neutralTextColor;
        }

        ColumnLayout {
            id: toolTipCol
            anchors.fill: parent
            anchors.margins: 8
            spacing: 6

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Kirigami.Icon {
                    source: "office-chart-line-percentage"
                    implicitWidth: 16
                    implicitHeight: 16
                    color: tooltipRoot.statusColor
                }

                PlasmaComponents.Label {
                    text: "Crypto-hub • " + root.summaryStatus
                    font.bold: true
                    font.pointSize: 9.5
                    color: tooltipRoot.statusColor
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Kirigami.Theme.textColor
                opacity: 0.12
            }

            PlasmaComponents.Label {
                text: root.shortSummaryDesc
                font.pointSize: 8.5
                wrapMode: Text.Wrap
                Layout.preferredWidth: 260
                Layout.fillWidth: true
                lineHeight: 1.18
                opacity: 0.95
            }
        }
    }

    readonly property string favoriteCoins: Plasmoid.configuration.favoriteCoins || ""
    readonly property string vsCurrency: Plasmoid.configuration.vsCurrency || "usd"
    readonly property int updateInterval: Plasmoid.configuration.updateInterval || 5
    readonly property int desktopCardType: Plasmoid.configuration.desktopCardType || 0
    readonly property string alertsJson: Plasmoid.configuration.alertsJson || "{\"alerts\":[]}"

    property bool showTicker: Plasmoid.configuration.showTicker
    property bool showSummary: Plasmoid.configuration.showSummary
    property bool showMiniCards: Plasmoid.configuration.showMiniCards
    property bool showAnalysisCards: Plasmoid.configuration.showAnalysisCards
    property bool showTables: Plasmoid.configuration.showTables
    property bool showHalving: Plasmoid.configuration.showHalving

    property var lastAlertState: ({
        "marketCap": 0,
        "fearGreedClass": "",
        "fngValue": 50,
        "btcRainbowZone": ""
    })

    Services.NotificationManager {
        id: notificationManager
    }

    Services.NetworkManager {
        id: networkManager
        favoriteCoins: root.favoriteCoins
        vsCurrency: root.vsCurrency
        updateInterval: root.updateInterval

        onDataUpdated: {
            root.updateSummaryStrings();
            root.handleDataUpdated();
        }
    }

    onDesktopCardTypeChanged: root.cleanupAlerts()
    onFavoriteCoinsChanged: root.cleanupAlerts()

    Component.onCompleted: {
        root.cleanupAlerts();
        root.updateSummaryStrings();
    }

    Component.onDestruction: {
        if (networkManager) {
            networkManager.stopStepTimers();
        }
    }

    function updateSummaryStrings() {
        var summary = MarketSummary.evaluateMarketSummary(
            networkManager.globalData,
            networkManager.fngData,
            networkManager.marketCoinsData,
            root.vsCurrency,
            Constants
        );
        if (summary) {
            root.currentMarketState = summary;
            root.summaryStatus = summary.status ? i18n(summary.status) : i18n("Accumulation ⚖️");
            root.shortSummaryDesc = summary.shortDesc ? i18n(summary.shortDesc) : i18n("Loading market analytics report...");
        }
    }

    function cleanupAlerts() {
        var isDesktop = (Plasmoid.formFactor === PlasmaCore.Types.Planar);
        var cleanedJson = AlertEngine.cleanupOrphanedAlerts(root.alertsJson, isDesktop, root.desktopCardType, root.favoriteCoins);
        if (cleanedJson !== root.alertsJson) {
            Plasmoid.configuration.alertsJson = cleanedJson;
        }
    }

    function handleDataUpdated() {
        var result = AlertEngine.evaluateAlerts(
            root.alertsJson,
            networkManager.coinsData,
            networkManager.globalData,
            networkManager.fngData,
            root.vsCurrency,
            networkManager.previousPrices,
            root.lastAlertState
        );

        if (result) {
            root.lastAlertState = result.lastAlertState;

            if (result.triggered && result.triggered.length > 0) {
                for (var i = 0; i < result.triggered.length; i++) {
                    var item = result.triggered[i];
                    notificationManager.sendNotification(item.title, item.text);
                }
            }

            if (result.modified) {
                Plasmoid.configuration.alertsJson = JSON.stringify({ "alerts": result.alerts });
            }
        }
    }

    // Безпечний виклик діалогу налаштувань для Plasma 6
    function openConfiguration() {
        try {
            // Варіант 1: Офіційний Plasma 6 internalAction
            if (typeof Plasmoid.internalAction === "function") {
                var intAct = Plasmoid.internalAction("configure");
                if (intAct && typeof intAct.trigger === "function") {
                    intAct.trigger();
                    return;
                }
            }

            // Варіант 2: Пошук екшену "configure" серед контекстних дій
            if (Plasmoid.contextualActions && Plasmoid.contextualActions.length > 0) {
                for (var i = 0; i < Plasmoid.contextualActions.length; i++) {
                    var act = Plasmoid.contextualActions[i];
                    if (act && (act.objectName === "configure" || (act.text && act.text.toLowerCase().indexOf("config") !== -1))) {
                        if (typeof act.trigger === "function") {
                            act.trigger();
                            return;
                        }
                    }
                }
            }
        } catch (e) {
            console.warn("Crypto-hub: Error triggering openConfiguration:", e);
        }
    }

    compactRepresentation: CompactRepresentation {
        summaryStatus: root.summaryStatus
        onToggleExpand: root.expanded = !root.expanded
    }

    fullRepresentation: Plasmoid.formFactor === PlasmaCore.Types.Planar
    ? desktopRepresentationComponent
    : panelRepresentationComponent

    Component {
        id: desktopRepresentationComponent
        DesktopFullRepresentation {
            favoriteCoins: root.favoriteCoins
            coinsData: networkManager.coinsData
            coinsDataChangeCounter: networkManager.coinsDataChangeCounter
            vsCurrency: root.vsCurrency
            fngData: networkManager.fngData
            globalData: networkManager.globalData
            desktopCardType: root.desktopCardType
            hasError: networkManager.hasError
            alertsJson: root.alertsJson

            trendingData: networkManager.trendingData
            gainersData: networkManager.gainersData
            losersData: networkManager.losersData
            marketCoinsData: networkManager.marketCoinsData

            onConfigureRequested: root.openConfiguration()
        }
    }

    Component {
        id: panelRepresentationComponent
        PanelFullRepresentation {
            globalData: networkManager.globalData
            fngData: networkManager.fngData
            vsCurrency: root.vsCurrency
            favoriteCoins: root.favoriteCoins
            coinsData: networkManager.coinsData
            alertsJson: root.alertsJson

            trendingData: networkManager.trendingData
            gainersData: networkManager.gainersData
            losersData: networkManager.losersData
            marketCoinsData: networkManager.marketCoinsData

            isFetching: networkManager.isFetching
            hasError: networkManager.hasError
            errorCountdown: networkManager.errorCountdown
            lastUpdatedTime: networkManager.lastUpdatedTime

            showTicker: root.showTicker
            showSummary: root.showSummary
            showMiniCards: root.showMiniCards
            showAnalysisCards: root.showAnalysisCards
            showTables: root.showTables
            showHalving: root.showHalving

            onRefreshRequested: networkManager.refreshAllData(true)
            onConfigureRequested: root.openConfiguration()
        }
    }
}
