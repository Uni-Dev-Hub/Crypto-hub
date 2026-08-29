pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Item {
    id: domCard

    property var globalData: null
    property real scaleFactor: 1.0

    implicitWidth: Kirigami.Units.gridUnit * 9
    implicitHeight: Kirigami.Units.gridUnit * 5.5

    readonly property var topDominanceList: {
        if (!domCard.globalData || !domCard.globalData.market_cap_percentage) return [];
        let list = [];
        let obj = domCard.globalData.market_cap_percentage;
        for (let key in obj) {
            list.push({ "symbol": key.toUpperCase(), "value": obj[key] });
        }
        list.sort(function(a, b) { return b.value - a.value; });
        return list.slice(0, 3);
    }

    readonly property real top3Sum: {
        let sum = 0;
        for (let i = 0; i < domCard.topDominanceList.length; i++) {
            sum += domCard.topDominanceList[i].value;
        }
        return sum;
    }

    function getCoinColor(symbol, index) {
        if (symbol === "BTC") return Kirigami.Theme.neutralTextColor;
        if (symbol === "ETH") return Kirigami.Theme.highlightColor;
        if (symbol === "USDT") return Kirigami.Theme.positiveTextColor;
        const colors = [
            Kirigami.Theme.negativeTextColor,
            Kirigami.Theme.neutralTextColor,
            Kirigami.Theme.linkTextColor
        ];
        return colors[index % colors.length];
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
            anchors.margins: Math.round(Kirigami.Units.gridUnit * 0.5 * domCard.scaleFactor)
            spacing: Math.round(Kirigami.Units.smallSpacing * domCard.scaleFactor)

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Rectangle {
                    Layout.preferredWidth: Math.round(8 * domCard.scaleFactor)
                    Layout.preferredHeight: Math.round(8 * domCard.scaleFactor)
                    radius: Layout.preferredWidth / 2
                    color: Kirigami.Theme.neutralTextColor
                    Layout.alignment: Qt.AlignVCenter
                }

                PlasmaComponents.Label {
                    text: i18n("Dominance")
                    font {
                        pointSize: 8.5 * domCard.scaleFactor
                    }
                    opacity: 0.6
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.round(8 * domCard.scaleFactor)
                color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.25)
                radius: 4
                clip: true

                Row {
                    anchors.fill: parent
                    spacing: 0

                    Repeater {
                        model: domCard.topDominanceList
                        delegate: Rectangle {
                            id: barSeg
                            required property var modelData
                            required property int index
                            width: parent.width * (barSeg.modelData.value / 100)
                            height: parent.height
                            color: domCard.getCoinColor(barSeg.modelData.symbol, barSeg.index)
                        }
                    }

                    Rectangle {
                        width: parent.width * (Math.max(0, 100 - domCard.top3Sum) / 100)
                        height: parent.height
                        color: Kirigami.Theme.textColor
                        opacity: 0.25
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Repeater {
                    model: domCard.topDominanceList
                    delegate: RowLayout {
                        id: legRow
                        required property var modelData
                        required property int index
                        spacing: 4

                        Rectangle {
                            Layout.preferredWidth: Math.round(6 * domCard.scaleFactor)
                            Layout.preferredHeight: Math.round(6 * domCard.scaleFactor)
                            radius: 3
                            color: domCard.getCoinColor(legRow.modelData.symbol, legRow.index)
                        }

                        PlasmaComponents.Label {
                            text: legRow.modelData.symbol + " " + legRow.modelData.value.toFixed(1) + "%"
                            font {
                                pointSize: 7.5 * domCard.scaleFactor
                                bold: true
                            }
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }
}
