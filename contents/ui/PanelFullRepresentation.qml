pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import "./components"

Item {
    id: panelRoot

    // Відносні розміри на основі системної сітки Kirigami
    readonly property real preferredPanelWidth: Math.round(Kirigami.Units.gridUnit * 36)
    readonly property real preferredPanelHeight: Math.round(Kirigami.Units.gridUnit * 28)

    width: preferredPanelWidth
    height: preferredPanelHeight
    implicitWidth: preferredPanelWidth
    implicitHeight: preferredPanelHeight

    Layout.minimumWidth: preferredPanelWidth
    Layout.maximumWidth: preferredPanelWidth
    Layout.minimumHeight: preferredPanelHeight
    Layout.maximumHeight: preferredPanelHeight

    property var globalData: null
    property var fngData: null
    property string vsCurrency: "usd"
    property string favoriteCoins: ""
    property var coinsData: null
    property string alertsJson: ""

    property var trendingData: []
    property var gainersData: []
    property var losersData: []
    property var marketCoinsData: []

    property bool isFetching: false
    property bool isManualRefreshing: false
    property bool hasError: false
    property int errorCountdown: 60
    property string lastUpdatedTime: ""
    property int currentTabIndex: 0

    property bool showTicker: true
    property bool showSummary: true
    property bool showMiniCards: true
    property bool showAnalysisCards: true
    property bool showTables: true
    property bool showHalving: true

    signal refreshRequested()
    signal configureRequested()

    readonly property bool showLoadingScreen: {
        var hasNoData = !panelRoot.coinsData || Object.keys(panelRoot.coinsData).length === 0;
        return panelRoot.isFetching && hasNoData;
    }

    onIsFetchingChanged: {
        if (!isFetching) {
            panelRoot.isManualRefreshing = false;
        }
    }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: Kirigami.Units.gridUnit
        anchors.bottomMargin: Kirigami.Units.gridUnit

        width: Math.min(parent.width, panelRoot.preferredPanelWidth) - (Kirigami.Units.gridUnit * 2)
        spacing: Kirigami.Units.mediumSpacing

        RowLayout {
            id: headerRow
            Layout.fillWidth: true

            Item {
                Layout.preferredWidth: rightHeaderControls.implicitWidth
                Layout.preferredHeight: rightHeaderControls.implicitHeight
            }

            PlasmaComponents.Label {
                text: "Crypto-hub"
                font {
                    pointSize: 14
                    bold: true
                }
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            RowLayout {
                id: rightHeaderControls
                spacing: Kirigami.Units.smallSpacing
                Layout.alignment: Qt.AlignVCenter

                ColumnLayout {
                    spacing: 2
                    Layout.alignment: Qt.AlignVCenter
                    visible: panelRoot.isFetching || panelRoot.hasError || panelRoot.lastUpdatedTime !== ""

                    ColumnLayout {
                        spacing: 0
                        visible: panelRoot.isFetching
                        Layout.alignment: Qt.AlignRight

                        Rectangle {
                            Layout.alignment: Qt.AlignRight
                            color: Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.12)
                            radius: 6
                            border.color: Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.25)
                            border.width: 1
                            implicitWidth: fetchingLabel.implicitWidth + 12
                            implicitHeight: fetchingLabel.implicitHeight + 4

                            PlasmaComponents.Label {
                                id: fetchingLabel
                                anchors.centerIn: parent
                                text: i18n("Updating data...")
                                font {
                                    pointSize: 8.5
                                    bold: true
                                }
                                color: Kirigami.Theme.highlightColor
                            }
                        }
                    }

                    ColumnLayout {
                        spacing: 2
                        visible: !panelRoot.isFetching && panelRoot.hasError
                        Layout.alignment: Qt.AlignRight

                        Rectangle {
                            Layout.alignment: Qt.AlignRight
                            color: Qt.rgba(Kirigami.Theme.negativeTextColor.r, Kirigami.Theme.negativeTextColor.g, Kirigami.Theme.negativeTextColor.b, 0.12)
                            radius: 6
                            border.color: Qt.rgba(Kirigami.Theme.negativeTextColor.r, Kirigami.Theme.negativeTextColor.g, Kirigami.Theme.negativeTextColor.b, 0.25)
                            border.width: 1
                            implicitWidth: errorLabel.implicitWidth + 12
                            implicitHeight: errorLabel.implicitHeight + 4

                            PlasmaComponents.Label {
                                id: errorLabel
                                anchors.centerIn: parent
                                text: i18n("Rate limit exceeded")
                                font {
                                    pointSize: 8.5
                                    bold: true
                                }
                                color: Kirigami.Theme.negativeTextColor
                            }
                        }

                        PlasmaComponents.Label {
                            text: i18n("(retry in %1 sec.)").arg(panelRoot.errorCountdown)
                            font.pointSize: 8
                            color: Kirigami.Theme.negativeTextColor
                            opacity: 0.8
                            horizontalAlignment: Text.AlignRight
                            Layout.alignment: Qt.AlignRight
                        }
                    }

                    ColumnLayout {
                        spacing: 2
                        visible: !panelRoot.isFetching && !panelRoot.hasError && panelRoot.lastUpdatedTime !== ""
                        Layout.alignment: Qt.AlignRight

                        Rectangle {
                            Layout.alignment: Qt.AlignRight
                            color: Qt.rgba(Kirigami.Theme.positiveTextColor.r, Kirigami.Theme.positiveTextColor.g, Kirigami.Theme.positiveTextColor.b, 0.12)
                            radius: 6
                            border.color: Qt.rgba(Kirigami.Theme.positiveTextColor.r, Kirigami.Theme.positiveTextColor.g, Kirigami.Theme.positiveTextColor.b, 0.25)
                            border.width: 1
                            implicitWidth: successLabel.implicitWidth + 12
                            implicitHeight: successLabel.implicitHeight + 4

                            PlasmaComponents.Label {
                                id: successLabel
                                anchors.centerIn: parent
                                text: i18n("Successfully updated")
                                font {
                                    pointSize: 8.5
                                    bold: true
                                }
                                color: Kirigami.Theme.positiveTextColor
                            }
                        }

                        PlasmaComponents.Label {
                            text: i18n("(at %1)").arg(panelRoot.lastUpdatedTime)
                            font.pointSize: 8
                            color: Kirigami.Theme.positiveTextColor
                            opacity: 0.8
                            horizontalAlignment: Text.AlignRight
                            Layout.alignment: Qt.AlignRight
                        }
                    }
                }

                PlasmaComponents.ToolButton {
                    id: refreshButton
                    onClicked: {
                        if (!panelRoot.isFetching) {
                            panelRoot.isManualRefreshing = true;
                            panelRoot.refreshRequested();
                        }
                    }
                    enabled: !panelRoot.isFetching
                    Controls.ToolTip.visible: refreshButton.hovered
                    Controls.ToolTip.text: i18n("Refresh data")

                    contentItem: Kirigami.Icon {
                        id: refreshIcon
                        source: "view-refresh"
                        implicitWidth: Kirigami.Units.iconSizes.smallMedium
                        implicitHeight: Kirigami.Units.iconSizes.smallMedium

                        RotationAnimator {
                            target: refreshIcon
                            from: 0
                            to: 360
                            duration: 1000
                            running: panelRoot.isFetching
                            loops: Animation.Infinite
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Kirigami.Theme.textColor
            opacity: 0.1
        }

        Rectangle {
            id: tabCapsule
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Math.round(Kirigami.Units.gridUnit * 10.5)
            Layout.preferredHeight: 28
            color: Kirigami.Theme.alternateBackgroundColor
            radius: 14
            border.width: 1
            border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)

            Row {
                id: tabRow
                anchors.fill: parent

                Rectangle {
                    width: tabRow.width / 2
                    height: tabRow.height
                    radius: 14
                    color: panelRoot.currentTabIndex === 0 ? Kirigami.Theme.highlightColor : "transparent"

                    PlasmaComponents.Label {
                        anchors.centerIn: parent
                        text: i18n("Feed")
                        font {
                            bold: true
                            pointSize: 9
                        }
                        color: panelRoot.currentTabIndex === 0 ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                        opacity: panelRoot.currentTabIndex === 0 ? 1.0 : 0.6
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: panelRoot.currentTabIndex = 0
                    }
                }

                Rectangle {
                    width: tabRow.width / 2
                    height: tabRow.height
                    radius: 14
                    color: panelRoot.currentTabIndex === 1 ? Kirigami.Theme.highlightColor : "transparent"

                    PlasmaComponents.Label {
                        anchors.centerIn: parent
                        text: i18n("Favorites")
                        font {
                            bold: true
                            pointSize: 9
                        }
                        color: panelRoot.currentTabIndex === 1 ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                        opacity: panelRoot.currentTabIndex === 1 ? 1.0 : 0.6
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: panelRoot.currentTabIndex = 1
                    }
                }
            }
        }

        Item {
            id: contentArea
            Layout.fillWidth: true
            Layout.fillHeight: true

            Item {
                id: mainLayoutContainer
                anchors.fill: parent
                visible: !panelRoot.showLoadingScreen
                clip: true

                Row {
                    id: slidingRow
                    height: parent.height
                    width: parent.width * 2
                    x: panelRoot.currentTabIndex === 0 ? 0 : -parent.width

                    Behavior on x {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                    }

                    FeedTab {
                        width: mainLayoutContainer.width
                        height: mainLayoutContainer.height

                        globalData: panelRoot.globalData
                        fngData: panelRoot.fngData
                        vsCurrency: panelRoot.vsCurrency
                        favoriteCoins: panelRoot.favoriteCoins
                        coinsData: panelRoot.coinsData
                        trendingData: panelRoot.trendingData
                        gainersData: panelRoot.gainersData
                        losersData: panelRoot.losersData
                        marketCoinsData: panelRoot.marketCoinsData

                        showTicker: panelRoot.showTicker
                        showSummary: panelRoot.showSummary
                        showMiniCards: panelRoot.showMiniCards
                        showAnalysisCards: panelRoot.showAnalysisCards
                        showTables: panelRoot.showTables
                        showHalving: panelRoot.showHalving
                    }

                    FavoritesTab {
                        width: mainLayoutContainer.width
                        height: mainLayoutContainer.height

                        favoriteCoins: panelRoot.favoriteCoins
                        coinsData: panelRoot.coinsData
                        vsCurrency: panelRoot.vsCurrency
                        alertsJson: panelRoot.alertsJson

                        onConfigureRequested: panelRoot.configureRequested()
                    }
                }
            }

            ColumnLayout {
                anchors.centerIn: parent
                visible: panelRoot.showLoadingScreen
                spacing: Kirigami.Units.gridUnit

                Controls.BusyIndicator {
                    id: loadingSpinner
                    Layout.alignment: Qt.AlignHCenter
                    running: panelRoot.showLoadingScreen
                }

                PlasmaComponents.Label {
                    text: i18n("Please wait, updating data...")
                    font.pointSize: 10
                    opacity: 0.8
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
}
