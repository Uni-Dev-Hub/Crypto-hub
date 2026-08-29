pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Item {
    id: fngCard

    property var fngData: null
    property real scaleFactor: 1.0

    implicitWidth: Kirigami.Units.gridUnit * 9
    implicitHeight: Kirigami.Units.gridUnit * 5.5

    readonly property int fngValue: fngCard.fngData ? parseInt(fngCard.fngData.value) : 0

    // Перейменовано з fngClassificationUa -> fngClassification (чистий i18n)
    readonly property string fngClassification: {
        if (!fngCard.fngData) return "---";
        const c = fngCard.fngData.value_classification;
        if (c === "Extreme Fear") return i18n("Extreme Fear");
        if (c === "Fear") return i18n("Fear");
        if (c === "Neutral") return i18n("Neutral");
        if (c === "Greed") return i18n("Greed");
        if (c === "Extreme Greed") return i18n("Extreme Greed");
        return c;
    }

    readonly property color fngColor: {
        if (fngCard.fngValue <= 45) return Kirigami.Theme.negativeTextColor;
        if (fngCard.fngValue <= 54) return Kirigami.Theme.neutralTextColor;
        return Kirigami.Theme.positiveTextColor;
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
            anchors.margins: Math.round(Kirigami.Units.gridUnit * 0.5 * fngCard.scaleFactor)
            spacing: Math.round(Kirigami.Units.smallSpacing * fngCard.scaleFactor)

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Rectangle {
                    Layout.preferredWidth: Math.round(8 * fngCard.scaleFactor)
                    Layout.preferredHeight: Math.round(8 * fngCard.scaleFactor)
                    radius: Layout.preferredWidth / 2
                    color: fngCard.fngData ? fngCard.fngColor : Kirigami.Theme.neutralTextColor
                    Layout.alignment: Qt.AlignVCenter
                }

                PlasmaComponents.Label {
                    text: i18n("Fear & Greed Index")
                    font {
                        pointSize: 8.5 * fngCard.scaleFactor
                    }
                    opacity: 0.6
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }

            PlasmaComponents.Label {
                Layout.fillWidth: true
                text: fngCard.fngData ? fngCard.fngValue.toString() : "..."
                font {
                    bold: true
                    pointSize: 14 * fngCard.scaleFactor
                }
                color: fngCard.fngColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                PlasmaComponents.Label {
                    text: fngCard.fngClassification
                    font {
                        pointSize: 7.5 * fngCard.scaleFactor
                        bold: true
                    }
                    opacity: 0.9
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.round(8 * fngCard.scaleFactor)
                    color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.25)
                    radius: 4

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: parent.width * (fngCard.fngValue / 100)
                        color: fngCard.fngColor
                        radius: 4
                        visible: fngCard.fngValue > 0
                    }
                }
            }
        }
    }
}
