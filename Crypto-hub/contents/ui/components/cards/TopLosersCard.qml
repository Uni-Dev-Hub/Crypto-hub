pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Item {
    id: losersCard

    property var listData: []
    property real scaleFactor: 1.0

    implicitWidth: Kirigami.Units.gridUnit * 9
    implicitHeight: Kirigami.Units.gridUnit * 10

    Rectangle {
        anchors.fill: parent
        color: Kirigami.Theme.alternateBackgroundColor
        radius: 14
        border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
        border.width: 1
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Math.round(Kirigami.Units.gridUnit * 0.5 * losersCard.scaleFactor)
            spacing: Math.round(Kirigami.Units.smallSpacing * losersCard.scaleFactor)

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Rectangle {
                    Layout.preferredWidth: Math.round(8 * losersCard.scaleFactor)
                    Layout.preferredHeight: Math.round(8 * losersCard.scaleFactor)
                    radius: Layout.preferredWidth / 2
                    color: Kirigami.Theme.negativeTextColor
                    Layout.alignment: Qt.AlignVCenter
                }

                PlasmaComponents.Label {
                    text: i18n("Top 5 Losers")
                    font {
                        bold: true
                        pointSize: 8.5 * losersCard.scaleFactor
                    }
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Kirigami.Theme.textColor
                opacity: 0.08
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 2

                Repeater {
                    model: (losersCard.listData && losersCard.listData.length > 0) ? losersCard.listData.slice(0, 5) : 0
                    delegate: RowLayout {
                        id: rowLoser
                        required property var modelData
                        required property int index

                        Layout.fillWidth: true

                        PlasmaComponents.Label {
                            text: (rowLoser.index + 1) + "."
                            font.pointSize: 8 * losersCard.scaleFactor
                            opacity: 0.4
                        }

                        Image {
                            Layout.preferredWidth: Math.round(Kirigami.Units.gridUnit * 0.8 * losersCard.scaleFactor)
                            Layout.preferredHeight: Math.round(Kirigami.Units.gridUnit * 0.8 * losersCard.scaleFactor)
                            source: rowLoser.modelData.image || ""
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                        }

                        PlasmaComponents.Label {
                            text: rowLoser.modelData.symbol.toUpperCase()
                            font {
                                bold: true
                                pointSize: 8 * losersCard.scaleFactor
                            }
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        PlasmaComponents.Label {
                            text: rowLoser.modelData.change.toFixed(1) + "%"
                            font {
                                bold: true
                                pointSize: 8 * losersCard.scaleFactor
                            }
                            color: Kirigami.Theme.negativeTextColor
                        }
                    }
                }

                PlasmaComponents.Label {
                    visible: !losersCard.listData || losersCard.listData.length === 0
                    text: i18n("No data")
                    font.pointSize: 8
                    opacity: 0.5
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
}
