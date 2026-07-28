pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Item {
    id: activeCoinsCard

    property var globalData: null
    property real scaleFactor: 1.0

    implicitWidth: Kirigami.Units.gridUnit * 9
    implicitHeight: Kirigami.Units.gridUnit * 5.5

    Rectangle {
        anchors.fill: parent
        color: Kirigami.Theme.alternateBackgroundColor
        radius: 14
        border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.12)
        border.width: 1
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Math.round(Kirigami.Units.gridUnit * 0.5 * activeCoinsCard.scaleFactor)
            spacing: Math.round(Kirigami.Units.smallSpacing * activeCoinsCard.scaleFactor)

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Rectangle {
                    Layout.preferredWidth: Math.round(8 * activeCoinsCard.scaleFactor)
                    Layout.preferredHeight: Math.round(8 * activeCoinsCard.scaleFactor)
                    radius: Layout.preferredWidth / 2
                    color: Kirigami.Theme.positiveTextColor
                    Layout.alignment: Qt.AlignVCenter
                }

                PlasmaComponents.Label {
                    text: i18n("Active Cryptos")
                    font {
                        pointSize: 8.5 * activeCoinsCard.scaleFactor
                    }
                    opacity: 0.6
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }

            PlasmaComponents.Label {
                Layout.fillWidth: true
                text: (activeCoinsCard.globalData && activeCoinsCard.globalData.active_cryptocurrencies !== undefined)
                ? Number(activeCoinsCard.globalData.active_cryptocurrencies).toLocaleString(Qt.locale(), "f", 0)
                : "..."
                font {
                    bold: true
                    pointSize: 13 * activeCoinsCard.scaleFactor
                }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            PlasmaComponents.Label {
                Layout.fillWidth: true
                text: i18n("coins on market")
                opacity: 0.5
                font {
                    pointSize: 7.5 * activeCoinsCard.scaleFactor
                }
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }
        }
    }
}
