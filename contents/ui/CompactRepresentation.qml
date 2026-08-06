pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Item {
    id: compactRoot

    property string summaryStatus: ""
    property string rawSummaryStatus: ""

    signal toggleExpand()

    readonly property real sideLength: {
        if (!parent) return Kirigami.Units.iconSizes.medium;
        var pWidth = parent.width > 0 ? parent.width : Kirigami.Units.iconSizes.medium;
        var pHeight = parent.height > 0 ? parent.height : Kirigami.Units.iconSizes.medium;
        return Math.min(pWidth, pHeight);
    }

    Layout.preferredWidth: sideLength
    Layout.preferredHeight: sideLength
    Layout.minimumWidth: Kirigami.Units.iconSizes.small
    Layout.minimumHeight: Kirigami.Units.iconSizes.small

    TapHandler {
        onTapped: compactRoot.toggleExpand()
    }

    readonly property string displaySymbol: {
        var s = (compactRoot.rawSummaryStatus + " " + compactRoot.summaryStatus).toLowerCase();
        if (s.indexOf("panic") !== -1 || s.indexOf("crash") !== -1 || s.indexOf("correction") !== -1 || s.indexOf("fear") !== -1 || s.indexOf("панік") !== -1 || s.indexOf("крах") !== -1 || s.indexOf("корекц") !== -1 || s.indexOf("страх") !== -1) {
            return "!";
        }
        if (s.indexOf("rally") !== -1 || s.indexOf("bull") !== -1 || s.indexOf("ралі") !== -1 || s.indexOf("бич") !== -1) {
            return "▲";
        }
        if (s.indexOf("altseason") !== -1 || s.indexOf("альтсезон") !== -1) {
            return "★";
        }
        return "≈";
    }

    PlasmaComponents.Label {
        anchors.centerIn: parent
        text: compactRoot.displaySymbol
        font.pixelSize: Math.round(Math.min(compactRoot.width, compactRoot.height) * 0.68)
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
