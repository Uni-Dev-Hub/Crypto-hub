pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import QtQuick.Effects
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import "../../code/database.js" as Database
import "../../code/coinSettingsHelper.js" as CoinSettingsHelper

// qmllint disable unqualified
// qmllint disable missing-property

Kirigami.ScrollablePage {
    id: root
    title: i18n("Coin List")
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

    property string cfg_alertsJson: "{\"alerts\":[]}"
    property int cfg_desktopCardType: 0
    property bool cfg_showAnalysisCards: true
    property bool cfg_showHalving: true
    property bool cfg_showMiniCards: true
    property bool cfg_showSummary: true
    property bool cfg_showTables: true
    property bool cfg_showTicker: true
    property int cfg_updateInterval: 5
    property string cfg_vsCurrency: "usd"

    property string cfg_favoriteCoins: ""
    property bool isUpdating: false
    property int activeSearchIndex: -1

    ListModel { id: favoritesModel }
    ListModel { id: searchResultsModel }

    Timer {
        id: searchTimer
        interval: 150
        running: false
        repeat: false
        onTriggered: CoinSettingsHelper.performSearch(searchField.text, searchResultsModel, Database)
    }

    Component.onCompleted: {
        root.loadModel();
    }

    onCfg_favoriteCoinsChanged: {
        root.loadModel();
    }

    function loadModel() {
        if (root.isUpdating) return;
        root.isUpdating = true;
        CoinSettingsHelper.loadFavoritesModel(root.cfg_favoriteCoins, favoritesModel, Database);
        root.isUpdating = false;
    }

    function serialize() {
        if (root.isUpdating) return;
        root.isUpdating = true;
        root.cfg_favoriteCoins = CoinSettingsHelper.serializeFavorites(favoritesModel);
        root.isUpdating = false;
    }

    function executeAdd() {
        var added = CoinSettingsHelper.handleAddAction(searchField.text, favoritesModel, searchResultsModel, root.activeSearchIndex, Database);
        if (added) {
            searchField.clear();
            searchResultsModel.clear();
            root.activeSearchIndex = -1;
            root.serialize();
        }
    }

    ColumnLayout {
        width: parent.width
        spacing: Kirigami.Units.mediumSpacing

        Kirigami.FormLayout {
            Layout.fillWidth: true

            Controls.TextField {
                id: searchField
                Kirigami.FormData.label: i18n("Search or Add Coins:")
                placeholderText: i18n("Name, ticker (e.g. btc) or batch (btc.eth.sol)...")
                Layout.fillWidth: true

                onTextChanged: {
                    root.activeSearchIndex = -1;
                    searchTimer.restart();
                }

                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Down) {
                        if (searchResultsModel.count > 0) {
                            root.activeSearchIndex = Math.min(searchResultsModel.count - 1, root.activeSearchIndex + 1);
                            event.accepted = true;
                        }
                    } else if (event.key === Qt.Key_Up) {
                        if (searchResultsModel.count > 0) {
                            root.activeSearchIndex = Math.max(-1, root.activeSearchIndex - 1);
                            event.accepted = true;
                        }
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        event.accepted = true;
                        root.executeAdd();
                    }
                }
            }
        }

        ColumnLayout {
            id: searchResultsContainer
            Layout.fillWidth: true
            spacing: 2
            visible: searchResultsModel.count > 0 && searchField.text.indexOf('.') === -1

            Repeater {
                model: searchResultsModel
                delegate: Controls.ItemDelegate {
                    id: searchDel
                    Layout.fillWidth: true
                    implicitHeight: 38

                    required property string coinId
                    required property string name
                    required property string symbol
                    required property int index

                    background: Rectangle {
                        color: searchDel.index === root.activeSearchIndex
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

                        PlasmaComponents.Label {
                            text: searchDel.name
                            Layout.fillWidth: true
                            font.bold: true
                            elide: Text.ElideRight
                            color: searchDel.index === root.activeSearchIndex ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                        }

                        PlasmaComponents.Label {
                            text: searchDel.symbol.toUpperCase()
                            font.bold: true
                            font.pointSize: 9
                            opacity: 0.8
                            color: searchDel.index === root.activeSearchIndex ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                        }
                    }

                    onClicked: {
                        CoinSettingsHelper.addCoinIdToList(searchDel.coinId, favoritesModel, Database);
                        searchField.clear();
                        searchResultsModel.clear();
                        root.activeSearchIndex = -1;
                        root.serialize();
                    }
                }
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        Kirigami.PlaceholderMessage {
            text: i18n("Coin list is empty")
            explanation: i18n("Use the search bar above for batch adding (e.g. btc.eth.sol) or searching by name.")
            visible: favoritesModel.count === 0
            Layout.fillWidth: true
            icon.name: "list-add-symbolic"
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: favoritesModel.count > 0
            spacing: Kirigami.Units.smallSpacing

            PlasmaComponents.Label {
                text: i18n("Your watchlist (%1)").arg(favoritesModel.count)
                font {
                    bold: true
                    pointSize: 9
                }
                opacity: 0.7
            }

            ListView {
                id: favoritesListView
                Layout.fillWidth: true
                implicitHeight: contentHeight
                model: favoritesModel
                interactive: false
                spacing: 4

                delegate: Rectangle {
                    id: delegateItem
                    width: favoritesListView.width
                    height: 48
                    color: Kirigami.Theme.alternateBackgroundColor
                    radius: 6
                    border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
                    border.width: 1

                    required property string coinId
                    required property string name
                    required property string symbol
                    required property string thumb
                    required property int index

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: Kirigami.Units.mediumSpacing

                        PlasmaComponents.Label {
                            text: (delegateItem.index + 1) + "."
                            font.bold: true
                            opacity: 0.4
                            Layout.alignment: Qt.AlignVCenter
                        }

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
                                    text: delegateItem.symbol ? delegateItem.symbol.substring(0, 1).toUpperCase() : "?"
                                    font.bold: true
                                    font.pointSize: 9
                                    color: Kirigami.Theme.highlightColor
                                }
                            }

                            Image {
                                id: coinImg
                                anchors.fill: parent
                                source: delegateItem.thumb || ""
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                visible: coinImg.status === Image.Ready

                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    maskEnabled: true
                                    maskSource: maskRect
                                }
                            }

                            Item {
                                id: maskRect
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

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Layout.alignment: Qt.AlignVCenter

                            PlasmaComponents.Label {
                                text: delegateItem.name
                                font.bold: true
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            PlasmaComponents.Label {
                                text: delegateItem.symbol !== "" ? (delegateItem.symbol + " • ID: " + delegateItem.coinId) : ("ID: " + delegateItem.coinId)
                                font.pointSize: 8
                                opacity: 0.5
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                        }

                        Controls.Button {
                            icon.name: "arrow-up-symbolic"
                            display: Controls.AbstractButton.IconOnly
                            enabled: delegateItem.index > 0
                            flat: true
                            onClicked: {
                                favoritesModel.move(delegateItem.index, delegateItem.index - 1, 1);
                                root.serialize();
                            }
                        }

                        Controls.Button {
                            icon.name: "arrow-down-symbolic"
                            display: Controls.AbstractButton.IconOnly
                            enabled: delegateItem.index < favoritesModel.count - 1
                            flat: true
                            onClicked: {
                                favoritesModel.move(delegateItem.index, delegateItem.index + 1, 1);
                                root.serialize();
                            }
                        }

                        Controls.Button {
                            icon.name: "delete"
                            display: Controls.AbstractButton.IconOnly
                            flat: true
                            onClicked: {
                                favoritesModel.remove(delegateItem.index);
                                root.serialize();
                            }
                        }
                    }
                }
            }
        }
    }
}
