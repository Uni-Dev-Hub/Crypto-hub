pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import "../../../code/portfolioEngine.js" as PortfolioEngine

Item {
    id: portCard

    property string portfolioJson: ""
    property var coinsData: null
    property string vsCurrency: "usd"
    property real scaleFactor: 1.0

    signal configureRequested()
    signal toggleHideBalance()

    implicitWidth: Kirigami.Units.gridUnit * 9
    implicitHeight: Kirigami.Units.gridUnit * 5.5

    readonly property var portfolioData: PortfolioEngine.parsePortfolio(portCard.portfolioJson)
    readonly property bool isHideBalance: portfolioData.hideBalance
    readonly property var stats: PortfolioEngine.calculatePortfolio(portfolioData, portCard.coinsData, portCard.vsCurrency)

    scale: hoverHandler.hovered ? 1.02 : 1.0
    Behavior on scale { NumberAnimation { duration: 150 } }

    Rectangle {
        anchors.fill: parent
        color: Kirigami.Theme.alternateBackgroundColor
        radius: 14
        border.color: hoverHandler.hovered ? Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.25) : Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.12)
        border.width: 1
        clip: true

        Behavior on border.color { ColorAnimation { duration: 150 } }
        HoverHandler { id: hoverHandler }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Math.round(Kirigami.Units.gridUnit * 0.5 * portCard.scaleFactor)
            spacing: Math.round(Kirigami.Units.smallSpacing * portCard.scaleFactor)

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Icon {
                    source: "wallet-open"
                    Layout.preferredWidth: Math.round(Kirigami.Units.gridUnit * 0.9 * portCard.scaleFactor)
                    Layout.preferredHeight: Math.round(Kirigami.Units.gridUnit * 0.9 * portCard.scaleFactor)
                    color: Kirigami.Theme.highlightColor
                }

                PlasmaComponents.Label {
                    text: i18n("Portfolio")
                    font.pointSize: 8.5 * portCard.scaleFactor
                    opacity: 0.6
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                MouseArea {
                    Layout.preferredWidth: Math.round(18 * portCard.scaleFactor)
                    Layout.preferredHeight: Math.round(18 * portCard.scaleFactor)
                    cursorShape: Qt.PointingHandCursor
                    onClicked: portCard.toggleHideBalance()

                    Kirigami.Icon {
                        anchors.fill: parent
                        source: portCard.isHideBalance ? "password-show-off" : "password-show-on"
                        opacity: 0.6
                    }
                }
            }

            PlasmaComponents.Label {
                Layout.fillWidth: true
                text: portCard.stats.itemsCount > 0
                ? PortfolioEngine.formatCurrency(portCard.stats.totalCurrentValue, portCard.vsCurrency, portCard.isHideBalance)
                : i18n("Empty")
                font {
                    bold: true
                    pointSize: 11 * portCard.scaleFactor
                }
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }

            // Міні-смуга часток
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.round(6 * portCard.scaleFactor)
                radius: 3
                color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.1)
                visible: portCard.stats.itemsCount > 0
                clip: true

                Row {
                    anchors.fill: parent
                    Repeater {
                        model: portCard.stats.items
                        delegate: Rectangle {
                            id: seg
                            required property var modelData
                            required property int index
                            width: parent.width * (seg.modelData.allocationPct / 100)
                            height: parent.height
                            color: PortfolioEngine.getAssetColor(seg.index)
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 0
                visible: portCard.stats.itemsCount > 0

                Item { Layout.fillWidth: true }

                Rectangle {
                    Layout.preferredWidth: changeRow.implicitWidth + 8
                    Layout.preferredHeight: changeRow.implicitHeight + 4
                    color: portCard.stats.totalChange24hVal >= 0
                    ? Qt.rgba(Kirigami.Theme.positiveTextColor.r, Kirigami.Theme.positiveTextColor.g, Kirigami.Theme.positiveTextColor.b, 0.12)
                    : Qt.rgba(Kirigami.Theme.negativeTextColor.r, Kirigami.Theme.negativeTextColor.g, Kirigami.Theme.negativeTextColor.b, 0.12)
                    radius: 8

                    RowLayout {
                        id: changeRow
                        anchors.centerIn: parent
                        spacing: 2

                        PlasmaComponents.Label {
                            text: portCard.stats.totalChange24hVal >= 0 ? "▲" : "▼"
                            color: portCard.stats.totalChange24hVal >= 0 ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
                            font.pointSize: 7.5 * portCard.scaleFactor
                        }

                        PlasmaComponents.Label {
                            text: (portCard.stats.totalChange24hPct >= 0 ? "+" : "") + portCard.stats.totalChange24hPct.toFixed(2) + "%"
                            font {
                                bold: true
                                pointSize: 7.5 * portCard.scaleFactor
                            }
                            color: portCard.stats.totalChange24hVal >= 0 ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
                        }
                    }
                }
            }
        }
    }
}
