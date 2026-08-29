pragma ComponentBehavior: Bound
import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Item {
    id: tickerCard

    property var coinsData: null
    property string favoriteCoins: ""
    property string vsCurrency: "usd"
    property real scaleFactor: 1.0

    implicitWidth: Kirigami.Units.gridUnit * 9
    implicitHeight: Kirigami.Units.gridUnit * 1.8

    readonly property var backupArray: tickerCard.favoriteCoins.split(",")

    function getCurrencySymbol(vs) {
        const cur = vs.toLowerCase();
        if (cur === "usd") return "$";
        if (cur === "eur") return "€";
        if (cur === "uah") return "₴";
        return vs.toUpperCase();
    }

    function formatPrice(val, vs) {
        if (val <= 0) return "...";
        var str = val.toString();
        var decimals = 2;

        if (str.indexOf('e') !== -1) {
            var parts = str.split('e');
            var exponent = parseInt(parts[1], 10);
            var originalDecimals = (parts[0].split('.')[1] || "").length;
            decimals = Math.abs(exponent) + originalDecimals;
        } else {
            var dotIdx = str.indexOf('.');
            if (dotIdx !== -1) {
                decimals = Math.max(2, str.length - dotIdx - 1);
            }
        }
        return getCurrencySymbol(vs) + " " + val.toLocaleString(Qt.locale(), "f", decimals);
    }

    onWidthChanged: {
        if (tickerCard.visible && width > 100 && scrollRow.implicitWidth > width) {
            debounceTimer.restart();
        }
    }

    onVisibleChanged: {
        if (tickerCard.visible && tickerCard.width > 100 && scrollRow.implicitWidth > tickerCard.width) {
            debounceTimer.restart();
        } else {
            scrollAnimation.stop();
        }
    }

    Timer {
        id: debounceTimer
        interval: 300
        running: false
        repeat: false
        onTriggered: {
            if (!tickerCard.visible) return;
            scrollAnimation.stop();
            scrollAnimation.from = tickerCard.width;
            scrollAnimation.to = -scrollRow.implicitWidth;
            scrollAnimation.duration = Math.max(20000, scrollRow.implicitWidth * 45);
            scrollAnimation.restart();
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Kirigami.Theme.alternateBackgroundColor
        radius: 8
        border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
        border.width: 1
        clip: true

        Row {
            id: scrollRow
            height: parent.height
            spacing: Math.round(20 * tickerCard.scaleFactor)
            anchors.verticalCenter: parent.verticalCenter

            onImplicitWidthChanged: {
                if (tickerCard.visible && implicitWidth > 0 && tickerCard.width > 100) {
                    debounceTimer.restart();
                }
            }

            Component.onCompleted: {
                if (tickerCard.visible && implicitWidth > 0 && tickerCard.width > 100) {
                    debounceTimer.restart();
                }
            }

            Repeater {
                model: tickerCard.coinsData && tickerCard.coinsData.length > 0 ? tickerCard.coinsData : 0
                delegate: Item {
                    id: marketItem
                    required property var modelData
                    required property int index

                    width: marketRow.implicitWidth
                    height: scrollRow.height

                    Row {
                        id: marketRow
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

                        PlasmaComponents.Label {
                            text: "#" + (marketItem.index + 1)
                            anchors.verticalCenter: parent.verticalCenter
                            font {
                                pointSize: 8.5 * tickerCard.scaleFactor
                            }
                            opacity: 0.4
                        }

                        Image {
                            width: Math.round(Kirigami.Units.gridUnit * 0.9 * tickerCard.scaleFactor)
                            height: Math.round(Kirigami.Units.gridUnit * 0.9 * tickerCard.scaleFactor)
                            anchors.verticalCenter: parent.verticalCenter
                            source: marketItem.modelData.image || ""
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                        }

                        PlasmaComponents.Label {
                            text: marketItem.modelData.symbol.toUpperCase()
                            anchors.verticalCenter: parent.verticalCenter
                            font {
                                bold: true
                                pointSize: 8.5 * tickerCard.scaleFactor
                            }
                        }

                        PlasmaComponents.Label {
                            text: tickerCard.formatPrice(marketItem.modelData.price, tickerCard.vsCurrency)
                            anchors.verticalCenter: parent.verticalCenter
                            font {
                                pointSize: 8.5 * tickerCard.scaleFactor
                            }
                        }

                        PlasmaComponents.Label {
                            text: (marketItem.modelData.change >= 0 ? "▲ " : "▼ ") + Math.abs(marketItem.modelData.change).toFixed(1) + "%"
                            anchors.verticalCenter: parent.verticalCenter
                            font {
                                bold: true
                                pointSize: 8 * tickerCard.scaleFactor
                            }
                            color: marketItem.modelData.change >= 0 ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
                        }

                        PlasmaComponents.Label {
                            text: "  |"
                            anchors.verticalCenter: parent.verticalCenter
                            font {
                                pointSize: 9 * tickerCard.scaleFactor
                            }
                            opacity: 0.25
                        }
                    }
                }
            }

            Repeater {
                model: (!tickerCard.coinsData || tickerCard.coinsData.length === 0) ? tickerCard.backupArray : 0
                delegate: Item {
                    id: backupItem
                    required property string modelData

                    width: backupRow.implicitWidth
                    height: scrollRow.height

                    readonly property string coinId: backupItem.modelData.trim()

                    Row {
                        id: backupRow
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

                        PlasmaComponents.Label {
                            text: backupItem.coinId.toUpperCase()
                            anchors.verticalCenter: parent.verticalCenter
                            font {
                                bold: true
                                pointSize: 8.5 * tickerCard.scaleFactor
                            }
                        }

                        PlasmaComponents.Label {
                            text: "..."
                            anchors.verticalCenter: parent.verticalCenter
                            font {
                                pointSize: 8.5 * tickerCard.scaleFactor
                            }
                        }

                        PlasmaComponents.Label {
                            text: "  |"
                            anchors.verticalCenter: parent.verticalCenter
                            font {
                                pointSize: 9 * tickerCard.scaleFactor
                            }
                            opacity: 0.25
                        }
                    }
                }
            }
        }
    }

    NumberAnimation {
        id: scrollAnimation
        target: scrollRow
        property: "x"
        loops: Animation.Infinite
        running: tickerCard.visible && scrollRow.implicitWidth > tickerCard.width
    }
}
