pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Item {
    id: rainbowCard

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

    readonly property var zoneInfo: {
        if (btcPrice <= 0) return { "text": "...", "color": Kirigami.Theme.textColor };

        const genesis = new Date("2009-01-03T00:00:00Z");
        const now = new Date();
        const days = Math.max(1, (now - genesis) / (1000 * 60 * 60 * 24));

        const logBtc = Math.log(btcPrice) / Math.LN10;
        const expectedLog = 5.84 * (Math.log(days) / Math.LN10) - 17.015;
        const offset = logBtc - expectedLog;

        if (offset < -0.3) return { "text": i18n("Fire Sale"), "color": Kirigami.Theme.highlightColor };
        if (offset < -0.1) return { "text": i18n("Buy!"), "color": Kirigami.Theme.positiveTextColor };
        if (offset < 0.1)  return { "text": i18n("Accumulate"), "color": Kirigami.Theme.neutralTextColor };
        if (offset < 0.3)  return { "text": i18n("Is this FOMO?"), "color": Kirigami.Theme.neutralTextColor };
        return { "text": i18n("Maximum Bubble!"), "color": Kirigami.Theme.negativeTextColor };
    }

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
            anchors.margins: Math.round(Kirigami.Units.gridUnit * 0.5 * rainbowCard.scaleFactor)
            spacing: Math.round(Kirigami.Units.smallSpacing * rainbowCard.scaleFactor)

            opacity: rainbowCard.btcPrice > 0 ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 250 } }

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Rectangle {
                    Layout.preferredWidth: Math.round(8 * rainbowCard.scaleFactor)
                    Layout.preferredHeight: Math.round(8 * rainbowCard.scaleFactor)
                    radius: Layout.preferredWidth / 2
                    color: rainbowCard.btcPrice > 0 ? rainbowCard.zoneInfo.color : Kirigami.Theme.neutralTextColor
                    Layout.alignment: Qt.AlignVCenter
                }

                PlasmaComponents.Label {
                    text: i18n("BTC Price Valuation")
                    font.pointSize: 9 * rainbowCard.scaleFactor
                    color: Kirigami.Theme.textColor
                    opacity: 0.7
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }

            PlasmaComponents.Label {
                Layout.fillWidth: true
                text: rainbowCard.zoneInfo.text
                font {
                    bold: true
                    pointSize: 11 * rainbowCard.scaleFactor
                }
                color: rainbowCard.zoneInfo.color
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 0

                Item { Layout.fillWidth: true }

                Rectangle {
                    visible: rainbowCard.btcPrice > 0
                    Layout.preferredWidth: changeRow.implicitWidth + 8
                    Layout.preferredHeight: changeRow.implicitHeight + 4
                    color: rainbowCard.btcChange >= 0
                    ? Qt.rgba(Kirigami.Theme.positiveTextColor.r, Kirigami.Theme.positiveTextColor.g, Kirigami.Theme.positiveTextColor.b, 0.12)
                    : Qt.rgba(Kirigami.Theme.negativeTextColor.r, Kirigami.Theme.negativeTextColor.g, Kirigami.Theme.negativeTextColor.b, 0.12)
                    radius: 8

                    RowLayout {
                        id: changeRow
                        anchors.centerIn: parent
                        spacing: 2

                        PlasmaComponents.Label {
                            text: rainbowCard.btcChange >= 0 ? "▲" : "▼"
                            color: rainbowCard.btcChange >= 0 ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
                            font.pointSize: 7.5 * rainbowCard.scaleFactor
                        }

                        PlasmaComponents.Label {
                            text: rainbowCard.btcChange.toFixed(2) + "%"
                            font {
                                bold: true
                                pointSize: 7.5 * rainbowCard.scaleFactor
                            }
                            color: rainbowCard.btcChange >= 0 ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
                        }
                    }
                }
            }
        }

        PlasmaComponents.Label {
            text: i18n("Loading...")
            anchors.centerIn: parent
            font.pointSize: 9 * rainbowCard.scaleFactor
            opacity: rainbowCard.btcPrice > 0 ? 0.0 : 0.6
            visible: opacity > 0.0
            Behavior on opacity { NumberAnimation { duration: 250 } }
        }
    }
}
