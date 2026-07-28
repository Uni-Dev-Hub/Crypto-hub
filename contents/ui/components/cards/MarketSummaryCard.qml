pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import "../../../code/marketSummary.js" as MarketSummary
import "../../../code/constants.js" as Constants

Item {
    id: summaryCard

    property var globalData: null
    property var fngData: null
    property var marketCoinsData: []
    property string vsCurrency: "usd"
    property real scaleFactor: 1.0

    implicitWidth: Kirigami.Units.gridUnit * 9
    implicitHeight: mainLayout.implicitHeight + Math.round(Kirigami.Units.gridUnit * 1.3 * summaryCard.scaleFactor)

    // Declarative i18n triggers so xgettext extracts all possible summary texts
    readonly property var _trSummary1: i18n("Accumulation ⚖️")
    readonly property var _trSummary2: i18n("Market is range-bound in a low volatility consolidation phase.")
    readonly property var _trSummary3: i18n("Panic / Crash 🚨")
    readonly property var _trSummary4: i18n("Extreme fear in the market. Historic buying opportunity zone.")
    readonly property var _trSummary5: i18n("Rally / Bull Run 🚀")
    readonly property var _trSummary6: i18n("Strong bullish momentum across major assets.")
    readonly property var _trSummary7: i18n("Altseason Peak ⚡")
    readonly property var _trSummary8: i18n("Capital actively flowing into altcoins while BTC dominance decreases.")
    readonly property var _trSummary9: i18n("Correction / Fear 🐻")
    readonly property var _trSummary10: i18n("Market correction phase. Buyers show caution near support levels.")

    readonly property var marketState: MarketSummary.evaluateMarketSummary(
        summaryCard.globalData,
        summaryCard.fngData,
        summaryCard.marketCoinsData,
        summaryCard.vsCurrency,
        Constants
    )

    readonly property color statusColor: {
        if (marketState && marketState.isBearish) return Kirigami.Theme.negativeTextColor;
        if (marketState && marketState.isBullish) return Kirigami.Theme.positiveTextColor;
        if (marketState && marketState.isAltseason) return Kirigami.Theme.highlightColor;
        return Kirigami.Theme.neutralTextColor;
    }

    scale: hoverHandler.hovered ? 1.01 : 1.0
    Behavior on scale { NumberAnimation { duration: 150 } }

    Rectangle {
        anchors.fill: parent
        color: Kirigami.Theme.alternateBackgroundColor
        radius: 14
        border.color: hoverHandler.hovered ? Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.25) : Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
        border.width: 1
        clip: true

        Behavior on border.color { ColorAnimation { duration: 150 } }

        HoverHandler { id: hoverHandler }

        ColumnLayout {
            id: mainLayout
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Math.round(Kirigami.Units.gridUnit * 0.6 * summaryCard.scaleFactor)
            spacing: Math.round(Kirigami.Units.smallSpacing * summaryCard.scaleFactor)

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Rectangle {
                    Layout.preferredWidth: Math.round(8 * summaryCard.scaleFactor)
                    Layout.preferredHeight: Math.round(8 * summaryCard.scaleFactor)
                    radius: Layout.preferredWidth / 2
                    color: summaryCard.statusColor
                    Layout.alignment: Qt.AlignVCenter
                }

                PlasmaComponents.Label {
                    text: i18n("Market Summary:")
                    font.pointSize: 9 * summaryCard.scaleFactor
                    color: Kirigami.Theme.textColor
                    opacity: 0.6
                }

                PlasmaComponents.Label {
                    text: summaryCard.marketState ? i18n(summaryCard.marketState.status) : ""
                    font {
                        bold: true
                        pointSize: 10 * summaryCard.scaleFactor
                    }
                    color: summaryCard.statusColor
                    Layout.fillWidth: true
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Kirigami.Theme.textColor
                opacity: 0.08
            }

            PlasmaComponents.Label {
                Layout.fillWidth: true
                text: summaryCard.marketState ? i18n(summaryCard.marketState.desc) : ""
                font.pointSize: 9 * summaryCard.scaleFactor
                color: Kirigami.Theme.textColor
                opacity: 0.95
                wrapMode: Text.Wrap
                lineHeight: 1.15
            }
        }
    }
}
