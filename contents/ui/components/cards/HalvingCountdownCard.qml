pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import "../../../code/constants.js" as Constants

Item {
    id: halvingCard

    property real scaleFactor: 1.0

    implicitWidth: Kirigami.Units.gridUnit * 9
    implicitHeight: Kirigami.Units.gridUnit * 5.5

    scale: hoverHandler.hovered ? 1.02 : 1.0
    Behavior on scale { NumberAnimation { duration: 150 } }

    readonly property real progress: Constants.getHalvingProgress()
    readonly property int daysLeft: Constants.getDaysToHalving()

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
            anchors.margins: Math.round(Kirigami.Units.gridUnit * 0.5 * halvingCard.scaleFactor)
            spacing: Math.round(Kirigami.Units.smallSpacing * halvingCard.scaleFactor)

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Rectangle {
                    Layout.preferredWidth: Math.round(8 * halvingCard.scaleFactor)
                    Layout.preferredHeight: Math.round(8 * halvingCard.scaleFactor)
                    radius: Layout.preferredWidth / 2
                    color: Kirigami.Theme.highlightColor
                    Layout.alignment: Qt.AlignVCenter
                }

                PlasmaComponents.Label {
                    text: i18n("BTC Halving")
                    font.pointSize: 9 * halvingCard.scaleFactor
                    color: Kirigami.Theme.textColor
                    opacity: 0.7
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }

            PlasmaComponents.Label {
                Layout.fillWidth: true
                text: i18n("%1 days").arg(halvingCard.daysLeft)
                font {
                    bold: true
                    pointSize: 13 * halvingCard.scaleFactor
                }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                PlasmaComponents.Label {
                    text: i18n("Epoch progress: %1%").arg(halvingCard.progress.toFixed(1))
                    font.pointSize: 7.5 * halvingCard.scaleFactor
                    opacity: 0.9
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.round(8 * halvingCard.scaleFactor)
                    color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.25)
                    radius: 4

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: parent.width * (halvingCard.progress / 100)
                        color: Kirigami.Theme.neutralTextColor
                        radius: 4
                    }
                }
            }
        }
    }
}
