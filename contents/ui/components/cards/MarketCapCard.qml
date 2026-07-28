pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Item {
    id: mcCard

    property var globalData: null
    property string vsCurrency: "usd"
    property real scaleFactor: 1.0

    implicitWidth: Kirigami.Units.gridUnit * 9
    implicitHeight: Kirigami.Units.gridUnit * 5.5

    readonly property real mcChange: (mcCard.globalData && mcCard.globalData.market_cap_change_percentage_24h_usd) ? mcCard.globalData.market_cap_change_percentage_24h_usd : 0.0

    function getCurrencySymbol(vs) {
        if (!vs) return "$";
        const cur = vs.toLowerCase().trim();
        if (cur === "usd" || cur === "cad" || cur === "aud") return "$";
        if (cur === "eur") return "€";
        if (cur === "uah") return "₴";
        if (cur === "gbp") return "£";
        if (cur === "jpy" || cur === "cny") return "¥";
        if (cur === "inr") return "₹";
        if (cur === "try") return "₺";
        if (cur === "pln") return "zł";
        if (cur === "ils") return "₪";
        if (cur === "czk") return "Kč";
        if (cur === "huf") return "Ft";
        if (cur === "dkk" || cur === "sek" || cur === "nok") return "kr";
        if (cur === "chf") return "CHF";
        return vs.toUpperCase();
    }

    function formatMarketCap(val, vs) {
        if (!val) return "...";
        var rounded = Math.round(val);
        return getCurrencySymbol(vs) + " " + rounded.toLocaleString(Qt.locale(), "f", 0);
    }

    Rectangle {
        anchors.fill: parent
        color: Kirigami.Theme.alternateBackgroundColor
        radius: 14
        border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.12)
        border.width: 1
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Math.round(Kirigami.Units.gridUnit * 0.5 * mcCard.scaleFactor)
            spacing: Math.round(Kirigami.Units.smallSpacing * mcCard.scaleFactor)

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Icon {
                    source: "globe-symbolic"
                    Layout.preferredWidth: Math.round(Kirigami.Units.gridUnit * 0.9 * mcCard.scaleFactor)
                    Layout.preferredHeight: Math.round(Kirigami.Units.gridUnit * 0.9 * mcCard.scaleFactor)
                    color: Kirigami.Theme.highlightColor
                }

                PlasmaComponents.Label {
                    text: i18n("Market Cap")
                    font {
                        pointSize: 8.5 * mcCard.scaleFactor
                    }
                    opacity: 0.6
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }

            PlasmaComponents.Label {
                Layout.fillWidth: true
                text: (mcCard.globalData && mcCard.globalData.total_market_cap && mcCard.globalData.total_market_cap[mcCard.vsCurrency])
                ? mcCard.formatMarketCap(mcCard.globalData.total_market_cap[mcCard.vsCurrency], mcCard.vsCurrency)
                : "..."
                font {
                    bold: true
                    pointSize: 10.5 * mcCard.scaleFactor
                }
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 0

                Item { Layout.fillWidth: true }

                Rectangle {
                    visible: mcCard.globalData !== null
                    Layout.preferredWidth: changeRow.implicitWidth + 8
                    Layout.preferredHeight: changeRow.implicitHeight + 4
                    color: mcCard.mcChange >= 0
                    ? Qt.rgba(Kirigami.Theme.positiveTextColor.r, Kirigami.Theme.positiveTextColor.g, Kirigami.Theme.positiveTextColor.b, 0.12)
                    : Qt.rgba(Kirigami.Theme.negativeTextColor.r, Kirigami.Theme.negativeTextColor.g, Kirigami.Theme.negativeTextColor.b, 0.12)
                    radius: 8

                    RowLayout {
                        id: changeRow
                        anchors.centerIn: parent
                        spacing: 2

                        PlasmaComponents.Label {
                            text: mcCard.mcChange >= 0 ? "▲" : "▼"
                            color: mcCard.mcChange >= 0 ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
                            font {
                                pointSize: 7.5 * mcCard.scaleFactor
                            }
                        }

                        PlasmaComponents.Label {
                            text: mcCard.mcChange.toFixed(2) + "%"
                            font {
                                bold: true
                                pointSize: 7.5 * mcCard.scaleFactor
                            }
                            color: mcCard.mcChange >= 0 ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
                        }
                    }
                }
            }
        }
    }
}
