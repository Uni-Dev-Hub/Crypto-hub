pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import QtQuick.Effects
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid
import "../../code/database.js" as Database
import "../../code/coinSettingsHelper.js" as CoinSettingsHelper
import "../../code/portfolioEngine.js" as PortfolioEngine

// qmllint disable unqualified
// qmllint disable missing-property

Kirigami.ScrollablePage {
    id: root
    title: i18n("Portfolio")
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

    property bool isPortfolioEnabled: false
    property bool isHideBalance: false
    property var portfolioItems: []
    property int editingIndex: -1
    property int activeSearchIndex: -1
    property string selectedCoinId: ""
    property bool isProgrammaticChange: false
    property bool isUpdating: false

    ListModel { id: searchResultsModel }

    Timer {
        id: searchTimer
        interval: 150
        running: false
        repeat: false
        onTriggered: CoinSettingsHelper.performSearch(coinSearchField.text, searchResultsModel, Database)
    }

    Component.onCompleted: {
        root.loadFromConfig();
    }

    onCfg_portfolioJsonChanged: {
        root.loadFromConfig();
    }

    function loadFromConfig() {
        if (root.isUpdating) return;
        root.isUpdating = true;
        var rawJson = root.cfg_portfolioJson;
        if ((!rawJson || rawJson === root.cfg_portfolioJsonDefault) && typeof Plasmoid !== "undefined" && Plasmoid && Plasmoid.configuration && Plasmoid.configuration.portfolioJson) {
            rawJson = Plasmoid.configuration.portfolioJson;
            root.cfg_portfolioJson = rawJson;
        }
        var pData = PortfolioEngine.parsePortfolio(rawJson);
        root.isPortfolioEnabled = pData.enabled;
        root.isHideBalance = pData.hideBalance;
        root.portfolioItems = pData.items;
        root.isUpdating = false;
    }

    function saveToConfig() {
        if (root.isUpdating) return;
        root.isUpdating = true;
        var data = {
            "enabled": root.isPortfolioEnabled,
            "hideBalance": root.isHideBalance,
            "items": root.portfolioItems
        };
        var jsonStr = JSON.stringify(data);
        root.cfg_portfolioJson = jsonStr;
        if (typeof Plasmoid !== "undefined" && Plasmoid && Plasmoid.configuration) {
            Plasmoid.configuration.portfolioJson = jsonStr;
        }
        root.isUpdating = false;
    }

    function resetForm() {
        root.isProgrammaticChange = true;
        coinSearchField.clear();
        amountField.clear();
        buyPriceField.clear();
        searchResultsModel.clear();
        root.editingIndex = -1;
        root.activeSearchIndex = -1;
        root.selectedCoinId = "";
        root.isProgrammaticChange = false;
    }

    function selectSearchResult(index) {
        if (index >= 0 && index < searchResultsModel.count) {
            var item = searchResultsModel.get(index);
            root.isProgrammaticChange = true;
            root.selectedCoinId = item.coinId;
            coinSearchField.text = item.name + " (" + item.symbol.toUpperCase() + ")";
            searchResultsModel.clear();
            root.activeSearchIndex = -1;
            root.isProgrammaticChange = false;
            amountField.forceActiveFocus();
        }
    }

    function saveItem() {
        var coinId = root.selectedCoinId;
        if (!coinId || coinId.trim() === "") {
            var rawCoin = coinSearchField.text.trim().toLowerCase();
            if (rawCoin === "") return;
            coinId = Database.resolveTicker(rawCoin);
        }
        if (!coinId) return;

        var amt = parseFloat(amountField.text.replace(",", "."));
        if (isNaN(amt) || amt <= 0) return;

        var buyPr = parseFloat(buyPriceField.text.replace(",", "."));
        if (isNaN(buyPr) || buyPr < 0) buyPr = 0;

        var list = root.portfolioItems.slice();

        if (root.editingIndex >= 0 && root.editingIndex < list.length) {
            list[root.editingIndex] = {
                "id": coinId,
                "amount": amt,
                "buyPrice": buyPr
            };
        } else {
            var existingIdx = -1;
            for (var i = 0; i < list.length; i++) {
                if (list[i].id === coinId) {
                    existingIdx = i;
                    break;
                }
            }

            if (existingIdx !== -1) {
                list[existingIdx].amount += amt;
                if (buyPr > 0) list[existingIdx].buyPrice = buyPr;
            } else {
                list.push({
                    "id": coinId,
                    "amount": amt,
                    "buyPrice": buyPr
                });
            }
        }

        root.portfolioItems = list;
        root.saveToConfig();
        root.resetForm();
    }

    function deleteItem(idx) {
        if (idx >= 0 && idx < root.portfolioItems.length) {
            var list = root.portfolioItems.slice();
            list.splice(idx, 1);
            root.portfolioItems = list;
            root.saveToConfig();
            if (root.editingIndex === idx) root.resetForm();
        }
    }

    function startEdit(idx) {
        if (idx >= 0 && idx < root.portfolioItems.length) {
            var item = root.portfolioItems[idx];
            root.editingIndex = idx;
            root.isProgrammaticChange = true;
            root.selectedCoinId = item.id;
            coinSearchField.text = root.getCoinDisplayName(item.id) + " (" + root.getCoinDisplaySymbol(item.id) + ")";
            amountField.text = item.amount.toString();
            buyPriceField.text = item.buyPrice > 0 ? item.buyPrice.toString() : "";
            root.isProgrammaticChange = false;
            amountField.forceActiveFocus();
        }
    }

    function getCoinDisplayName(coinId) {
        if (!coinId) return "";
        var clean = coinId.toLowerCase().trim();
        if (Database && typeof Database.getCoinInfo === "function") {
            var info = Database.getCoinInfo(clean);
            if (info && info.name) return info.name;
        }
        if (clean === "binancecoin") return "BNB";
        if (clean === "bittorrent") return "BitTorrent";
        if (clean === "stellar") return "Stellar";
        if (clean === "ripple") return "XRP";
        return clean.split("-").map(function(s) {
            return s.charAt(0).toUpperCase() + s.slice(1);
        }).join(" ");
    }

    function getCoinDisplaySymbol(coinId) {
        if (!coinId) return "";
        var clean = coinId.toLowerCase().trim();
        if (Database && typeof Database.getSymbolForCoin === "function") {
            var s = Database.getSymbolForCoin(clean);
            if (s) return s.toUpperCase();
        }
        if (clean === "binancecoin") return "BNB";
        if (clean === "bittorrent") return "BTT";
        if (clean === "stellar") return "XLM";
        if (clean === "ripple") return "XRP";
        if (clean === "bitcoin") return "BTC";
        if (clean === "ethereum") return "ETH";
        if (clean === "dogecoin") return "DOGE";
        return clean.toUpperCase();
    }

    function getCoinThumb(coinId) {
        if (!coinId) return "";
        var clean = coinId.toLowerCase().trim();
        if (Database && typeof Database.getCoinInfo === "function") {
            var info = Database.getCoinInfo(clean);
            if (info && info.thumb) return info.thumb;
        }
        return "";
    }

    ColumnLayout {
        width: parent.width
        spacing: Kirigami.Units.mediumSpacing

        Kirigami.FormLayout {
            Layout.fillWidth: true

            Controls.Switch {
                id: enablePortfolioSwitch
                Kirigami.FormData.label: i18n("Portfolio Tracking:")
                text: i18n("Enable Crypto Portfolio")
                checked: root.isPortfolioEnabled
                onToggled: {
                    if (root.isPortfolioEnabled !== checked) {
                        root.isPortfolioEnabled = checked;
                        root.saveToConfig();
                    }
                }
            }
        }

        // Банер приватності
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: privacyCol.implicitHeight + Kirigami.Units.largeSpacing * 2
            color: Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.08)
            radius: 8
            border.color: Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.25)
            border.width: 1

            RowLayout {
                id: privacyCol
                anchors.fill: parent
                anchors.margins: Kirigami.Units.largeSpacing
                spacing: Kirigami.Units.mediumSpacing

                Kirigami.Icon {
                    source: "security-high-symbolic"
                    implicitWidth: 28
                    implicitHeight: 28
                    color: Kirigami.Theme.highlightColor
                    Layout.alignment: Qt.AlignVCenter
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Controls.Label {
                        text: i18n("100% Local & Private")
                        font.bold: true
                        font.pointSize: 9.5
                    }

                    Controls.Label {
                        text: i18n("Your portfolio assets, quantities, and transactions are stored strictly on your device. No balances or financial data are ever transmitted to third parties or remote servers.")
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                        font.pointSize: 8.5
                        opacity: 0.85
                        lineHeight: 1.25
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.mediumSpacing
            visible: root.isPortfolioEnabled

            Kirigami.Separator {
                Layout.fillWidth: true
            }

            Controls.Label {
                text: root.editingIndex === -1 ? i18n("Add Asset to Portfolio:") : i18n("Edit Asset:")
                font.bold: true
            }

            Kirigami.FormLayout {
                Layout.fillWidth: true

                Controls.TextField {
                    id: coinSearchField
                    Kirigami.FormData.label: i18n("Coin (Ticker or ID):")
                    placeholderText: i18n("e.g. btc, eth, sol, doge...")
                    Layout.fillWidth: true
                    enabled: root.editingIndex === -1

                    onTextChanged: {
                        if (activeFocus && !root.isProgrammaticChange) {
                            root.selectedCoinId = "";
                            root.activeSearchIndex = -1;
                            searchTimer.restart();
                        }
                    }

                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Down && searchResultsModel.count > 0) {
                            root.activeSearchIndex = Math.min(searchResultsModel.count - 1, root.activeSearchIndex + 1);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Up && searchResultsModel.count > 0) {
                            root.activeSearchIndex = Math.max(-1, root.activeSearchIndex - 1);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            event.accepted = true;
                            if (root.activeSearchIndex >= 0 && root.activeSearchIndex < searchResultsModel.count) {
                                root.selectSearchResult(root.activeSearchIndex);
                            } else if (searchResultsModel.count > 0) {
                                root.selectSearchResult(0);
                            } else {
                                amountField.forceActiveFocus();
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    visible: searchResultsModel.count > 0 && coinSearchField.activeFocus

                    Repeater {
                        model: searchResultsModel
                        delegate: Controls.ItemDelegate {
                            id: searchDel
                            Layout.fillWidth: true
                            implicitHeight: 36

                            required property string coinId
                            required property string name
                            required property string symbol
                            required property int index

                            background: Rectangle {
                                color: searchDel.index === root.activeSearchIndex
                                ? Kirigami.Theme.focusColor
                                : (searchDel.hovered ? Kirigami.Theme.hoverColor : Kirigami.Theme.alternateBackgroundColor)
                                radius: 4
                            }

                            contentItem: RowLayout {
                                anchors.fill: parent
                                anchors.margins: 6
                                Controls.Label {
                                    text: searchDel.name
                                    font.bold: true
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                                Controls.Label {
                                    text: searchDel.symbol.toUpperCase()
                                    opacity: 0.7
                                    font.pointSize: 8.5
                                }
                            }

                            onClicked: root.selectSearchResult(searchDel.index)
                        }
                    }
                }

                Controls.TextField {
                    id: amountField
                    Kirigami.FormData.label: i18n("Holdings Quantity:")
                    placeholderText: "e.g. 0.5"
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    Layout.fillWidth: true
                }

                Controls.TextField {
                    id: buyPriceField
                    Kirigami.FormData.label: i18n("Avg. Buy Price (Optional):")
                    placeholderText: "e.g. 62500"
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    Layout.fillWidth: true
                }

                RowLayout {
                    spacing: Kirigami.Units.smallSpacing

                    Controls.Button {
                        text: root.editingIndex === -1 ? i18n("Add to Portfolio") : i18n("Save Changes")
                        icon.name: root.editingIndex === -1 ? "list-add-symbolic" : "document-save-symbolic"
                        onClicked: root.saveItem()
                    }

                    Controls.Button {
                        text: i18n("Cancel")
                        icon.name: "dialog-cancel"
                        visible: root.editingIndex !== -1
                        onClicked: root.resetForm()
                    }
                }
            }

            Kirigami.Separator {
                Layout.fillWidth: true
            }

            Controls.Label {
                text: i18n("Your Portfolio Assets (%1)").arg(root.portfolioItems.length)
                font.bold: true
            }

            Kirigami.PlaceholderMessage {
                text: i18n("No assets added yet")
                explanation: i18n("Add your crypto holdings using the form above.")
                visible: root.portfolioItems.length === 0
                Layout.fillWidth: true
                icon.name: "wallet-open"
            }

            ListView {
                id: portfolioListView
                Layout.fillWidth: true
                implicitHeight: contentHeight
                interactive: false
                spacing: 4
                model: root.portfolioItems

                delegate: Rectangle {
                    id: portDel
                    width: portfolioListView.width
                    height: 48
                    color: Kirigami.Theme.alternateBackgroundColor
                    radius: 6
                    border.color: portDel.index === root.editingIndex
                    ? Kirigami.Theme.highlightColor
                    : Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
                    border.width: portDel.index === root.editingIndex ? 2 : 1

                    required property var modelData
                    required property int index

                    readonly property string displayName: root.getCoinDisplayName(portDel.modelData.id)
                    readonly property string displaySymbol: root.getCoinDisplaySymbol(portDel.modelData.id)
                    readonly property string thumbUrl: root.getCoinThumb(portDel.modelData.id)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: Kirigami.Units.mediumSpacing

                        // Фіксована ширина для індексу: запобігає зсуву логотипів для чисел 1..9 vs 10..99
                        PlasmaComponents.Label {
                            text: (portDel.index + 1) + "."
                            font.bold: true
                            opacity: 0.4
                            Layout.preferredWidth: 28
                            Layout.alignment: Qt.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                        }

                        // Логотип монети
                        Item {
                            Layout.preferredWidth: 28
                            Layout.preferredHeight: 28
                            Layout.alignment: Qt.AlignVCenter

                            Rectangle {
                                anchors.fill: parent
                                radius: width / 2
                                color: Kirigami.Theme.highlightColor
                                opacity: 0.2
                                visible: coinImg.status !== Image.Ready

                                PlasmaComponents.Label {
                                    anchors.centerIn: parent
                                    text: portDel.displaySymbol ? portDel.displaySymbol.substring(0, 1).toUpperCase() : "?"
                                    font.bold: true
                                    font.pointSize: 9
                                    color: Kirigami.Theme.highlightColor
                                }
                            }

                            Image {
                                id: coinImg
                                anchors.fill: parent
                                source: portDel.thumbUrl || ""
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                visible: coinImg.status === Image.Ready

                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    maskEnabled: true
                                    maskSource: portMask
                                }
                            }

                            Item {
                                id: portMask
                                anchors.fill: parent
                                layer.enabled: true
                                visible: false
                                Rectangle {
                                    anchors.fill: parent
                                    radius: width / 2
                                    color: "black"
                                }
                            }
                        }

                        // Назва та кількість (ліва колонка)
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Layout.alignment: Qt.AlignVCenter

                            RowLayout {
                                spacing: 6
                                Layout.fillWidth: true

                                PlasmaComponents.Label {
                                    text: portDel.displayName
                                    font.bold: true
                                    font.pointSize: 9
                                    elide: Text.ElideRight
                                }

                                Rectangle {
                                    color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
                                    radius: 3
                                    implicitWidth: symTxt.implicitWidth + 6
                                    implicitHeight: symTxt.implicitHeight + 2
                                    Layout.alignment: Qt.AlignVCenter

                                    PlasmaComponents.Label {
                                        id: symTxt
                                        anchors.centerIn: parent
                                        text: portDel.displaySymbol
                                        font.pointSize: 7.5
                                        opacity: 0.7
                                    }
                                }
                            }

                            PlasmaComponents.Label {
                                text: i18n("Amount: %1 %2").arg(PortfolioEngine.formatAmount(portDel.modelData.amount)).arg(portDel.displaySymbol) +
                                      (portDel.modelData.buyPrice > 0 ? (" • " + i18n("Buy: %1").arg(portDel.modelData.buyPrice)) : "")
                                font.pointSize: 8
                                opacity: 0.6
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                        }

                        // Кнопки редагування та видалення
                        RowLayout {
                            spacing: 2
                            Layout.alignment: Qt.AlignVCenter

                            Controls.Button {
                                icon.name: "edit-entry"
                                display: Controls.AbstractButton.IconOnly
                                flat: true
                                onClicked: root.startEdit(portDel.index)
                            }

                            Controls.Button {
                                icon.name: "delete"
                                display: Controls.AbstractButton.IconOnly
                                flat: true
                                onClicked: root.deleteItem(portDel.index)
                            }
                        }
                    }
                }
            }
        }
    }
}
