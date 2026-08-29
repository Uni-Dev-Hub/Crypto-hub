pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import "../../services" as Services
import "../../code/database.js" as Database
import "../../code/coingecko.js" as CoinGecko
import "../../code/fng.js" as FnG
import "../../code/portfolioEngine.js" as PortfolioEngine
import "../../code/alertSettingsHelper.js" as AlertSettingsHelper

// qmllint disable unqualified
// qmllint disable missing-property

Kirigami.ScrollablePage {
    id: alertsPage
    title: i18n("Alerts")
    topPadding: 0

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

    property var favoriteCoinsList: []
    property string editingAlertId: ""

    property var liveMarketsData: ({})
    property var liveGlobalData: null
    property var liveFngData: null

    property var targetList: []
    property var triggerList: []
    property var frequencyList: []

    readonly property string vsCurrency: alertsPage.cfg_vsCurrency || "usd"
    readonly property var portfolioData: PortfolioEngine.parsePortfolio(alertsPage.cfg_portfolioJson)
    readonly property var portfolioStats: PortfolioEngine.calculatePortfolio(portfolioData, liveMarketsData, vsCurrency)

    ListModel { id: alertsModel }
    ListModel { id: coinModel }

    ListModel {
        id: dominanceModel
        ListElement { value: "btc_dom"; text: "Bitcoin (BTC.D)" }
        ListElement { value: "eth_dom"; text: "Ethereum (ETH.D)" }
    }

    Services.NotificationManager {
        id: testNotificationManager
    }

    Timer {
        id: livePreviewDebounceTimer
        interval: 600
        running: false
        repeat: false
        onTriggered: alertsPage.doFetchLivePreviewData()
    }

    Component.onCompleted: {
        updateFavoritesList();
        syncModelFromConfig();
        buildTargetComboModel();
        updateFrequencyModel();
        fetchLivePreviewData();
    }

    onCfg_alertsJsonChanged: {
        updateFavoritesList();
        syncModelFromConfig();
        buildTargetComboModel();
        updateFrequencyModel();
    }

    onCfg_favoriteCoinsChanged: {
        updateFavoritesList();
        buildTargetComboModel();
        fetchLivePreviewData();
    }

    onCfg_portfolioJsonChanged: {
        buildTargetComboModel();
        fetchLivePreviewData();
    }

    function updateFrequencyModel() {
        alertsPage.frequencyList = [
            { "value": "once", "text": i18n("Only once") },
            { "value": "daily", "text": i18n("Once a day") },
            { "value": "always", "text": i18n("Every time reached") }
        ];
        frequencyCombo.model = alertsPage.frequencyList;
    }

    function fetchLivePreviewData() {
        livePreviewDebounceTimer.restart();
    }

    function doFetchLivePreviewData() {
        if (targetCombo.isSelectedCoin) {
            if (coinSelectCombo.currentIndex >= 0 && coinSelectCombo.currentIndex < alertsPage.favoriteCoinsList.length) {
                var coinObj = alertsPage.favoriteCoinsList[coinSelectCombo.currentIndex];
                CoinGecko.fetchCoinData(coinObj.id, alertsPage.vsCurrency, function(res) {
                    if (res) alertsPage.liveMarketsData = res;
                });
            }
        } else if (targetCombo.isSelectedPortfolio) {
            var portCoins = [];
            if (alertsPage.portfolioData && Array.isArray(alertsPage.portfolioData.items)) {
                for (var i = 0; i < alertsPage.portfolioData.items.length; i++) {
                    if (alertsPage.portfolioData.items[i].id) portCoins.push(alertsPage.portfolioData.items[i].id);
                }
            }
            if (portCoins.length > 0) {
                CoinGecko.fetchCoinData(portCoins.join(","), alertsPage.vsCurrency, function(res) {
                    if (res) alertsPage.liveMarketsData = res;
                });
            }
        } else {
            var targetVal = targetCombo.selectedTargetValue;
            if (targetVal === "fng") {
                FnG.fetchFearAndGreed(function(res) {
                    if (res) alertsPage.liveFngData = res;
                });
            } else if (targetVal === "dominance" || targetVal === "market_cap" || targetVal === "global_volume" || targetVal === "active_coins" || targetVal === "stable_dom") {
                CoinGecko.fetchGlobalData(function(res) {
                    if (res) alertsPage.liveGlobalData = res;
                });
            } else if (targetVal === "eth_btc_ratio" || targetVal === "btc_rainbow") {
                CoinGecko.fetchCoinData("bitcoin,ethereum", alertsPage.vsCurrency, function(res) {
                    if (res) alertsPage.liveMarketsData = res;
                });
            }
        }
    }

    function isAlertValidForCurrentMode(alert) {
        var isDesktop = typeof Plasmoid !== "undefined" ? (Plasmoid.formFactor === 0) : false;
        var desktopType = alertsPage.cfg_desktopCardType;
        var favs = alertsPage.cfg_favoriteCoins || "";

        return AlertSettingsHelper.isAlertValidForCurrentMode(alert, isDesktop, desktopType, favs);
    }

    function buildTargetComboModel() {
        var prevTarget = targetCombo.selectedTargetValue;
        var list = [];
        var isDesktop = typeof Plasmoid !== "undefined" ? (Plasmoid.formFactor === 0) : false;
        var desktopType = alertsPage.cfg_desktopCardType;
        var showMini = alertsPage.cfg_showMiniCards;
        var showAnalysis = alertsPage.cfg_showAnalysisCards;
        var showHalving = alertsPage.cfg_showHalving;

        if (isDesktop) {
            if (desktopType === 0) list.push({ "value": "coin", "text": i18n("Selected Coin") });
            else if (desktopType === 1) list.push({ "value": "fng", "text": i18n("Fear & Greed Index") });
            else if (desktopType === 2) list.push({ "value": "market_cap", "text": i18n("Global Market Cap") });
            else if (desktopType === 3) list.push({ "value": "dominance", "text": i18n("Dominance (BTC / ETH)") });
            else if (desktopType === 4) list.push({ "value": "active_coins", "text": i18n("Active Cryptocurrencies") });
            else if (desktopType === 9) list.push({ "value": "global_volume", "text": i18n("24h Total Volume") });
            else if (desktopType === 10) list.push({ "value": "eth_btc_ratio", "text": i18n("ETH/BTC Ratio") });
            else if (desktopType === 11) list.push({ "value": "halving", "text": i18n("BTC Halving Countdown") });
            else if (desktopType === 12) list.push({ "value": "btc_rainbow", "text": i18n("BTC Rainbow Zone") });
            else if (desktopType === 13) list.push({ "value": "stable_dom", "text": i18n("Stablecoin Dominance") });
            else if (desktopType === 15) list.push({ "value": "portfolio", "text": i18n("Crypto Portfolio") });
        } else {
            list.push({ "value": "coin", "text": i18n("Selected Coin") });
            if (alertsPage.portfolioData && alertsPage.portfolioData.enabled) {
                list.push({ "value": "portfolio", "text": i18n("Crypto Portfolio") });
            }
            if (showMini) {
                list.push({ "value": "fng", "text": i18n("Fear & Greed Index") });
                list.push({ "value": "market_cap", "text": i18n("Global Market Cap") });
                list.push({ "value": "global_volume", "text": i18n("24h Total Volume") });
                list.push({ "value": "dominance", "text": i18n("Dominance (BTC / ETH)") });
                list.push({ "value": "stable_dom", "text": i18n("Stablecoin Dominance") });
                list.push({ "value": "active_coins", "text": i18n("Active Cryptocurrencies") });
            }
            if (showAnalysis) {
                list.push({ "value": "eth_btc_ratio", "text": i18n("ETH/BTC Ratio") });
                list.push({ "value": "btc_rainbow", "text": i18n("BTC Rainbow Zone") });
            }
            if (showHalving) {
                list.push({ "value": "halving", "text": i18n("BTC Halving Countdown") });
            }
        }

        alertsPage.targetList = list;
        targetCombo.model = alertsPage.targetList;

        var foundIdx = 0;
        for (var i = 0; i < list.length; i++) {
            if (list[i].value === prevTarget) {
                foundIdx = i;
                break;
            }
        }
        targetCombo.currentIndex = foundIdx;
        updateTriggerModel();
    }

    function updateTriggerModel() {
        var prevTrigger = (triggerCombo.currentIndex >= 0 && alertsPage.triggerList && triggerCombo.currentIndex < alertsPage.triggerList.length) ? alertsPage.triggerList[triggerCombo.currentIndex].value : "";
        var list = [];
        var targetId = targetCombo.selectedTargetValue;

        if (targetId === "coin") {
            list.push({ "value": "price_reaches", "text": i18n("Price reaches") });
            list.push({ "value": "price_above", "text": i18n("Price above") });
            list.push({ "value": "price_below", "text": i18n("Price below") });
            list.push({ "value": "change_24h_above", "text": i18n("24h Change above (%)") });
            list.push({ "value": "change_24h_below", "text": i18n("24h Change below (%)") });
            list.push({ "value": "ath_reached", "text": i18n("ATH Reached") });
            list.push({ "value": "atl_reached", "text": i18n("ATL Reached") });
            list.push({ "value": "high_24h_breakout", "text": i18n("24h High Breakout") });
            list.push({ "value": "low_24h_breakout", "text": i18n("24h Low Breakout") });
            list.push({ "value": "ath_drop", "text": i18n("Drop from ATH (%) >") });
            list.push({ "value": "atl_rise", "text": i18n("Rise from ATL (%) >") });
        } else if (targetId === "portfolio") {
            list.push({ "value": "portfolio_val_above", "text": i18n("Total Value above") });
            list.push({ "value": "portfolio_val_below", "text": i18n("Total Value below") });
            list.push({ "value": "portfolio_change_above", "text": i18n("24h Change above (%)") });
            list.push({ "value": "portfolio_change_below", "text": i18n("24h Change below (%)") });
            list.push({ "value": "portfolio_pnl_above", "text": i18n("All-Time ROI above (%)") });
            list.push({ "value": "portfolio_pnl_below", "text": i18n("All-Time ROI below (%)") });
        } else if (targetId === "fng") {
            list.push({ "value": "fng_above", "text": i18n("Index above") });
            list.push({ "value": "fng_below", "text": i18n("Index below") });
            list.push({ "value": "fng_status_change", "text": i18n("Zone status changes") });
        } else if (targetId === "market_cap" || targetId === "global_volume") {
            list.push({ "value": "value_above", "text": i18n("Value above") });
            list.push({ "value": "value_below", "text": i18n("Value below") });
        } else if (targetId === "dominance" || targetId === "btc_dom" || targetId === "eth_dom" || targetId === "stable_dom") {
            list.push({ "value": "dom_above", "text": i18n("Dominance above (%)") });
            list.push({ "value": "dom_below", "text": i18n("Dominance below (%)") });
        } else if (targetId === "active_coins") {
            list.push({ "value": "coins_above", "text": i18n("Count above") });
            list.push({ "value": "coins_below", "text": i18n("Count below") });
        } else if (targetId === "eth_btc_ratio") {
            list.push({ "value": "ratio_above", "text": i18n("Ratio above") });
            list.push({ "value": "ratio_below", "text": i18n("Ratio below") });
        } else if (targetId === "btc_rainbow") {
            list.push({ "value": "zone_change", "text": i18n("Valuation Zone changes") });
        } else if (targetId === "halving") {
            list.push({ "value": "days_left_below", "text": i18n("Days remaining less than") });
        }

        alertsPage.triggerList = list;
        triggerCombo.model = alertsPage.triggerList;

        var foundIdx = 0;
        for (var i = 0; i < list.length; i++) {
            if (list[i].value === prevTrigger) {
                foundIdx = i;
                break;
            }
        }
        triggerCombo.currentIndex = foundIdx;
    }

    function syncModelFromConfig() {
        alertsModel.clear();
        var data;
        try {
            data = JSON.parse(cfg_alertsJson);
        } catch(e) {
            data = {"alerts": []};
        }

        var list = data.alerts || [];
        var modified = false;

        for (var i = 0; i < list.length; i++) {
            if (isAlertValidForCurrentMode(list[i])) {
                alertsModel.append(list[i]);
            } else {
                modified = true;
            }
        }

        if (modified) {
            saveAlertsFromModel();
        }
    }

    function saveAlertsFromModel() {
        var list = [];
        for (var i = 0; i < alertsModel.count; i++) {
            list.push(alertsModel.get(i));
        }

        var data = { "alerts": list };
        alertsPage.cfg_alertsJson = JSON.stringify(data);
    }

    function updateFavoritesList() {
        coinModel.clear();
        var favString = alertsPage.cfg_favoriteCoins || "";

        favoriteCoinsList = [];
        if (favString && favString.trim() !== "") {
            var ids = favString.split(",").map(function(s) { return s.trim().toLowerCase(); }).filter(function(s) { return s !== ""; });
            for (var i = 0; i < ids.length; i++) {
                var cId = ids[i];
                var sym = cId.toUpperCase();
                if (Database && typeof Database.getSymbolForCoin === "function") {
                    sym = Database.getSymbolForCoin(cId) || cId.toUpperCase();
                } else if (Database && typeof Database.getSymbol === "function") {
                    sym = Database.getSymbol(cId) || cId.toUpperCase();
                }
                favoriteCoinsList.push({ "id": cId, "symbol": sym });
                coinModel.append({ "id": cId, "symbol": sym });
            }
        }

        if (coinSelectCombo.currentIndex < 0 || coinSelectCombo.currentIndex >= coinModel.count) {
            coinSelectCombo.currentIndex = 0;
        }
    }

    ColumnLayout {
        id: mainLayout
        width: parent.width
        spacing: Kirigami.Units.smallSpacing

        Kirigami.FormLayout {
            id: mainForm
            Layout.fillWidth: true

            RowLayout {
                Kirigami.FormData.label: i18n("Target:")
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Controls.ComboBox {
                    id: targetCombo
                    Layout.fillWidth: true
                    model: alertsPage.targetList
                    textRole: "text"
                    valueRole: "value"

                    readonly property bool isSelectedCoin: {
                        if (currentIndex >= 0 && alertsPage.targetList && currentIndex < alertsPage.targetList.length) {
                            return alertsPage.targetList[currentIndex].value === "coin";
                        }
                        return false;
                    }

                    readonly property bool isSelectedPortfolio: {
                        if (currentIndex >= 0 && alertsPage.targetList && currentIndex < alertsPage.targetList.length) {
                            return alertsPage.targetList[currentIndex].value === "portfolio";
                        }
                        return false;
                    }

                    readonly property string selectedTargetValue: {
                        if (currentIndex >= 0 && alertsPage.targetList && currentIndex < alertsPage.targetList.length) {
                            return alertsPage.targetList[currentIndex].value;
                        }
                        return "fng";
                    }

                    onActivated: {
                        alertsPage.updateTriggerModel();
                        alertsPage.fetchLivePreviewData();
                    }
                }

                Controls.ComboBox {
                    id: coinSelectCombo
                    Layout.fillWidth: true
                    visible: targetCombo.isSelectedCoin
                    model: coinModel
                    textRole: "symbol"

                    onCurrentIndexChanged: alertsPage.fetchLivePreviewData()
                }

                Controls.ComboBox {
                    id: dominanceSelectCombo
                    Layout.fillWidth: true
                    visible: targetCombo.selectedTargetValue === "dominance"
                    model: dominanceModel
                    textRole: "text"

                    onCurrentIndexChanged: alertsPage.fetchLivePreviewData()
                }

                Rectangle {
                    Layout.alignment: Qt.AlignVCenter
                    color: Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.12)
                    radius: 4
                    border.color: Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.25)
                    border.width: 1
                    implicitWidth: liveValText.implicitWidth + 12
                    implicitHeight: 26
                    visible: targetCombo.selectedTargetValue !== "none"

                    Controls.Label {
                        id: liveValText
                        anchors.centerIn: parent
                        font.bold: true
                        font.pointSize: 8.5
                        color: Kirigami.Theme.highlightColor
                        text: AlertSettingsHelper.formatLiveValueText(
                            targetCombo.selectedTargetValue,
                            targetCombo.isSelectedCoin,
                            targetCombo.isSelectedPortfolio,
                            coinSelectCombo.currentIndex,
                            alertsPage.favoriteCoinsList,
                            alertsPage.liveMarketsData,
                            alertsPage.liveGlobalData,
                            alertsPage.liveFngData,
                            dominanceSelectCombo.currentIndex === 0 ? "btc_dom" : "eth_dom",
                            alertsPage.vsCurrency,
                            alertsPage.portfolioStats
                        )
                    }
                }
            }

            RowLayout {
                Kirigami.FormData.label: i18n("Condition:")
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing
                visible: targetCombo.selectedTargetValue !== "none"

                Controls.ComboBox {
                    id: triggerCombo
                    Layout.preferredWidth: parent.width * 0.55
                    model: alertsPage.triggerList
                    textRole: "text"
                    valueRole: "value"
                }

                Controls.TextField {
                    id: valueInput
                    Layout.fillWidth: true
                    placeholderText: targetCombo.selectedTargetValue === "none" ? i18n("Disabled") : (isValueInputHidden ? i18n("Auto") : i18n("Value"))
                    enabled: !isValueInputHidden && targetCombo.selectedTargetValue !== "none"
                    inputMethodHints: Qt.ImhFormattedNumbersOnly

                    readonly property bool isValueInputHidden: {
                        if (triggerCombo.currentIndex >= 0 && alertsPage.triggerList && triggerCombo.currentIndex < alertsPage.triggerList.length) {
                            var val = alertsPage.triggerList[triggerCombo.currentIndex].value;
                            return val === "ath_reached" ||
                            val === "atl_reached" ||
                            val === "high_24h_breakout" ||
                            val === "low_24h_breakout" ||
                            val === "fng_status_change" ||
                            val === "zone_change";
                        }
                        return false;
                    }
                }
            }

            RowLayout {
                Kirigami.FormData.label: i18n("Options:")
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing
                visible: targetCombo.selectedTargetValue !== "none"

                Controls.ComboBox {
                    id: frequencyCombo
                    Layout.preferredWidth: parent.width * 0.4
                    model: alertsPage.frequencyList
                    textRole: "text"
                    valueRole: "value"
                }

                Controls.TextField {
                    id: noteInput
                    Layout.fillWidth: true
                    placeholderText: i18n("Note (optional)")
                    maximumLength: 30
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing
                visible: targetCombo.selectedTargetValue !== "none"

                Controls.Button {
                    text: alertsPage.editingAlertId === "" ? i18n("Create alert") : i18n("Save changes")
                    icon.name: alertsPage.editingAlertId === "" ? "list-add-symbolic" : "document-save-symbolic"
                    Layout.fillWidth: true
                    onClicked: {
                        var isCoin = targetCombo.isSelectedCoin;
                        var isPortfolio = targetCombo.isSelectedPortfolio;
                        if (triggerCombo.currentIndex < 0 || !alertsPage.triggerList || triggerCombo.currentIndex >= alertsPage.triggerList.length) return;
                        var selectedType = alertsPage.triggerList[triggerCombo.currentIndex].value;

                        var val = parseFloat(valueInput.text.replace(",", "."));
                        if (!valueInput.isValueInputHidden && (isNaN(val) || val <= 0)) {
                            return;
                        }
                        if (valueInput.isValueInputHidden) {
                            val = 0.0;
                        }

                        var freqIdx = Math.max(0, frequencyCombo.currentIndex);
                        var selectedFrequency = (alertsPage.frequencyList && freqIdx < alertsPage.frequencyList.length) ? alertsPage.frequencyList[freqIdx].value : "once";

                        var targetType = "macro";
                        var targetId = "";
                        var symbol = "";

                        if (isCoin) {
                            targetType = "coin";
                            if (coinSelectCombo.currentIndex < 0 || coinSelectCombo.currentIndex >= coinModel.count) return;
                            var coinObj = coinModel.get(coinSelectCombo.currentIndex);
                            targetId = coinObj.id;
                            symbol = coinObj.symbol;
                        } else if (isPortfolio) {
                            targetType = "portfolio";
                            targetId = "portfolio";
                            symbol = i18n("Portfolio");
                        } else {
                            if (targetCombo.currentIndex < 0 || !alertsPage.targetList || targetCombo.currentIndex >= alertsPage.targetList.length) return;
                            var macroObj = alertsPage.targetList[targetCombo.currentIndex];
                            targetId = macroObj.value;

                            if (targetId === "dominance") {
                                var domIdx = Math.max(0, dominanceSelectCombo.currentIndex);
                                targetId = dominanceModel.get(domIdx).value;
                            }

                            if (targetId === "fng") symbol = "F&G";
                            else if (targetId === "market_cap") symbol = "Total Cap";
                            else if (targetId === "global_volume") symbol = "Total Vol";
                            else if (targetId === "btc_dom") symbol = "BTC.D";
                            else if (targetId === "eth_dom") symbol = "ETH.D";
                            else if (targetId === "stable_dom") symbol = "Stable.D";
                            else if (targetId === "active_coins") symbol = "Active Coins";
                            else if (targetId === "btc_rainbow") symbol = "BTC Rainbow";
                            else if (targetId === "eth_btc_ratio") symbol = "ETH/BTC";
                            else if (targetId === "halving") symbol = "Halving";
                        }

                        if (alertsPage.editingAlertId === "") {
                            var newAlert = {
                                "id": Date.now().toString(),
                                "targetType": targetType,
                                "targetId": targetId,
                                "symbol": symbol,
                                "type": selectedType,
                                "targetValue": val,
                                "frequency": selectedFrequency,
                                "note": noteInput.text.trim(),
                                "lastTriggered": 0
                            };
                            alertsModel.append(newAlert);
                        } else {
                            for (var i = 0; i < alertsModel.count; i++) {
                                if (alertsModel.get(i).id === alertsPage.editingAlertId) {
                                    alertsModel.setProperty(i, "targetType", targetType);
                                    alertsModel.setProperty(i, "targetId", targetId);
                                    alertsModel.setProperty(i, "symbol", symbol);
                                    alertsModel.setProperty(i, "type", selectedType);
                                    alertsModel.setProperty(i, "targetValue", val);
                                    alertsModel.setProperty(i, "frequency", selectedFrequency);
                                    alertsModel.setProperty(i, "note", noteInput.text.trim());
                                    alertsModel.setProperty(i, "lastTriggered", 0);
                                    break;
                                }
                            }
                            alertsPage.editingAlertId = "";
                        }

                        alertsPage.saveAlertsFromModel();
                        valueInput.clear();
                        noteInput.clear();
                    }
                }

                Controls.Button {
                    text: i18n("Test alert")
                    icon.name: "notifications-symbolic"
                    onClicked: {
                        testNotificationManager.sendTestNotification();
                    }
                }

                Controls.Button {
                    text: i18n("Cancel")
                    icon.name: "dialog-cancel"
                    visible: alertsPage.editingAlertId !== ""
                    onClicked: {
                        alertsPage.editingAlertId = "";
                        valueInput.clear();
                        noteInput.clear();
                    }
                }
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        Controls.Label {
            text: i18n("Your configured alerts:")
            font.bold: true
        }

        ListView {
            id: alertsListView
            Layout.fillWidth: true
            implicitHeight: 250
            clip: true
            model: alertsModel

            delegate: Rectangle {
                id: alertItem
                width: alertsListView.width
                height: 50
                color: Kirigami.Theme.alternateBackgroundColor
                radius: 6
                border.color: alertItem.id === alertsPage.editingAlertId
                ? Kirigami.Theme.highlightColor
                : Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
                border.width: alertItem.id === alertsPage.editingAlertId ? 2 : 1

                required property string id
                required property string targetType
                required property string targetId
                required property string symbol
                required property string type
                required property double targetValue
                required property string frequency
                required property string note
                required property int index

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        RowLayout {
                            spacing: 6
                            Controls.Label {
                                text: {
                                    if (alertItem.targetType === "portfolio") return i18n("Crypto Portfolio");
                                    if (alertItem.targetType === "macro") {
                                        if (alertItem.targetId === "fng") return i18n("Fear & Greed Index");
                                        if (alertItem.targetId === "market_cap") return i18n("Global Market Cap");
                                        if (alertItem.targetId === "global_volume") return i18n("24h Total Volume");
                                        if (alertItem.targetId === "btc_dom") return i18n("BTC Dominance");
                                        if (alertItem.targetId === "eth_dom") return i18n("ETH Dominance");
                                        if (alertItem.targetId === "stable_dom") return i18n("Stablecoin Dominance");
                                        if (alertItem.targetId === "active_coins") return i18n("Active Cryptocurrencies");
                                        if (alertItem.targetId === "btc_rainbow") return i18n("BTC Rainbow Zone");
                                        if (alertItem.targetId === "eth_btc_ratio") return i18n("ETH/BTC Ratio");
                                        if (alertItem.targetId === "halving") return i18n("BTC Halving");
                                    }
                                    return alertItem.symbol;
                                }
                                font.bold: true
                            }
                            Controls.Label {
                                text: AlertSettingsHelper.formatTriggerDescription(alertItem.type, alertItem.targetType)
                                font.pointSize: 8.5
                                opacity: 0.7
                            }
                            Controls.Label {
                                text: AlertSettingsHelper.formatTargetValue(alertItem)
                                font.bold: true
                                color: Kirigami.Theme.highlightColor
                                visible: text !== ""
                            }
                        }

                        Controls.Label {
                            text: (alertItem.note ? alertItem.note + " • " : "") +
                            (alertItem.frequency === "once" ? i18n("Only once") : (alertItem.frequency === "daily" ? i18n("Once a day") : i18n("Every time")))
                            font.pointSize: 8
                            opacity: 0.5
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        spacing: 2

                        Controls.Button {
                            icon.name: "edit-entry"
                            display: Controls.AbstractButton.IconOnly
                            flat: true
                            onClicked: {
                                alertsPage.editingAlertId = alertItem.id;

                                if (alertItem.targetType === "macro") {
                                    if (alertItem.targetId === "btc_dom" || alertItem.targetId === "eth_dom") {
                                        var domIdxInList = -1;
                                        for (var d = 0; d < alertsPage.targetList.length; d++) {
                                            if (alertsPage.targetList[d].value === "dominance") { domIdxInList = d; break; }
                                        }
                                        if (domIdxInList !== -1) targetCombo.currentIndex = domIdxInList;
                                        dominanceSelectCombo.currentIndex = (alertItem.targetId === "btc_dom") ? 0 : 1;
                                    } else {
                                        var targetIdxInList = -1;
                                        for (var t = 0; t < alertsPage.targetList.length; t++) {
                                            if (alertsPage.targetList[t].value === alertItem.targetId) { targetIdxInList = t; break; }
                                        }
                                        if (targetIdxInList !== -1) targetCombo.currentIndex = targetIdxInList;
                                    }
                                } else if (alertItem.targetType === "portfolio") {
                                    var portIdxInList = -1;
                                    for (var p = 0; p < alertsPage.targetList.length; p++) {
                                        if (alertsPage.targetList[p].value === "portfolio") { portIdxInList = p; break; }
                                    }
                                    if (portIdxInList !== -1) targetCombo.currentIndex = portIdxInList;
                                } else {
                                    var coinIdxInList = -1;
                                    for (var c = 0; c < alertsPage.targetList.length; c++) {
                                        if (alertsPage.targetList[c].value === "coin") { coinIdxInList = c; break; }
                                    }
                                    if (coinIdxInList !== -1) targetCombo.currentIndex = coinIdxInList;

                                    var coinIdx = AlertSettingsHelper.findItemIndexInModel(coinModel, "id", alertItem.targetId);
                                    if (coinIdx !== -1) {
                                        coinSelectCombo.currentIndex = coinIdx;
                                    }
                                }

                                alertsPage.updateTriggerModel();

                                var triggerIdxInList = -1;
                                for (var tr = 0; tr < alertsPage.triggerList.length; tr++) {
                                    if (alertsPage.triggerList[tr].value === alertItem.type) { triggerIdxInList = tr; break; }
                                }
                                if (triggerIdxInList !== -1) triggerCombo.currentIndex = triggerIdxInList;

                                if (alertItem.type !== "ath_reached" &&
                                    alertItem.type !== "atl_reached" &&
                                    alertItem.type !== "high_24h_breakout" &&
                                    alertItem.type !== "low_24h_breakout" &&
                                    alertItem.type !== "fng_status_change" &&
                                    alertItem.type !== "zone_change") {
                                    valueInput.text = alertItem.targetValue.toString();
                                } else {
                                    valueInput.clear();
                                }

                                var freqIdxInList = -1;
                                for (var fr = 0; fr < alertsPage.frequencyList.length; fr++) {
                                    if (alertsPage.frequencyList[fr].value === alertItem.frequency) { freqIdxInList = fr; break; }
                                }
                                if (freqIdxInList !== -1) frequencyCombo.currentIndex = freqIdxInList;

                                noteInput.text = alertItem.note;
                            }
                        }

                        Controls.Button {
                            icon.name: "delete"
                            display: Controls.AbstractButton.IconOnly
                            flat: true
                            onClicked: {
                                if (alertsPage.editingAlertId === alertItem.id) {
                                    alertsPage.editingAlertId = "";
                                    valueInput.clear();
                                    noteInput.clear();
                                }
                                alertsModel.remove(alertItem.index);
                                alertsPage.saveAlertsFromModel();
                            }
                        }
                    }
                }
            }
        }
    }
}
