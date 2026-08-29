pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Item {
    id: ratioCard

    property var marketCoinsData: []
    property var coinsData: null
    property string vsCurrency: "usd"
    property real scaleFactor: 1.0

    implicitWidth: Kirigami.Units.gridUnit * 9
    implicitHeight: Kirigami.Units.gridUnit * 5.5

    scale: hoverHandler.hovered ? 1.02 : 1.0
    Behavior on scale { NumberAnimation { duration: 150 } }

    readonly property real btcPrice: {
        if (marketCoinsData && marketCoinsData.length > 0) {
            for (let i = 0; i < marketCoinsData.length; i++) {
                if (marketCoinsData[i].symbol.toLowerCase() === "btc") return marketCoinsData[i].price;
            }
        }
        if (coinsData && coinsData["bitcoin"]) {
            return coinsData["bitcoin"][vsCurrency] || 0.0;
        }
        return 0.0;
    }

    readonly property real ethPrice: {
        if (marketCoinsData && marketCoinsData.length > 0) {
            for (let i = 0; i < marketCoinsData.length; i++) {
                if (marketCoinsData[i].symbol.toLowerCase() === "eth") return marketCoinsData[i].price;
            }
        }
        if (coinsData && coinsData["ethereum"]) {
            return coinsData["ethereum"][vsCurrency] || 0.0;
        }
        return 0.0;
    }

    readonly property real ratio: (btcPrice > 0) ? (ethPrice / btcPrice) : 0.0

    readonly property real btcChange: {
        if (marketCoinsData && marketCoinsData.length > 0) {
            for (let i = 0; i < marketCoinsData.length; i++) {
                if (marketCoinsData[i].symbol.toLowerCase() === "btc") return marketCoinsData[i].change;
            }
        }
        if (coinsData && coinsData["bitcoin"]) {
            return coinsData["bitcoin"][vsCurrency + "_24h_change"] || 0.0;
        }
        return 0.0;
    }

    readonly property real ethChange: {
        if (marketCoinsData && marketCoinsData.length > 0) {
            for (let i = 0; i < marketCoinsData.length; i++) {
                if (marketCoinsData[i].symbol.toLowerCase() === "eth") return marketCoinsData[i].change;
            }
        }
        if (coinsData && coinsData["ethereum"]) {
            return coinsData["ethereum"][vsCurrency + "_24h_change"] || 0.0;
        }
        return 0.0;
    }

    readonly property real ratioChange: ethChange - btcChange

    Rectangle {
        anchors.fill: parent
        color: Kirigami.Theme.alternateBackgroundColor
        radius: 12
        border.color: hoverHandler.hovered ? Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.25) : Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
        border.width: 1
        clip: true

        Behavior on border.color { ColorAnimation { duration: 150 } }

        HoverHandler { id: hoverHandler }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Math.round(Kirigami.Units.gridUnit * 0.5 * ratioCard.scaleFactor)
            spacing: Math.round(Kirigami.Units.smallSpacing * ratioCard.scaleFactor)

            opacity: ratioCard.ratio > 0 ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 250 } }

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Rectangle {
                    Layout.preferredWidth: Math.round(8 * ratioCard.scaleFactor)
                    Layout.preferredHeight: Math.round(8 * ratioCard.scaleFactor)
                    radius: Layout.preferredWidth / 2
                    color: ratioCard.ratio > 0 ? (ratioCard.ratioChange >= 0 ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor) : Kirigami.Theme.neutralTextColor
                    Layout.alignment: Qt.AlignVCenter
                }

                PlasmaComponents.Label {
                    text: i18n("ETH/BTC Ratio")
                    font.pointSize: 9 * ratioCard.scaleFactor
                    color: Kirigami.Theme.textColor
                    opacity: 0.7
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }

            PlasmaComponents.Label {
                Layout.fillWidth: true
                text: ratioCard.ratio > 0 ? ratioCard.ratio.toFixed(4) : "..."
                font {
                    bold: true
                    pointSize: 14 * ratioCard.scaleFactor
                }
                color: Kirigami.Theme.textColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 0

                Item { Layout.fillWidth: true }

                Rectangle {
                    visible: ratioCard.ratio > 0
                    Layout.preferredWidth: changeRow.implicitWidth + 8
                    Layout.preferredHeight: changeRow.implicitHeight + 4
                    color: ratioCard.ratioChange >= 0
                    ? Qt.rgba(Kirigami.Theme.positiveTextColor.r, Kirigami.Theme.positiveTextColor.g, Kirigami.Theme.positiveTextColor.b, 0.12)
                    : Qt.rgba(Kirigami.Theme.negativeTextColor.r, Kirigami.Theme.negativeTextColor.g, Kirigami.Theme.negativeTextColor.b, 0.12)
                    radius: 8

                    RowLayout {
                        id: changeRow
                        anchors.centerIn: parent
                        spacing: 2

                        PlasmaComponents.Label {
                            text: ratioCard.ratioChange >= 0 ? "▲" : "▼"
                            color: ratioCard.ratioChange >= 0 ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
                            font.pointSize: 7.5 * ratioCard.scaleFactor
                        }

                        PlasmaComponents.Label {
                            text: (ratioCard.ratioChange >= 0 ? "+" : "") + ratioCard.ratioChange.toFixed(2) + "%"
                            font {
                                bold: true
                                pointSize: 7.5 * ratioCard.scaleFactor
                            }
                            color: ratioCard.ratioChange >= 0 ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
                        }
                    }
                }
            }
        }

        PlasmaComponents.Label {
            text: i18n("Loading...")
            anchors.centerIn: parent
            font.pointSize: 9 * ratioCard.scaleFactor
            opacity: ratioCard.ratio > 0 ? 0.0 : 0.6
            visible: opacity > 0.0
            Behavior on opacity { NumberAnimation { duration: 250 } }
        }
    }
}
