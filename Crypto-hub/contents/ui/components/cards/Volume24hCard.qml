pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Item {
    id: volCard

    property var globalData: null
    property string vsCurrency: "usd"
    property real scaleFactor: 1.0

    implicitWidth: Kirigami.Units.gridUnit * 9
    implicitHeight: Kirigami.Units.gridUnit * 5.5

    readonly property real change24h: (volCard.globalData && volCard.globalData.market_cap_change_percentage_24h_usd) ? volCard.globalData.market_cap_change_percentage_24h_usd : 0.0

    function getCurrencySymbol(vs) {
        const cur = vs.toLowerCase();
        if (cur === "usd") return "$";
        if (cur === "eur") return "€";
        if (cur === "uah") return "₴";
        if (cur === "rub") return "₽";
        if (cur === "gbp") return "£";
        return vs.toUpperCase();
    }

    function formatVolume(val, vs) {
        if (!val) return "...";
        var rounded = Math.round(val);
        return getCurrencySymbol(vs) + " " + rounded.toLocaleString(Qt.locale(), "f", 0);
    }

    scale: hoverHandler.hovered ? 1.02 : 1.0
    Behavior on scale { NumberAnimation { duration: 150 } }

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
            anchors.margins: Math.round(Kirigami.Units.gridUnit * 0.5 * volCard.scaleFactor)
            spacing: Math.round(Kirigami.Units.smallSpacing * volCard.scaleFactor)

            opacity: volCard.globalData ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 250 } }

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Rectangle {
                    Layout.preferredWidth: Math.round(8 * volCard.scaleFactor)
                    Layout.preferredHeight: Math.round(8 * volCard.scaleFactor)
                    radius: Layout.preferredWidth / 2
                    color: Kirigami.Theme.positiveTextColor
                    Layout.alignment: Qt.AlignVCenter
                }

                PlasmaComponents.Label {
                    text: i18n("24h Volume")
                    font.pointSize: 9 * volCard.scaleFactor
                    color: Kirigami.Theme.textColor
                    opacity: 0.7
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }

            PlasmaComponents.Label {
                Layout.fillWidth: true
                text: (volCard.globalData && volCard.globalData.total_volume && volCard.globalData.total_volume[volCard.vsCurrency])
                ? volCard.formatVolume(volCard.globalData.total_volume[volCard.vsCurrency], volCard.vsCurrency)
                : "..."
                font {
                    bold: true
                    pointSize: 10.5 * volCard.scaleFactor
                }
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 0

                Item { Layout.fillWidth: true }

                Rectangle {
                    visible: volCard.globalData !== null
                    Layout.preferredWidth: changeRow.implicitWidth + 8
                    Layout.preferredHeight: changeRow.implicitHeight + 4
                    color: volCard.change24h >= 0
                    ? Qt.rgba(Kirigami.Theme.positiveTextColor.r, Kirigami.Theme.positiveTextColor.g, Kirigami.Theme.positiveTextColor.b, 0.12)
                    : Qt.rgba(Kirigami.Theme.negativeTextColor.r, Kirigami.Theme.negativeTextColor.g, Kirigami.Theme.negativeTextColor.b, 0.12)
                    radius: 8

                    RowLayout {
                        id: changeRow
                        anchors.centerIn: parent
                        spacing: 2

                        PlasmaComponents.Label {
                            text: volCard.change24h >= 0 ? "▲" : "▼"
                            color: volCard.change24h >= 0 ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
                            font.pointSize: 7.5 * volCard.scaleFactor
                        }

                        PlasmaComponents.Label {
                            text: volCard.change24h.toFixed(2) + "%"
                            font {
                                bold: true
                                pointSize: 7.5 * volCard.scaleFactor
                            }
                            color: volCard.change24h >= 0 ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
                        }
                    }
                }
            }
        }

        PlasmaComponents.Label {
            text: i18n("Loading...")
            anchors.centerIn: parent
            font.pointSize: 9 * volCard.scaleFactor
            opacity: volCard.globalData ? 0.0 : 0.6
            visible: opacity > 0.0
            Behavior on opacity { NumberAnimation { duration: 250 } }
        }
    }
}
