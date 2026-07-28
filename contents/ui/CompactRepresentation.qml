pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Item {
    id: compactRoot

    property string summaryStatus: ""

    signal toggleExpand()

    // Адаптивний розрахунок розміру для вертикальних та горизонтальних панелей
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

    readonly property string displayEmoji: {
        var status = compactRoot.summaryStatus || "";
        if (status.indexOf("🐻") !== -1) return "🐻";
        if (status.indexOf("🚀") !== -1) return "🚀";
        if (status.indexOf("🚨") !== -1) return "🚨";
        if (status.indexOf("🟢") !== -1) return "🟢";
        if (status.indexOf("⚡") !== -1) return "⚡";
        if (status.indexOf("😱") !== -1) return "😱";
        if (status.indexOf("🐂") !== -1) return "🐂";
        if (status.indexOf("📉") !== -1) return "📉";
        if (status.indexOf("📈") !== -1) return "📈";
        return "⚖️";
    }

    PlasmaComponents.Label {
        anchors.centerIn: parent
        text: compactRoot.displayEmoji
        font.pixelSize: Math.round(Math.min(compactRoot.width, compactRoot.height) * 0.68)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
