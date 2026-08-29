pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import "./components/cards"

Item {
    id: desktopRoot
    anchors.fill: parent

    property string favoriteCoins: ""
    property var coinsData: null
    property int coinsDataChangeCounter: 0
    property string vsCurrency: "usd"
    property var fngData: null
    property var globalData: null
    property int desktopCardType: 0
    property bool hasError: false
    property string alertsJson: ""
    property string portfolioJson: ""

    property var trendingData: []
    property var gainersData: []
    property var losersData: []
    property var marketCoinsData: []

    signal configureRequested()
    signal toggleHideBalance()

    readonly property real baseWidth: Kirigami.Units.gridUnit * 9
    readonly property real baseHeight: {
        const type = parseInt(desktopRoot.desktopCardType);
        if (type === 5) {
            return Kirigami.Units.gridUnit * 1.8
        } else if (type === 6 || type === 7 || type === 8) {
            return Kirigami.Units.gridUnit * 10
        } else if (type === 14) {
            return Kirigami.Units.gridUnit * 8.5
        } else {
            return Kirigami.Units.gridUnit * 5.5
        }
    }

    implicitWidth: baseWidth
    implicitHeight: baseHeight

    Layout.minimumWidth: baseWidth
    Layout.minimumHeight: baseHeight

    readonly property real scaleFactor: Math.min(desktopRoot.width / baseWidth, desktopRoot.height / baseHeight)

    readonly property string targetCoinId: {
        if (!desktopRoot.favoriteCoins || desktopRoot.favoriteCoins.trim() === "") {
            return "";
        }

        var list = desktopRoot.favoriteCoins.split(",").map(function(s) { return s.trim().toLowerCase(); }).filter(function(s) { return s !== ""; });
        if (list.length === 0) {
            return "";
        }

        return list[0];
    }

    Loader {
        id: cardLoader
        anchors.fill: parent
        sourceComponent: {
            const type = parseInt(desktopRoot.desktopCardType);

            if (type === 0 && desktopRoot.targetCoinId === "") {
                return emptyFavoriteCardComponent;
            }

            switch (type) {
                case 0: return coinCardComponent;
                case 1: return fngCardComponent;
                case 2: return mcCardComponent;
                case 3: return domCardComponent;
                case 4: return activeCoinsCardComponent;
                case 5: return tickerCardComponent;
                case 6: return gainerCardComponent;
                case 7: return losersCardComponent;
                case 8: return trendingCardComponent;
                case 9: return volumeCardComponent;
                case 10: return ethBtcCardComponent;
                case 11: return halvingCardComponent;
                case 12: return rainbowCardComponent;
                case 13: return stablecoinDomCardComponent;
                case 14: return summaryCardComponent;
                case 15: return portfolioCardComponent;
                default: return coinCardComponent;
            }
        }
    }

    Kirigami.Icon {
        id: offlineIndicator
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: Math.round(6 * desktopRoot.scaleFactor)
        source: "network-disconnect"
        color: Kirigami.Theme.negativeTextColor
        width: Math.round(14 * desktopRoot.scaleFactor)
        height: Math.round(14 * desktopRoot.scaleFactor)
        visible: desktopRoot.hasError
        opacity: 0.75
        z: 99
    }

    Component {
        id: emptyFavoriteCardComponent
        Item {
            id: emptyCard
            implicitWidth: Kirigami.Units.gridUnit * 9
            implicitHeight: Kirigami.Units.gridUnit * 5.5

            Rectangle {
                anchors.fill: parent
                color: Kirigami.Theme.alternateBackgroundColor
                radius: 14
                border.color: hoverHandler.hovered
                ? Kirigami.Theme.highlightColor
                : Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.12)
                border.width: 1

                HoverHandler {
                    id: hoverHandler
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: desktopRoot.configureRequested()
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Math.round(4 * desktopRoot.scaleFactor)
                    width: parent.width - Math.round(16 * desktopRoot.scaleFactor)

                    Kirigami.Icon {
                        Layout.alignment: Qt.AlignHCenter
                        source: "list-add-symbolic"
                        implicitWidth: Math.round(22 * desktopRoot.scaleFactor)
                        implicitHeight: Math.round(22 * desktopRoot.scaleFactor)
                        color: Kirigami.Theme.highlightColor
                    }

                    PlasmaComponents.Label {
                        Layout.fillWidth: true
                        text: i18n("Add Coin")
                        font {
                            bold: true
                            pointSize: 9 * desktopRoot.scaleFactor
                        }
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }

                    PlasmaComponents.Label {
                        Layout.fillWidth: true
                        text: i18n("Click to configure")
                        font.pointSize: 7.5 * desktopRoot.scaleFactor
                        opacity: 0.6
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }

    Component {
        id: coinCardComponent
        CoinCard {
            coinId: desktopRoot.targetCoinId
            coinDetails: (desktopRoot.coinsData && desktopRoot.targetCoinId && desktopRoot.coinsDataChangeCounter >= 0) ? desktopRoot.coinsData[desktopRoot.targetCoinId] : null
            vsCurrency: desktopRoot.vsCurrency
            scaleFactor: desktopRoot.scaleFactor
            alertsJson: desktopRoot.alertsJson
            portfolioJson: desktopRoot.portfolioJson
        }
    }

    Component {
        id: fngCardComponent
        FearGreedCard {
            fngData: desktopRoot.fngData
            scaleFactor: desktopRoot.scaleFactor
        }
    }

    Component {
        id: mcCardComponent
        MarketCapCard {
            globalData: desktopRoot.globalData
            vsCurrency: desktopRoot.vsCurrency
            scaleFactor: desktopRoot.scaleFactor
        }
    }

    Component {
        id: domCardComponent
        DominanceCard {
            globalData: desktopRoot.globalData
            scaleFactor: desktopRoot.scaleFactor
        }
    }

    Component {
        id: activeCoinsCardComponent
        ActiveCoinsCard {
            globalData: desktopRoot.globalData
            scaleFactor: desktopRoot.scaleFactor
        }
    }

    Component {
        id: tickerCardComponent
        TickerCard {
            favoriteCoins: desktopRoot.favoriteCoins
            coinsData: desktopRoot.marketCoinsData.length > 0 ? desktopRoot.marketCoinsData : null
            vsCurrency: desktopRoot.vsCurrency
            scaleFactor: desktopRoot.scaleFactor
        }
    }

    Component {
        id: gainerCardComponent
        TopGainersCard {
            listData: desktopRoot.gainersData
            scaleFactor: desktopRoot.scaleFactor
        }
    }

    Component {
        id: losersCardComponent
        TopLosersCard {
            listData: desktopRoot.losersData
            scaleFactor: desktopRoot.scaleFactor
        }
    }

    Component {
        id: trendingCardComponent
        TrendingCard {
            listData: desktopRoot.trendingData
            scaleFactor: desktopRoot.scaleFactor
        }
    }

    Component {
        id: volumeCardComponent
        Volume24hCard {
            globalData: desktopRoot.globalData
            vsCurrency: desktopRoot.vsCurrency
            scaleFactor: desktopRoot.scaleFactor
        }
    }

    Component {
        id: ethBtcCardComponent
        EthBtcRatioCard {
            marketCoinsData: desktopRoot.marketCoinsData
            coinsData: desktopRoot.coinsData
            vsCurrency: desktopRoot.vsCurrency
            scaleFactor: desktopRoot.scaleFactor
        }
    }

    Component {
        id: halvingCardComponent
        HalvingCountdownCard {
            scaleFactor: desktopRoot.scaleFactor
        }
    }

    Component {
        id: rainbowCardComponent
        RainbowChartCard {
            marketCoinsData: desktopRoot.marketCoinsData
            coinsData: desktopRoot.coinsData
            vsCurrency: desktopRoot.vsCurrency
            scaleFactor: desktopRoot.scaleFactor
        }
    }

    Component {
        id: stablecoinDomCardComponent
        StablecoinDominanceCard {
            globalData: desktopRoot.globalData
            scaleFactor: desktopRoot.scaleFactor
        }
    }

    Component {
        id: summaryCardComponent
        MarketSummaryCard {
            globalData: desktopRoot.globalData
            fngData: desktopRoot.fngData
            marketCoinsData: desktopRoot.marketCoinsData
            vsCurrency: desktopRoot.vsCurrency
            scaleFactor: desktopRoot.scaleFactor
        }
    }

    Component {
        id: portfolioCardComponent
        PortfolioCard {
            portfolioJson: desktopRoot.portfolioJson
            coinsData: desktopRoot.coinsData
            vsCurrency: desktopRoot.vsCurrency
            scaleFactor: desktopRoot.scaleFactor
            onConfigureRequested: desktopRoot.configureRequested()
            onToggleHideBalance: desktopRoot.toggleHideBalance()
        }
    }
}
