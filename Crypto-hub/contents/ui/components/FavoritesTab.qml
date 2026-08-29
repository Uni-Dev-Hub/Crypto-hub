pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami

Item {
    id: tabRoot
    Layout.fillWidth: true
    Layout.fillHeight: true

    property string favoriteCoins: ""
    property var coinsData: null
    property string vsCurrency: "usd"
    property string alertsJson: ""
    property string portfolioJson: ""

    signal configureRequested()

    readonly property var coinsArray: {
        var clean = tabRoot.favoriteCoins.trim();
        if (clean === "") return [];
        return clean.split(",").map(function(s) { return s.trim(); }).filter(function(s) { return s !== ""; });
    }

    ScrollView {
        id: scrollContainer
        anchors.fill: parent
        clip: true
        visible: tabRoot.coinsArray.length > 0

        leftPadding: Kirigami.Units.gridUnit
        rightPadding: Kirigami.Units.gridUnit
        topPadding: Kirigami.Units.gridUnit
        bottomPadding: Kirigami.Units.gridUnit

        Grid {
            id: favoritesGrid
            width: scrollContainer.availableWidth
            columns: 5
            spacing: Kirigami.Units.smallSpacing

            Repeater {
                model: tabRoot.coinsArray

                CoinTile {
                    coinsData: tabRoot.coinsData
                    vsCurrency: tabRoot.vsCurrency
                    gridColumns: favoritesGrid.columns
                    gridSpacing: favoritesGrid.spacing
                    alertsJson: tabRoot.alertsJson
                    portfolioJson: tabRoot.portfolioJson
                }
            }
        }
    }

    ColumnLayout {
        id: placeholder
        anchors.centerIn: parent
        width: parent.width - (Kirigami.Units.gridUnit * 4)
        spacing: Kirigami.Units.largeSpacing
        visible: tabRoot.coinsArray.length === 0

        Kirigami.Icon {
            Layout.alignment: Qt.AlignHCenter
            source: "favorite"
            implicitWidth: Kirigami.Units.iconSizes.huge
            implicitHeight: Kirigami.Units.iconSizes.huge
            color: Kirigami.Theme.highlightColor
            opacity: 0.65
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            Label {
                Layout.fillWidth: true
                text: i18n("Favorites list is empty")
                font {
                    bold: true
                    pointSize: 11
                }
                horizontalAlignment: Text.AlignHCenter
                opacity: 0.95
            }

            Label {
                Layout.fillWidth: true
                text: i18n("Add your favorite coins in widget settings to track their prices on this tab.")
                font.pointSize: 9.5
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                opacity: 0.6
            }
        }

        Button {
            Layout.alignment: Qt.AlignHCenter
            text: i18n("Go to Settings")
            icon.name: "configure"

            onClicked: {
                tabRoot.configureRequested();
            }
        }
    }
}
