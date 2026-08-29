pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import "./cards"

Flickable {
    id: feedContainer
    Layout.fillWidth: true
    Layout.fillHeight: true
    clip: true

    contentWidth: width
    contentHeight: mainColumn.implicitHeight

    Controls.ScrollBar.vertical: Controls.ScrollBar {
        parent: feedContainer
        anchors.top: feedContainer.top
        anchors.bottom: feedContainer.bottom
        anchors.right: feedContainer.right
    }

    property var globalData: null
    property var fngData: null
    property string vsCurrency: "usd"
    property string favoriteCoins: ""
    property var coinsData: null

    property var trendingData: []
    property var gainersData: []
    property var losersData: []
    property var marketCoinsData: []

    property bool showTicker: true
    property bool showSummary: true
    property bool showMiniCards: true
    property bool showAnalysisCards: true
    property bool showTables: true
    property bool showHalving: true

    ColumnLayout {
        id: mainColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: Kirigami.Units.gridUnit
        anchors.rightMargin: Kirigami.Units.gridUnit
        anchors.topMargin: Kirigami.Units.gridUnit
        anchors.bottomMargin: Kirigami.Units.gridUnit

        spacing: Kirigami.Units.gridUnit

        TickerCard {
            Layout.fillWidth: true
            implicitHeight: Math.round(Kirigami.Units.gridUnit * 2.2)
            favoriteCoins: feedContainer.favoriteCoins
            coinsData: (feedContainer.marketCoinsData && feedContainer.marketCoinsData.length > 0) ? feedContainer.marketCoinsData : null
            vsCurrency: feedContainer.vsCurrency
            scaleFactor: 1.0
            visible: feedContainer.showTicker
        }

        MarketSummaryCard {
            id: summaryCard
            Layout.fillWidth: true
            globalData: feedContainer.globalData
            fngData: feedContainer.fngData
            marketCoinsData: feedContainer.marketCoinsData
            vsCurrency: feedContainer.vsCurrency
            scaleFactor: 1.05
            visible: feedContainer.showSummary
        }

        RowLayout {
            Layout.fillWidth: true
            implicitHeight: Math.round(Kirigami.Units.gridUnit * 5.8)
            spacing: Kirigami.Units.gridUnit
            visible: feedContainer.showMiniCards

            MarketCapCard {
                id: mCapMini
                Layout.fillWidth: true
                Layout.fillHeight: true
                globalData: feedContainer.globalData
                vsCurrency: feedContainer.vsCurrency
                scaleFactor: 1.1
            }

            FearGreedCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                fngData: feedContainer.fngData
                scaleFactor: 1.1
            }

            Volume24hCard {
                id: vol24Mini
                Layout.fillWidth: true
                Layout.fillHeight: true
                globalData: feedContainer.globalData
                vsCurrency: feedContainer.vsCurrency
                scaleFactor: 1.1
            }
        }

        RowLayout {
            Layout.fillWidth: true
            implicitHeight: Math.round(Kirigami.Units.gridUnit * 5.8)
            spacing: Kirigami.Units.gridUnit
            visible: feedContainer.showMiniCards

            DominanceCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                globalData: feedContainer.globalData
                scaleFactor: 1.1
            }

            StablecoinDominanceCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                globalData: feedContainer.globalData
                scaleFactor: 1.1
            }

            ActiveCoinsCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                globalData: feedContainer.globalData
                scaleFactor: 1.1
            }
        }

        RowLayout {
            Layout.fillWidth: true
            implicitHeight: Math.round(Kirigami.Units.gridUnit * 5.8)
            spacing: Kirigami.Units.gridUnit
            visible: feedContainer.showAnalysisCards

            RainbowChartCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                marketCoinsData: feedContainer.marketCoinsData
                coinsData: feedContainer.coinsData
                vsCurrency: feedContainer.vsCurrency
                scaleFactor: 1.15
            }

            EthBtcRatioCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                marketCoinsData: feedContainer.marketCoinsData
                scaleFactor: 1.15
            }
        }

        RowLayout {
            Layout.fillWidth: true
            implicitHeight: Math.round(Kirigami.Units.gridUnit * 10)
            spacing: Kirigami.Units.gridUnit
            visible: feedContainer.showTables

            TopGainersCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                listData: feedContainer.gainersData
                scaleFactor: 1.0
            }

            TopLosersCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                listData: feedContainer.losersData
                scaleFactor: 1.0
            }

            TrendingCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                listData: feedContainer.trendingData
                scaleFactor: 1.0
            }
        }

        HalvingCountdownCard {
            Layout.fillWidth: true
            implicitHeight: Math.round(Kirigami.Units.gridUnit * 6.5)
            scaleFactor: 1.15
            visible: feedContainer.showHalving
        }

        Item {
            Layout.preferredHeight: Math.round(Kirigami.Units.gridUnit * 1.5)
            Layout.fillWidth: true
            visible: feedContainer.showHalving || feedContainer.showTables || feedContainer.showAnalysisCards
        }
    }
}
