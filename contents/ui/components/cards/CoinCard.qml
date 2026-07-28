pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import "../../../code/alertEngine.js" as AlertEngine

Item {
    id: coinCard

    property string coinId: ""
    property var coinDetails: null
    property string vsCurrency: "usd"
    property real scaleFactor: 1.0
    property string alertsJson: ""

    implicitWidth: Kirigami.Units.gridUnit * 9
    implicitHeight: Kirigami.Units.gridUnit * 5.5

    readonly property real price: coinCard.coinDetails ? coinCard.coinDetails[coinCard.vsCurrency] || 0.0 : 0.0
    readonly property real change24h: coinCard.coinDetails ? coinCard.coinDetails[coinCard.vsCurrency + "_24h_change"] || 0.0 : 0.0
    readonly property string symbol: coinCard.coinDetails ? coinCard.coinDetails.symbol || "" : ""

    readonly property int activeAlertsCount: AlertEngine.getAlertCountForCoin(coinCard.alertsJson, coinCard.coinId)

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
        color: coinCard.change24h > 0
        ? Qt.rgba(Kirigami.Theme.positiveTextColor.r, Kirigami.Theme.positiveTextColor.g, Kirigami.Theme.positiveTextColor.b, 0.12)
        : (coinCard.change24h < 0 ? Qt.rgba(Kirigami.Theme.negativeTextColor.r, Kirigami.Theme.negativeTextColor.g, Kirigami.Theme.negativeTextColor.b, 0.12) : Kirigami.Theme.alternateBackgroundColor)
        radius: 14
        border.color: coinCard.change24h > 0
        ? Qt.rgba(Kirigami.Theme.positiveTextColor.r, Kirigami.Theme.positiveTextColor.g, Kirigami.Theme.positiveTextColor.b, 0.3)
        : (coinCard.change24h < 0 ? Qt.rgba(Kirigami.Theme.negativeTextColor.r, Kirigami.Theme.negativeTextColor.g, Kirigami.Theme.negativeTextColor.b, 0.3) : "transparent")
        border.width: 1
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Math.round(Kirigami.Units.gridUnit * 0.5 * coinCard.scaleFactor)
            spacing: Math.round(Kirigami.Units.smallSpacing * coinCard.scaleFactor)

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Item {
                    Layout.preferredWidth: Math.round(Kirigami.Units.gridUnit * 1.4 * coinCard.scaleFactor)
                    Layout.preferredHeight: Math.round(Kirigami.Units.gridUnit * 1.4 * coinCard.scaleFactor)

                    Kirigami.Icon {
                        anchors.fill: parent
                        source: "currency-btc"
                        color: Kirigami.Theme.highlightColor
                        visible: coinImage.status !== Image.Ready
                    }

                    Image {
                        id: coinImage
                        anchors.fill: parent
                        source: (coinCard.coinDetails && coinCard.coinDetails.image) ? coinCard.coinDetails.image : ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        visible: coinImage.status === Image.Ready

                        layer.enabled: true
                        layer.effect: MultiEffect {
                            maskEnabled: true
                            maskSource: cardMask
                        }
                    }

                    Item {
                        id: cardMask
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
                    text: coinCard.coinId.toUpperCase()
                    font {
                        bold: false
                        pointSize: 8.5 * coinCard.scaleFactor
                    }
                    opacity: 0.6
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }

            PlasmaComponents.Label {
                Layout.fillWidth: true
                text: coinCard.formatPrice(coinCard.price, coinCard.vsCurrency)
                font {
                    bold: true
                    pointSize: 11 * coinCard.scaleFactor
                }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                fontSizeMode: Text.Fit
                minimumPointSize: Math.round(7 * coinCard.scaleFactor)
                elide: Text.ElideNone
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 0

                RowLayout {
                    spacing: Math.round(2 * coinCard.scaleFactor)
                    visible: coinCard.activeAlertsCount > 0

                    Kirigami.Icon {
                        source: "notifications"
                        implicitWidth: Math.round(12 * coinCard.scaleFactor)
                        implicitHeight: Math.round(12 * coinCard.scaleFactor)
                        color: coinCard.change24h >= 0 ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
                    }

                    PlasmaComponents.Label {
                        text: coinCard.activeAlertsCount.toString()
                        font {
                            bold: true
                            pointSize: 8 * coinCard.scaleFactor
                        }
                        color: coinCard.change24h >= 0 ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
                    }
                }

                Item { Layout.fillWidth: true }

                PlasmaComponents.Label {
                    text: coinCard.price > 0
                    ? (coinCard.change24h >= 0 ? "+" : "") + coinCard.change24h.toFixed(2) + "%"
                    : "---"
                    font {
                        bold: true
                        pointSize: 9 * coinCard.scaleFactor
                    }
                    color: coinCard.change24h >= 0 ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
                }
            }
        }
    }
}
