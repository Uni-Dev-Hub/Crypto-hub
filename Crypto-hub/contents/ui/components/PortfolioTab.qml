pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import QtQuick.Effects
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import "../../code/portfolioEngine.js" as PortfolioEngine

Item {
    id: tabRoot
    Layout.fillWidth: true
    Layout.fillHeight: true

    property string portfolioJson: ""
    property var coinsData: null
    property string vsCurrency: "usd"

    signal configureRequested()
    signal toggleHideBalance()

    readonly property var portfolioData: PortfolioEngine.parsePortfolio(tabRoot.portfolioJson)
    readonly property bool isHideBalance: portfolioData.hideBalance
    readonly property var stats: PortfolioEngine.calculatePortfolio(portfolioData, tabRoot.coinsData, tabRoot.vsCurrency)

    Flickable {
        id: scrollArea
        anchors.fill: parent
        clip: true
        contentWidth: width
        contentHeight: mainCol.implicitHeight + Kirigami.Units.gridUnit * 1.5
        visible: tabRoot.stats.itemsCount > 0

        Controls.ScrollBar.vertical: Controls.ScrollBar {
            parent: scrollArea
            anchors.top: scrollArea.top
            anchors.bottom: scrollArea.bottom
            anchors.right: scrollArea.right
        }

        ColumnLayout {
            id: mainCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: Kirigami.Units.gridUnit
            anchors.rightMargin: Kirigami.Units.gridUnit
            anchors.topMargin: Kirigami.Units.smallSpacing
            spacing: Kirigami.Units.mediumSpacing

            // Головна картка балансу
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: summaryCol.implicitHeight + Kirigami.Units.gridUnit * 1.2
                color: tabRoot.stats.totalChange24hVal >= 0
                ? Qt.rgba(Kirigami.Theme.positiveTextColor.r, Kirigami.Theme.positiveTextColor.g, Kirigami.Theme.positiveTextColor.b, 0.08)
                : Qt.rgba(Kirigami.Theme.negativeTextColor.r, Kirigami.Theme.negativeTextColor.g, Kirigami.Theme.negativeTextColor.b, 0.08)
                radius: 14
                border.color: tabRoot.stats.totalChange24hVal >= 0
                ? Qt.rgba(Kirigami.Theme.positiveTextColor.r, Kirigami.Theme.positiveTextColor.g, Kirigami.Theme.positiveTextColor.b, 0.25)
                : Qt.rgba(Kirigami.Theme.negativeTextColor.r, Kirigami.Theme.negativeTextColor.g, Kirigami.Theme.negativeTextColor.b, 0.25)
                border.width: 1

                ColumnLayout {
                    id: summaryCol
                    anchors.fill: parent
                    anchors.margins: Math.round(Kirigami.Units.gridUnit * 0.8)
                    spacing: Kirigami.Units.smallSpacing

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing

                        Kirigami.Icon {
                            source: "wallet-open"
                            implicitWidth: 16
                            implicitHeight: 16
                            color: Kirigami.Theme.highlightColor
                        }

                        PlasmaComponents.Label {
                            text: i18n("Total Portfolio Balance")
                            font.pointSize: 9
                            font.bold: true
                            opacity: 0.7
                            Layout.fillWidth: true
                        }

                        Controls.Button {
                            icon.name: tabRoot.isHideBalance ? "password-show-off" : "password-show-on"
                            flat: true
                            display: Controls.AbstractButton.IconOnly
                            onClicked: tabRoot.toggleHideBalance()
                            Controls.ToolTip.visible: hovered
                            Controls.ToolTip.text: tabRoot.isHideBalance ? i18n("Show balance") : i18n("Hide balance")
                        }
                    }

                    PlasmaComponents.Label {
                        text: PortfolioEngine.formatCurrency(tabRoot.stats.totalCurrentValue, tabRoot.vsCurrency, tabRoot.isHideBalance)
                        font {
                            bold: true
                            pointSize: 22
                        }
                        color: Kirigami.Theme.textColor
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing

                        // 24h PnL Pill
                        Rectangle {
                            implicitWidth: pnl24Row.implicitWidth + 12
                            implicitHeight: pnl24Row.implicitHeight + 6
                            radius: 6
                            color: tabRoot.stats.totalChange24hVal >= 0
                            ? Qt.rgba(Kirigami.Theme.positiveTextColor.r, Kirigami.Theme.positiveTextColor.g, Kirigami.Theme.positiveTextColor.b, 0.16)
                            : Qt.rgba(Kirigami.Theme.negativeTextColor.r, Kirigami.Theme.negativeTextColor.g, Kirigami.Theme.negativeTextColor.b, 0.16)

                            RowLayout {
                                id: pnl24Row
                                anchors.centerIn: parent
                                spacing: 4

                                PlasmaComponents.Label {
                                    text: tabRoot.stats.totalChange24hVal >= 0 ? "▲" : "▼"
                                    color: tabRoot.stats.totalChange24hVal >= 0 ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
                                    font.pointSize: 8
                                }
                                PlasmaComponents.Label {
                                    text: "24h: " + (tabRoot.stats.totalChange24hVal >= 0 ? "+" : "") +
                                          PortfolioEngine.formatCurrency(tabRoot.stats.totalChange24hVal, tabRoot.vsCurrency, tabRoot.isHideBalance) +
                                          " (" + (tabRoot.stats.totalChange24hPct >= 0 ? "+" : "") + tabRoot.stats.totalChange24hPct.toFixed(2) + "%)"
                                    font {
                                        bold: true
                                        pointSize: 8.5
                                    }
                                    color: tabRoot.stats.totalChange24hVal >= 0 ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
                                }
                            }
                        }

                        // All-Time PnL Pill
                        Rectangle {
                            visible: tabRoot.stats.hasBuyPrices
                            implicitWidth: pnlAllRow.implicitWidth + 12
                            implicitHeight: pnlAllRow.implicitHeight + 6
                            radius: 6
                            color: tabRoot.stats.totalPnlVal >= 0
                            ? Qt.rgba(Kirigami.Theme.positiveTextColor.r, Kirigami.Theme.positiveTextColor.g, Kirigami.Theme.positiveTextColor.b, 0.16)
                            : Qt.rgba(Kirigami.Theme.negativeTextColor.r, Kirigami.Theme.negativeTextColor.g, Kirigami.Theme.negativeTextColor.b, 0.16)

                            RowLayout {
                                id: pnlAllRow
                                anchors.centerIn: parent
                                spacing: 4

                                PlasmaComponents.Label {
                                    text: i18n("ROI:")
                                    font.pointSize: 8
                                    opacity: 0.7
                                }
                                PlasmaComponents.Label {
                                    text: (tabRoot.stats.totalPnlVal >= 0 ? "+" : "") +
                                          PortfolioEngine.formatCurrency(tabRoot.stats.totalPnlVal, tabRoot.vsCurrency, tabRoot.isHideBalance) +
                                          " (" + (tabRoot.stats.totalPnlPct >= 0 ? "+" : "") + tabRoot.stats.totalPnlPct.toFixed(1) + "%)"
                                    font {
                                        bold: true
                                        pointSize: 8.5
                                    }
                                    color: tabRoot.stats.totalPnlVal >= 0 ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
                                }
                            }
                        }
                    }
                }
            }

            // Розподіл часток із інтерактивною легендою
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: allocCol.implicitHeight + Kirigami.Units.smallSpacing * 2
                color: Kirigami.Theme.alternateBackgroundColor
                radius: 10
                border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
                border.width: 1

                ColumnLayout {
                    id: allocCol
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.smallSpacing + 2
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true
                        PlasmaComponents.Label {
                            text: i18n("Asset Allocation")
                            font {
                                bold: true
                                pointSize: 8.5
                            }
                            opacity: 0.7
                            Layout.fillWidth: true
                        }
                        PlasmaComponents.Label {
                            text: i18n("%1 Assets").arg(tabRoot.stats.itemsCount)
                            font.pointSize: 8
                            opacity: 0.5
                        }
                    }

                    // Смуга розподілу часток
                    Rectangle {
                        id: barBg
                        Layout.fillWidth: true
                        Layout.preferredHeight: 8
                        radius: 4
                        color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.1)
                        clip: true

                        Row {
                            anchors.fill: parent
                            spacing: 0
                            Repeater {
                                model: tabRoot.stats.items
                                delegate: Rectangle {
                                    id: allocSeg
                                    required property var modelData
                                    required property int index

                                    width: allocSeg.modelData.allocationPct > 0
                                    ? Math.max(4, barBg.width * (allocSeg.modelData.allocationPct / 100))
                                    : 0
                                    height: parent.height
                                    color: PortfolioEngine.getAssetColor(allocSeg.index)
                                }
                            }
                        }
                    }

                    // Міні-легенда
                    Flow {
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing

                        Repeater {
                            model: tabRoot.stats.items.slice(0, 6)
                            delegate: RowLayout {
                                id: legItem
                                required property var modelData
                                required property int index
                                spacing: 4

                                Rectangle {
                                    Layout.preferredWidth: 6
                                    Layout.preferredHeight: 6
                                    radius: 3
                                    color: PortfolioEngine.getAssetColor(legItem.index)
                                }
                                PlasmaComponents.Label {
                                    text: legItem.modelData.symbol + " " + PortfolioEngine.formatAllocation(legItem.modelData.allocationPct)
                                    font.pointSize: 7.5
                                    opacity: 0.75
                                }
                            }
                        }
                    }
                }
            }

            // Список монет портфелю
            ListView {
                id: assetListView
                Layout.fillWidth: true
                implicitHeight: contentHeight
                interactive: false
                spacing: 6
                model: tabRoot.stats.items

                delegate: Rectangle {
                    id: assetItem
                    width: assetListView.width
                    height: 54
                    color: hoverHnd.hovered
                    ? Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.05)
                    : Kirigami.Theme.alternateBackgroundColor
                    radius: 8
                    border.color: hoverHnd.hovered
                    ? Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.22)
                    : Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
                    border.width: 1

                    required property var modelData
                    required property int index

                    HoverHandler {
                        id: hoverHnd
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 12
                        spacing: Kirigami.Units.mediumSpacing

                        // Кольоровий індикатор частки
                        Rectangle {
                            Layout.preferredWidth: 3
                            Layout.preferredHeight: 28
                            Layout.alignment: Qt.AlignVCenter
                            radius: 1.5
                            color: PortfolioEngine.getAssetColor(assetItem.index)
                        }

                        // Круглий аватар монети
                        Item {
                            Layout.preferredWidth: 28
                            Layout.preferredHeight: 28
                            Layout.alignment: Qt.AlignVCenter

                            Rectangle {
                                anchors.fill: parent
                                radius: width / 2
                                color: Kirigami.Theme.highlightColor
                                opacity: 0.2
                                visible: coinImg.status !== Image.Ready

                                PlasmaComponents.Label {
                                    anchors.centerIn: parent
                                    text: assetItem.modelData.symbol ? assetItem.modelData.symbol.substring(0, 1).toUpperCase() : "?"
                                    font.bold: true
                                    font.pointSize: 9
                                    color: Kirigami.Theme.highlightColor
                                }
                            }

                            Image {
                                id: coinImg
                                anchors.fill: parent
                                source: assetItem.modelData.image || ""
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                visible: coinImg.status === Image.Ready

                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    maskEnabled: true
                                    maskSource: imgMask
                                }
                            }

                            Item {
                                id: imgMask
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

                        // Назва, кількість та частка (ліва частина)
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 1

                            RowLayout {
                                spacing: 6
                                Layout.fillWidth: true

                                PlasmaComponents.Label {
                                    text: assetItem.modelData.name
                                    font.bold: true
                                    font.pointSize: 9
                                    elide: Text.ElideRight
                                }

                                Rectangle {
                                    color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
                                    radius: 3
                                    implicitWidth: symTxt.implicitWidth + 6
                                    implicitHeight: symTxt.implicitHeight + 2
                                    Layout.alignment: Qt.AlignVCenter

                                    PlasmaComponents.Label {
                                        id: symTxt
                                        anchors.centerIn: parent
                                        text: assetItem.modelData.symbol
                                        font.pointSize: 7.5
                                        opacity: 0.7
                                    }
                                }
                            }

                            PlasmaComponents.Label {
                                text: (tabRoot.isHideBalance ? "•••••• " : (PortfolioEngine.formatAmount(assetItem.modelData.amount) + " ")) +
                                      assetItem.modelData.symbol + " • " + PortfolioEngine.formatAllocation(assetItem.modelData.allocationPct)
                                font.pointSize: 8
                                opacity: 0.55
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                        }

                        // Баланс та добовий результат (строго вирівняна права колонка)
                        ColumnLayout {
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            Layout.preferredWidth: 105
                            spacing: 1

                            PlasmaComponents.Label {
                                Layout.fillWidth: true
                                text: PortfolioEngine.formatCurrency(assetItem.modelData.currentValue, tabRoot.vsCurrency, tabRoot.isHideBalance)
                                font.bold: true
                                font.pointSize: 9.5
                                horizontalAlignment: Text.AlignRight
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignRight
                                spacing: 4

                                Item { Layout.fillWidth: true }

                                PlasmaComponents.Label {
                                    text: (assetItem.modelData.change24hPct >= 0 ? "+" : "") + assetItem.modelData.change24hPct.toFixed(2) + "%"
                                    font.pointSize: 8
                                    font.bold: true
                                    horizontalAlignment: Text.AlignRight
                                    color: assetItem.modelData.change24hPct >= 0 ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
                                }

                                PlasmaComponents.Label {
                                    visible: assetItem.modelData.buyPrice > 0
                                    text: "• " + (assetItem.modelData.pnlPct >= 0 ? "+" : "") + assetItem.modelData.pnlPct.toFixed(1) + "%"
                                    font.pointSize: 7.5
                                    opacity: 0.7
                                    horizontalAlignment: Text.AlignRight
                                    color: assetItem.modelData.pnlPct >= 0 ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Порожній стан
    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width - (Kirigami.Units.gridUnit * 4)
        spacing: Kirigami.Units.largeSpacing
        visible: tabRoot.stats.itemsCount === 0

        Kirigami.Icon {
            Layout.alignment: Qt.AlignHCenter
            source: "wallet-open"
            implicitWidth: Kirigami.Units.iconSizes.huge
            implicitHeight: Kirigami.Units.iconSizes.huge
            color: Kirigami.Theme.highlightColor
            opacity: 0.65
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            PlasmaComponents.Label {
                Layout.fillWidth: true
                text: i18n("Portfolio is empty")
                font {
                    bold: true
                    pointSize: 11
                }
                horizontalAlignment: Text.AlignHCenter
                opacity: 0.95
            }

            PlasmaComponents.Label {
                Layout.fillWidth: true
                text: i18n("Add your crypto assets in widget settings to track your balances, 24h PnL, and allocation.")
                font.pointSize: 9.5
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                opacity: 0.6
            }
        }

        Controls.Button {
            Layout.alignment: Qt.AlignHCenter
            text: i18n("Go to Settings")
            icon.name: "configure"
            onClicked: tabRoot.configureRequested()
        }
    }
}
