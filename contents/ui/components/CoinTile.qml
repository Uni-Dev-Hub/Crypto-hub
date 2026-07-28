pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import "../../code/alertEngine.js" as AlertEngine

Item {
    id: tile

    required property string modelData
    property var coinsData: null
    property string vsCurrency: "usd"
    property int gridColumns: 5
    property real gridSpacing: 8
    property string alertsJson: ""

    readonly property string coinId: tile.modelData ? tile.modelData.trim() : ""
    readonly property var coinDetails: (tile.coinsData && tile.coinId && tile.coinsData[tile.coinId]) ? tile.coinsData[tile.coinId] : null

    width: parent ? (parent.width / tile.gridColumns - tile.gridSpacing) : 120
    height: 85

    readonly property real price: tile.coinDetails ? tile.coinDetails[tile.vsCurrency] || 0.0 : 0.0
    readonly property real change: tile.coinDetails ? tile.coinDetails[tile.vsCurrency + "_24h_change"] || 0.0 : 0.0
    readonly property string symbol: tile.coinDetails ? tile.coinDetails.symbol || "" : ""

    readonly property int activeAlertsCount: AlertEngine.getAlertCountForCoin(tile.alertsJson, tile.coinId)

    function getCurrencySymbol(vs) {
        if (!vs) return "$ ";
        const cur = vs.toLowerCase().trim();
        if (cur === "usd" || cur === "cad" || cur === "aud") return "$ ";
        if (cur === "eur") return "€ ";
        if (cur === "uah") return "₴ ";
        if (cur === "gbp") return "£ ";
        if (cur === "jpy" || cur === "cny") return "¥ ";
        if (cur === "inr") return "₹ ";
        if (cur === "try") return "₺ ";
        if (cur === "pln") return "zł ";
        if (cur === "ils") return "₪ ";
        if (cur === "czk") return "Kč ";
        if (cur === "huf") return "Ft ";
        if (cur === "dkk" || cur === "sek" || cur === "nok") return "kr ";
        if (cur === "chf") return "CHF ";
        return vs.toUpperCase() + " ";
    }

    function formatPrice(val, vs) {
        if (val <= 0) return "...";
        var str = val.toString();
        var decimals = 2;

        if (str.indexOf('e') !== -1) {
            var parts = str.split('e');
            var exponent = parseInt(parts[1], 10);
            var originalDecimals = (parts[0].split('.')[1] || "").length;
            decimals = Math.abs(exponent) + originalDecimals;
        } else {
            var dotIdx = str.indexOf('.');
            if (dotIdx !== -1) {
                decimals = Math.max(2, str.length - dotIdx - 1);
            }
        }
        return getCurrencySymbol(vs) + val.toLocaleString(Qt.locale(), "f", decimals);
    }

    Rectangle {
        anchors.fill: parent
        radius: 12

        color: {
            if (tile.change > 0) {
                return Qt.rgba(Kirigami.Theme.positiveTextColor.r, Kirigami.Theme.positiveTextColor.g, Kirigami.Theme.positiveTextColor.b, 0.16);
            } else if (tile.change < 0) {
                return Qt.rgba(Kirigami.Theme.negativeTextColor.r, Kirigami.Theme.negativeTextColor.g, Kirigami.Theme.negativeTextColor.b, 0.16);
            }
            return Kirigami.Theme.alternateBackgroundColor;
        }

        border.color: {
            if (tile.change > 0) {
                return Qt.rgba(Kirigami.Theme.positiveTextColor.r, Kirigami.Theme.positiveTextColor.g, Kirigami.Theme.positiveTextColor.b, hoverHandler.hovered ? 0.60 : 0.38);
            } else if (tile.change < 0) {
                return Qt.rgba(Kirigami.Theme.negativeTextColor.r, Kirigami.Theme.negativeTextColor.g, Kirigami.Theme.negativeTextColor.b, hoverHandler.hovered ? 0.60 : 0.38);
            }
            return hoverHandler.hovered ? Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.3) : "transparent";
        }
        border.width: 1

        Behavior on border.color {
            ColorAnimation { duration: 150 }
        }

        HoverHandler {
            id: hoverHandler
        }

        ColumnLayout {
            id: tileLayout
            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing
            spacing: Kirigami.Units.smallSpacing

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Item {
                    id: imageContainer
                    Layout.preferredWidth: 22
                    Layout.preferredHeight: 22

                    Kirigami.Icon {
                        anchors.fill: parent
                        source: "currency-btc"
                        color: Kirigami.Theme.highlightColor
                        visible: coinImage.status !== Image.Ready
                    }

                    Image {
                        id: coinImage
                        anchors.fill: parent
                        source: (tile.coinDetails && tile.coinDetails.image) ? tile.coinDetails.image : ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        visible: coinImage.status === Image.Ready

                        layer.enabled: true
                        layer.effect: MultiEffect {
                            maskEnabled: true
                            maskSource: tileMask
                        }
                    }

                    Item {
                        id: tileMask
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

                PlasmaComponents.Label {
                    text: tile.coinId.toUpperCase()
                    font.pointSize: 9
                    color: Kirigami.Theme.textColor
                    opacity: 0.8
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }

            PlasmaComponents.Label {
                Layout.fillWidth: true
                text: tile.formatPrice(tile.price, tile.vsCurrency)
                font.pointSize: 10
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                fontSizeMode: Text.Fit
                minimumPointSize: 7
                elide: Text.ElideNone
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 0

                RowLayout {
                    spacing: 2
                    visible: tile.activeAlertsCount > 0

                    Kirigami.Icon {
                        source: "notifications"
                        implicitWidth: 12
                        implicitHeight: 12
                        color: tile.change >= 0 ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
                    }

                    PlasmaComponents.Label {
                        text: tile.activeAlertsCount.toString()
                        font.pointSize: 7.5
                        font.bold: true
                        color: tile.change >= 0 ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
                    }
                }

                Item { Layout.fillWidth: true }

                PlasmaComponents.Label {
                    text: tile.price > 0
                    ? (tile.change >= 0 ? "+" : "") + tile.change.toFixed(2) + "%"
                    : "---"
                    font.pointSize: 8
                    font.bold: true
                    color: tile.change >= 0 ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
                }
            }
        }
    }
}
