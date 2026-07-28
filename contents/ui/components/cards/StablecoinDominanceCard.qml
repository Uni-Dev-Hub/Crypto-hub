pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Item {
    id: stableDomCard

    property var globalData: null
    property real scaleFactor: 1.0

    implicitWidth: Kirigami.Units.gridUnit * 9
    implicitHeight: Kirigami.Units.gridUnit * 5.5

    scale: hoverHandler.hovered ? 1.02 : 1.0
    Behavior on scale { NumberAnimation { duration: 150 } }

    readonly property real dominance: {
        if (!globalData || !globalData.market_cap_percentage) return 0.0;

        const pct = globalData.market_cap_percentage;
        const usdtDom = pct["usdt"] || pct["USDT"] || 0.0;
        const usdcDom = pct["usdc"] || pct["USDC"] || 0.0;

        return usdtDom + usdcDom;
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
            anchors.margins: Math.round(Kirigami.Units.gridUnit * 0.5 * stableDomCard.scaleFactor)
            spacing: Math.round(Kirigami.Units.smallSpacing * stableDomCard.scaleFactor)

            opacity: stableDomCard.dominance > 0 ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 250 } }

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Rectangle {
                    Layout.preferredWidth: Math.round(8 * stableDomCard.scaleFactor)
                    Layout.preferredHeight: Math.round(8 * stableDomCard.scaleFactor)
                    radius: Layout.preferredWidth / 2
                    color: Kirigami.Theme.positiveTextColor
                    Layout.alignment: Qt.AlignVCenter
                }

                PlasmaComponents.Label {
                    text: i18n("Stablecoin Dom")
                    font.pointSize: 9 * stableDomCard.scaleFactor
                    color: Kirigami.Theme.textColor
                    opacity: 0.7
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }

            PlasmaComponents.Label {
                Layout.fillWidth: true
                text: stableDomCard.dominance.toFixed(1) + "%"
                font {
                    bold: true
                    pointSize: 14 * stableDomCard.scaleFactor
                }
                color: Kirigami.Theme.textColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                PlasmaComponents.Label {
                    text: stableDomCard.dominance > 12.0 ? i18n("Risk-Off (Fear) 🛡️") : i18n("Risk-On (Buying) 🚀")
                    font {
                        pointSize: 7.5 * stableDomCard.scaleFactor
                        bold: true
                    }
                    color: stableDomCard.dominance > 12.0 ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.positiveTextColor
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                }
            }
        }

        PlasmaComponents.Label {
            text: i18n("Loading...")
            anchors.centerIn: parent
            font.pointSize: 9 * stableDomCard.scaleFactor
            opacity: stableDomCard.dominance > 0 ? 0.0 : 0.6
            visible: opacity > 0.0
            Behavior on opacity { NumberAnimation { duration: 250 } }
        }
    }
}
