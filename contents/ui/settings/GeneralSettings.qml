pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import "../../code/database.js" as Database
import "../../code/coinSettingsHelper.js" as CoinSettingsHelper

// qmllint disable unqualified
// qmllint disable missing-property

Kirigami.ScrollablePage {
    id: generalSettings
    title: i18n("General")
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

    property string cfg_alertsJson: "{\"alerts\":[]}"
    property string cfg_vsCurrency: "usd"
    property int cfg_updateInterval: 5
    property int cfg_desktopCardType: 0
    property string cfg_favoriteCoins: ""

    property bool cfg_showTicker: true
    property bool cfg_showSummary: true
    property bool cfg_showMiniCards: true
    property bool cfg_showAnalysisCards: true
    property bool cfg_showTables: true
    property bool cfg_showHalving: true

    readonly property bool isDesktopMode: typeof Plasmoid !== "undefined" ? (Plasmoid.formFactor === 0) : false

    property int activeSearchIndex: -1
    property bool isProgrammaticChange: false

    Timer {
        id: desktopSearchTimer
        interval: 150
        running: false
        repeat: false
        onTriggered: CoinSettingsHelper.performSearch(desktopCoinInput.text, desktopSearchResultsModel, Database)
    }

    ListModel {
        id: desktopSearchResultsModel
    }

    function selectSearchResult(index) {
        if (index >= 0 && index < desktopSearchResultsModel.count) {
            var selected = desktopSearchResultsModel.get(index);
            generalSettings.isProgrammaticChange = true;
            desktopCoinInput.text = selected.coinId;
            generalSettings.cfg_favoriteCoins = selected.coinId;

            desktopSearchResultsModel.clear();
            generalSettings.activeSearchIndex = -1;
            generalSettings.isProgrammaticChange = false;
        }
    }

    function resolveAndSaveCoin(inputText) {
        var clean = inputText.trim().toLowerCase();
        if (clean === "") {
            generalSettings.cfg_favoriteCoins = "";
            return;
        }

        var resolvedId = Database.resolveTicker(clean);
        generalSettings.cfg_favoriteCoins = resolvedId;
        desktopCoinInput.text = resolvedId;
    }

    Kirigami.FormLayout {
        id: formLayout
        Layout.fillWidth: true

        Controls.ComboBox {
            id: currencyCombo
            Kirigami.FormData.label: i18n("Target Currency:")
            Layout.fillWidth: true
            textRole: "text"
            valueRole: "value"

            model: [
                { value: "usd", text: i18n("USD ($) — US Dollar") },
                { value: "eur", text: i18n("EUR (€) — Euro") },
                { value: "uah", text: i18n("UAH (₴) — Ukrainian Hryvnia") },
                { value: "gbp", text: i18n("GBP (£) — British Pound") },
                { value: "jpy", text: i18n("JPY (¥) — Japanese Yen") },
                { value: "cad", text: i18n("CAD ($) — Canadian Dollar") },
                { value: "aud", text: i18n("AUD ($) — Australian Dollar") },
                { value: "chf", text: i18n("CHF — Swiss Franc") },
                { value: "pln", text: i18n("PLN (zł) — Polish Zloty") },
                { value: "try", text: i18n("TRY (₺) — Turkish Lira") },
                { value: "cny", text: i18n("CNY (¥) — Chinese Yuan") },
                { value: "czk", text: i18n("CZK (Kč) — Czech Koruna") },
                { value: "dkk", text: i18n("DKK (kr) — Danish Krone") },
                { value: "sek", text: i18n("SEK (kr) — Swedish Krona") },
                { value: "nok", text: i18n("NOK (kr) — Norwegian Krone") },
                { value: "huf", text: i18n("HUF (Ft) — Hungarian Forint") },
                { value: "ils", text: i18n("ILS (₪) — Israeli Shekel") },
                { value: "inr", text: i18n("INR (₹) — Indian Rupee") }
            ]

            Component.onCompleted: currencyCombo.syncIndex()

            function syncIndex() {
                var m = currencyCombo.model;
                if (!m) return;
                for (var i = 0; i < m.length; i++) {
                    if (m[i].value === generalSettings.cfg_vsCurrency) {
                        currencyCombo.currentIndex = i;
                        return;
                    }
                }
                currencyCombo.currentIndex = 0;
            }

            Connections {
                target: generalSettings
                function onCfg_vsCurrencyChanged() {
                    currencyCombo.syncIndex();
                }
            }

            onActivated: (index) => {
                var m = currencyCombo.model;
                if (index >= 0 && index < m.length) {
                    var val = m[index].value;
                    if (generalSettings.cfg_vsCurrency !== val) {
                        generalSettings.cfg_vsCurrency = val;
                    }
                }
            }
        }

        Controls.ComboBox {
            id: intervalCombo
            Kirigami.FormData.label: i18n("Auto-refresh Interval:")
            Layout.fillWidth: true
            textRole: "text"
            valueRole: "value"

            model: [
                { value: 1, text: i18n("1 minute") },
                { value: 5, text: i18n("5 minutes") },
                { value: 10, text: i18n("10 minutes") },
                { value: 15, text: i18n("15 minutes") },
                { value: 30, text: i18n("30 minutes") },
                { value: 45, text: i18n("45 minutes") },
                { value: 60, text: i18n("1 hour") }
            ]

            Component.onCompleted: intervalCombo.syncIndex()

            function syncIndex() {
                var m = intervalCombo.model;
                if (!m) return;
                for (var i = 0; i < m.length; i++) {
                    if (m[i].value === generalSettings.cfg_updateInterval) {
                        intervalCombo.currentIndex = i;
                        return;
                    }
                }
                intervalCombo.currentIndex = 1;
            }

            Connections {
                target: generalSettings
                function onCfg_updateIntervalChanged() {
                    intervalCombo.syncIndex();
                }
            }

            onActivated: (index) => {
                var m = intervalCombo.model;
                if (index >= 0 && index < m.length) {
                    var val = m[index].value;
                    if (generalSettings.cfg_updateInterval !== val) {
                        generalSettings.cfg_updateInterval = val;
                    }
                }
            }
        }

        Controls.ComboBox {
            id: cardTypeCombo
            Kirigami.FormData.label: i18n("Desktop Widget:")
            visible: generalSettings.isDesktopMode
            model: [
                i18n("Selected Coin Card"),
                i18n("Fear & Greed Index"),
                i18n("Global Market Cap"),
                i18n("Dominance Distribution"),
                i18n("Active Cryptocurrencies"),
                i18n("Marquee Price Ticker"),
                i18n("Top 5 Gainers"),
                i18n("Top 5 Losers"),
                i18n("Trending Coins"),
                i18n("24h Trading Volume"),
                i18n("ETH/BTC Ratio"),
                i18n("BTC Halving Countdown"),
                i18n("BTC Price Valuation"),
                i18n("Stablecoin Dominance"),
                i18n("Market Analytics Summary")
            ]
            Layout.fillWidth: true
            currentIndex: generalSettings.cfg_desktopCardType

            onActivated: (index) => {
                if (generalSettings.cfg_desktopCardType !== index) {
                    generalSettings.cfg_desktopCardType = index;
                }
            }
        }

        Controls.TextField {
            id: desktopCoinInput
            Kirigami.FormData.label: i18n("Widget Coin (ID or Ticker):")
            visible: generalSettings.isDesktopMode && generalSettings.cfg_desktopCardType == 0
            Layout.fillWidth: true
            placeholderText: i18n("e.g. btc, eth, sol, doge...")

            Component.onCompleted: {
                desktopCoinInput.text = generalSettings.cfg_favoriteCoins;
            }

            Connections {
                target: generalSettings
                function onCfg_favoriteCoinsChanged() {
                    if (!desktopCoinInput.activeFocus && desktopCoinInput.text !== generalSettings.cfg_favoriteCoins) {
                        desktopCoinInput.text = generalSettings.cfg_favoriteCoins;
                    }
                }
            }

            onTextChanged: {
                if (desktopCoinInput.activeFocus && !generalSettings.isProgrammaticChange) {
                    var clean = desktopCoinInput.text.trim().toLowerCase();
                    if (generalSettings.cfg_favoriteCoins !== clean) {
                        generalSettings.cfg_favoriteCoins = clean;
                    }
                    generalSettings.activeSearchIndex = -1;
                    desktopSearchTimer.restart();
                }
            }

            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Down) {
                    if (desktopSearchResultsModel.count > 0) {
                        generalSettings.activeSearchIndex = Math.min(desktopSearchResultsModel.count - 1, generalSettings.activeSearchIndex + 1);
                        event.accepted = true;
                    }
                } else if (event.key === Qt.Key_Up) {
                    if (desktopSearchResultsModel.count > 0) {
                        generalSettings.activeSearchIndex = Math.max(-1, generalSettings.activeSearchIndex - 1);
                        event.accepted = true;
                    }
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    event.accepted = true;
                    if (generalSettings.activeSearchIndex >= 0 && generalSettings.activeSearchIndex < desktopSearchResultsModel.count) {
                        generalSettings.selectSearchResult(generalSettings.activeSearchIndex);
                    } else {
                        generalSettings.resolveAndSaveCoin(desktopCoinInput.text);
                        desktopSearchResultsModel.clear();
                        generalSettings.activeSearchIndex = -1;
                    }
                }
            }
        }

        ColumnLayout {
            id: desktopSearchResultsContainer
            Layout.fillWidth: true
            spacing: 2
            visible: generalSettings.isDesktopMode && generalSettings.cfg_desktopCardType == 0 && desktopSearchResultsModel.count > 0

            Repeater {
                model: desktopSearchResultsModel
                delegate: Controls.ItemDelegate {
                    id: searchDel
                    Layout.fillWidth: true
                    implicitHeight: 38

                    required property string coinId
                    required property string name
                    required property string symbol
                    required property int index

                    background: Rectangle {
                        color: searchDel.index === generalSettings.activeSearchIndex
                        ? Kirigami.Theme.focusColor
                        : (searchDel.hovered ? Kirigami.Theme.hoverColor : Kirigami.Theme.alternateBackgroundColor)
                        border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.1)
                        radius: 4
                    }

                    contentItem: RowLayout {
                        spacing: Kirigami.Units.mediumSpacing
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12

                        Controls.Label {
                            text: searchDel.name
                            Layout.fillWidth: true
                            font.bold: true
                            elide: Text.ElideRight
                            color: searchDel.index === generalSettings.activeSearchIndex ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                        }

                        Controls.Label {
                            text: searchDel.symbol.toUpperCase()
                            font.bold: true
                            font.pointSize: 9
                            opacity: 0.8
                            color: searchDel.index === generalSettings.activeSearchIndex ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                        }
                    }

                    onClicked: {
                        generalSettings.selectSearchResult(searchDel.index);
                    }
                }
            }
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Feed Settings")
            Layout.fillWidth: true
            visible: !generalSettings.isDesktopMode
        }

        Controls.CheckBox {
            id: showTickerCheck
            text: i18n("Marquee Price Ticker")
            visible: !generalSettings.isDesktopMode
            checked: generalSettings.cfg_showTicker
            onCheckedChanged: {
                if (generalSettings.cfg_showTicker !== showTickerCheck.checked) {
                    generalSettings.cfg_showTicker = showTickerCheck.checked;
                }
            }
        }

        Controls.CheckBox {
            id: showSummaryCheck
            text: i18n("Market Analytics Summary")
            visible: !generalSettings.isDesktopMode
            checked: generalSettings.cfg_showSummary
            onCheckedChanged: {
                if (generalSettings.cfg_showSummary !== showSummaryCheck.checked) {
                    generalSettings.cfg_showSummary = showSummaryCheck.checked;
                }
            }
        }

        Controls.CheckBox {
            id: showMiniCardsCheck
            text: i18n("Key Metrics (Market Cap, Volume, Fear & Greed, Dominance)")
            visible: !generalSettings.isDesktopMode
            checked: generalSettings.cfg_showMiniCards
            onCheckedChanged: {
                if (generalSettings.cfg_showMiniCards !== showMiniCardsCheck.checked) {
                    generalSettings.cfg_showMiniCards = showMiniCardsCheck.checked;
                }
            }
        }

        Controls.CheckBox {
            id: showAnalysisCardsCheck
            text: i18n("Analytical Models (ETH/BTC, BTC Price Valuation)")
            visible: !generalSettings.isDesktopMode
            checked: generalSettings.cfg_showAnalysisCards
            onCheckedChanged: {
                if (generalSettings.cfg_showAnalysisCards !== showAnalysisCardsCheck.checked) {
                    generalSettings.cfg_showAnalysisCards = showAnalysisCardsCheck.checked;
                }
            }
        }

        Controls.CheckBox {
            id: showTablesCheck
            text: i18n("Leaderboard Tables (Gainers, Losers & Trending)")
            visible: !generalSettings.isDesktopMode
            checked: generalSettings.cfg_showTables
            onCheckedChanged: {
                if (generalSettings.cfg_showTables !== showTablesCheck.checked) {
                    generalSettings.cfg_showTables = showTablesCheck.checked;
                }
            }
        }

        Controls.CheckBox {
            id: showHalvingCheck
            text: i18n("BTC Halving Countdown")
            visible: !generalSettings.isDesktopMode
            checked: generalSettings.cfg_showHalving
            onCheckedChanged: {
                if (generalSettings.cfg_showHalving !== showHalvingCheck.checked) {
                    generalSettings.cfg_showHalving = showHalvingCheck.checked;
                }
            }
        }
    }
}
