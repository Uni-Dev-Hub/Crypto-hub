pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

// qmllint disable unqualified
// qmllint disable missing-property

Kirigami.ScrollablePage {
    id: supportPage
    title: i18n("Support & Info")
    topPadding: 0

    // Оголошення cfg_* властивостей для сумісності з Plasma 6 ConfigModel
    readonly property string cfg_alertsJsonDefault: "{\"alerts\":[]}"
    readonly property int cfg_desktopCardTypeDefault: 0
    readonly property string cfg_favoriteCoinsDefault: ""
    readonly property bool cfg_showAnalysisCardsDefault: true
    readonly property bool cfg_showHalvingDefault: true
    readonly property bool cfg_showMiniCardsDefault: true
    readonly property bool cfg_showSummaryDefault: true
    readonly property bool cfg_showTablesDefault: true
    readonly property bool cfg_showTickerDefault: true
    readonly property int cfg_updateIntervalDefault: 5
    readonly property string cfg_vsCurrencyDefault: "usd"

    property string cfg_alertsJson: "{\"alerts\":[]}"
    property int cfg_desktopCardType: 0
    property string cfg_favoriteCoins: ""
    property bool cfg_showAnalysisCards: true
    property bool cfg_showHalving: true
    property bool cfg_showMiniCards: true
    property bool cfg_showSummary: true
    property bool cfg_showTables: true
    property bool cfg_showTicker: true
    property int cfg_updateInterval: 5
    property string cfg_vsCurrency: "usd"

    TextEdit {
        id: clipboardHelper
        width: 1
        height: 1
        opacity: 0
        enabled: true
    }

    function copyToClipboard(textToCopy) {
        clipboardHelper.text = textToCopy;
        clipboardHelper.selectAll();
        clipboardHelper.copy();
    }

    property int currentTabIndex: 0

    ColumnLayout {
        id: mainLayout
        width: parent.width
        spacing: Kirigami.Units.mediumSpacing

        // Баннер проєкту
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: bannerCol.implicitHeight + Kirigami.Units.largeSpacing * 2
            color: Kirigami.Theme.alternateBackgroundColor
            radius: 12
            border.color: Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.4)
            border.width: 1

            RowLayout {
                id: bannerCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Kirigami.Units.largeSpacing
                spacing: Kirigami.Units.largeSpacing

                Kirigami.Icon {
                    source: "office-chart-line-percentage"
                    implicitWidth: 44
                    implicitHeight: 44
                    color: Kirigami.Theme.highlightColor
                    Layout.alignment: Qt.AlignTop
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Controls.Label {
                        text: "Crypto-hub v1.0.0"
                        font.bold: true
                        font.pointSize: 12
                    }

                    Controls.Label {
                        text: i18n("The first feature-rich cryptocurrency monitoring widget for KDE Plasma 6.")
                        font.pointSize: 9
                        opacity: 0.85
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }
                }
            }
        }

        Controls.TabBar {
            id: tabBar
            Layout.fillWidth: true
            currentIndex: supportPage.currentTabIndex
            onCurrentIndexChanged: supportPage.currentTabIndex = tabBar.currentIndex

            Controls.TabButton {
                text: i18n("What's New")
            }
            Controls.TabButton {
                text: i18n("About Project")
            }
            Controls.TabButton {
                text: i18n("Authors")
            }
            Controls.TabButton {
                text: i18n("Support")
            }
            Controls.TabButton {
                text: i18n("FAQ")
            }
        }

        // Вкладка 0: Що нового
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.mediumSpacing
            visible: supportPage.currentTabIndex === 0

            Controls.Label {
                text: i18n("Crypto-hub provides real-time crypto market monitoring via 15 desktop card types, auto-refresh, and a local SQLite database for offline coin search. The project is fully open source under the GNU GPLv3 license.")
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                font.pointSize: 9.5
                lineHeight: 1.25
                opacity: 0.95
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: changelogCol.implicitHeight + 24
                color: Kirigami.Theme.alternateBackgroundColor
                radius: 8
                border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.1)
                border.width: 1

                ColumnLayout {
                    id: changelogCol
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    RowLayout {
                        spacing: 6
                        Kirigami.Icon {
                            source: "bookmarks-symbolic"
                            implicitWidth: 18
                            implicitHeight: 18
                            color: Kirigami.Theme.highlightColor
                        }
                        Controls.Label {
                            text: i18n("Key features of version v1.0.0:")
                            font.bold: true
                            font.pointSize: 10
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Kirigami.Theme.textColor
                        opacity: 0.1
                    }

                    Controls.Label {
                        text: i18n("🚀 Official release for KDE Plasma 6 and Qt 6 environment.\n" +
                        "🪙 15 modular desktop widget cards (Price, Market Cap, Halving, ETH/BTC, Rainbow Zone, etc.).\n" +
                        "📊 Market analytics feed with top gainers, losers, and trending coins.\n" +
                        "🔔 Flexible system notification builder for price breakouts, ATH/ATL, and Fear & Greed shifts.\n" +
                        "🗄️ Offline coin cache powered by a local SQLite database.\n" +
                        "🎨 Dynamic market condition status icon on the Plasma panel.")
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                        font.pointSize: 9
                        lineHeight: 1.3
                        opacity: 0.9
                    }
                }
            }
        }

        // Вкладка 1: Про проєкт
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.mediumSpacing
            visible: supportPage.currentTabIndex === 1

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: aboutCol.implicitHeight + 24
                color: Kirigami.Theme.alternateBackgroundColor
                radius: 8
                border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.1)
                border.width: 1

                ColumnLayout {
                    id: aboutCol
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    RowLayout {
                        spacing: 8
                        Kirigami.Icon {
                            source: "applications-system-symbolic"
                            implicitWidth: 20
                            implicitHeight: 20
                            color: Kirigami.Theme.highlightColor
                        }
                        Controls.Label {
                            text: i18n("Universal Development Hub (UniDevHub)")
                            font.bold: true
                            font.pointSize: 10
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Kirigami.Theme.textColor
                        opacity: 0.1
                    }

                    Controls.Label {
                        text: i18n("The UniDevHub project was created by a visually impaired developer from Ukraine to build open-source software products, primarily for Linux and Android.")
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                        font.pointSize: 9
                        lineHeight: 1.3
                        opacity: 0.9
                    }

                    Controls.Label {
                        text: i18n("Project Goals:")
                        font.bold: true
                        font.pointSize: 9.5
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        RowLayout {
                            spacing: 10
                            Kirigami.Icon { source: "edit-find-symbolic"; implicitWidth: 16; implicitHeight: 16; opacity: 0.7 }
                            Controls.Label {
                                text: i18n("1. Create software products missing in daily use.")
                                font.pointSize: 8.5
                                Layout.fillWidth: true
                                wrapMode: Text.Wrap
                            }
                        }
                        RowLayout {
                            spacing: 10
                            Kirigami.Icon { source: "user-group-new-symbolic"; implicitWidth: 16; implicitHeight: 16; opacity: 0.7 }
                            Controls.Label {
                                text: i18n("2. Involve more people in open-source development.")
                                font.pointSize: 8.5
                                Layout.fillWidth: true
                                wrapMode: Text.Wrap
                            }
                        }
                        RowLayout {
                            spacing: 10
                            Kirigami.Icon { source: "security-high-symbolic"; implicitWidth: 16; implicitHeight: 16; opacity: 0.7 }
                            Controls.Label {
                                text: i18n("3. Promote open-source software and digital sovereignty.")
                                font.pointSize: 8.5
                                Layout.fillWidth: true
                                wrapMode: Text.Wrap
                            }
                        }
                        RowLayout {
                            spacing: 10
                            Kirigami.Icon { source: "dialog-messages-symbolic"; implicitWidth: 16; implicitHeight: 16; opacity: 0.7 }
                            Controls.Label {
                                text: i18n("4. Stay connected with community and ensure accessibility for everyone.")
                                font.pointSize: 8.5
                                Layout.fillWidth: true
                                wrapMode: Text.Wrap
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: joinCol.implicitHeight + 20
                color: Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.08)
                radius: 8
                border.color: Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.25)
                border.width: 1

                RowLayout {
                    id: joinCol
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 12

                    Kirigami.Icon {
                        source: "system-run-symbolic"
                        implicitWidth: 24
                        implicitHeight: 24
                        color: Kirigami.Theme.highlightColor
                        Layout.alignment: Qt.AlignVCenter
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Controls.Label {
                            text: i18n("Join the UniDevHub project!")
                            font.bold: true
                            font.pointSize: 9.5
                            color: Kirigami.Theme.textColor
                        }

                        Controls.Label {
                            text: i18n("Whether you are a developer, designer, translator, or user — your ideas and contribution will help make open-source software better and more accessible for everyone.")
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                            font.pointSize: 8.5
                            opacity: 0.85
                            lineHeight: 1.25
                        }
                    }
                }
            }
        }

        // Вкладка 2: Автори
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.mediumSpacing
            visible: supportPage.currentTabIndex === 2

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: authorCol.implicitHeight + 24
                color: Kirigami.Theme.alternateBackgroundColor
                radius: 8
                border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.1)
                border.width: 1

                ColumnLayout {
                    id: authorCol
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    RowLayout {
                        spacing: 8
                        Kirigami.Icon {
                            source: "user-identity"
                            implicitWidth: 20
                            implicitHeight: 20
                            color: Kirigami.Theme.highlightColor
                        }
                        Controls.Label {
                            text: i18n("Development Team:")
                            font.bold: true
                            font.pointSize: 10
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Kirigami.Theme.textColor
                        opacity: 0.1
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Controls.Label {
                            text: i18n("• Concept & Development:")
                            font.bold: true
                        }
                        Controls.Label {
                            text: "Oleksandr Afanasiev"
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Controls.Label {
                            text: i18n("• Design & Base Localization:")
                            font.bold: true
                        }
                        Controls.Label {
                            text: "Kira Novak"
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            Controls.Button {
                text: i18n("Open project repository on GitHub")
                icon.name: "internet-services"
                Layout.alignment: Qt.AlignHCenter
                onClicked: Qt.openUrlExternally("https://github.com/Uni-Dev-Hub/Crypto-hub")
            }
        }

        // Вкладка 3: Підтримка
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.mediumSpacing
            visible: supportPage.currentTabIndex === 3

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: multiProjCol.implicitHeight + 20
                color: Kirigami.Theme.alternateBackgroundColor
                radius: 8
                border.color: Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.3)
                border.width: 1

                RowLayout {
                    id: multiProjCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 10
                    spacing: 8

                    Kirigami.Icon {
                        source: "help-donate"
                        implicitWidth: 22
                        implicitHeight: 22
                        color: Kirigami.Theme.highlightColor
                        Layout.alignment: Qt.AlignTop
                    }

                    Controls.Label {
                        text: i18n("By supporting us financially, you support not only the development of this widget, but also other open-source projects for the Linux community from our team!")
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                        font.pointSize: 8.5
                        font.bold: true
                        opacity: 0.9
                    }
                }
            }

            Kirigami.FormLayout {
                Layout.fillWidth: true

                Kirigami.Separator {
                    Kirigami.FormData.isSection: true
                    Kirigami.FormData.label: i18n("Community & Development")
                    Layout.fillWidth: true
                }

                RowLayout {
                    Kirigami.FormData.label: i18n("Contact Email:")
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    Controls.TextField {
                        id: contactEmailField
                        text: "unidevhub@gmail.com"
                        readOnly: true
                        Layout.fillWidth: true
                        font.pointSize: 8.5
                    }

                    Controls.Button {
                        icon.name: "edit-copy"
                        text: i18n("Copy")
                        onClicked: supportPage.copyToClipboard(contactEmailField.text)
                    }
                }

                RowLayout {
                    Kirigami.FormData.label: i18n("YouTube channel:")
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    Controls.Label {
                        text: "@LinuxUniverseUa"
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    Controls.Button {
                        text: i18n("Subscribe")
                        icon.name: "video-single-tab"
                        onClicked: Qt.openUrlExternally("https://www.youtube.com/@LinuxUniverseUa")
                    }
                }

                RowLayout {
                    Kirigami.FormData.label: i18n("GitHub team:")
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    Controls.Label {
                        text: i18n("Join us in improving the code")
                        opacity: 0.8
                        Layout.fillWidth: true
                    }

                    Controls.Button {
                        text: i18n("Join")
                        icon.name: "vcs-code"
                        onClicked: Qt.openUrlExternally("https://github.com/Uni-Dev-Hub/Crypto-hub")
                    }
                }
            }

            Kirigami.FormLayout {
                Layout.fillWidth: true

                Kirigami.Separator {
                    Kirigami.FormData.isSection: true
                    Kirigami.FormData.label: i18n("Financial Support (Donations)")
                    Layout.fillWidth: true
                }

                RowLayout {
                    Kirigami.FormData.label: "Binance Pay:"
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    Controls.TextField {
                        id: binancePayField
                        text: "User-ae94e"
                        readOnly: true
                        Layout.fillWidth: true
                        font.pointSize: 8.5
                    }

                    Controls.Button {
                        icon.name: "edit-copy"
                        text: i18n("Copy")
                        onClicked: supportPage.copyToClipboard(binancePayField.text)
                    }
                }

                RowLayout {
                    Kirigami.FormData.label: "USDC (BSC / BEP20):"
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    Controls.TextField {
                        id: usdcField
                        text: "0xe8908a75da74c1ee814d6a693d01e07f4294ecde"
                        readOnly: true
                        Layout.fillWidth: true
                        font.pointSize: 8.5
                    }

                    Controls.Button {
                        icon.name: "edit-copy"
                        text: i18n("Copy")
                        onClicked: supportPage.copyToClipboard(usdcField.text)
                    }
                }

                RowLayout {
                    Kirigami.FormData.label: "Dogecoin (DOGE):"
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    Controls.TextField {
                        id: dogeField
                        text: "DTAVZYESwELqdv9E3h6DtUvKpU1NRSFs5E"
                        readOnly: true
                        Layout.fillWidth: true
                        font.pointSize: 8.5
                    }

                    Controls.Button {
                        icon.name: "edit-copy"
                        text: i18n("Copy")
                        onClicked: supportPage.copyToClipboard(dogeField.text)
                    }
                }

                RowLayout {
                    Kirigami.FormData.label: "Bitcoin (BTC):"
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    Controls.TextField {
                        id: btcField
                        text: "13zpVCf8dDxF8QXVtx9o82Tp2UJxCvxv9W"
                        readOnly: true
                        Layout.fillWidth: true
                        font.pointSize: 8.5
                    }

                    Controls.Button {
                        icon.name: "edit-copy"
                        text: i18n("Copy")
                        onClicked: supportPage.copyToClipboard(btcField.text)
                    }
                }

                RowLayout {
                    Kirigami.FormData.label: "Ethereum (ETH):"
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    Controls.TextField {
                        id: ethField
                        text: "0xe8908a75da74c1ee814d6a693d01e07f4294ecde"
                        readOnly: true
                        Layout.fillWidth: true
                        font.pointSize: 8.5
                    }

                    Controls.Button {
                        icon.name: "edit-copy"
                        text: i18n("Copy")
                        onClicked: supportPage.copyToClipboard(ethField.text)
                    }
                }
            }
        }

        // Вкладка 4: FAQ
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.mediumSpacing
            visible: supportPage.currentTabIndex === 4

            Controls.Label {
                text: i18n("Frequently Asked Questions (FAQ):")
                font.bold: true
                font.pointSize: 10
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                ColumnLayout {
                    id: faq1
                    property bool expanded: false
                    Layout.fillWidth: true

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 38
                        color: faq1.expanded ? Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.12) : Kirigami.Theme.alternateBackgroundColor
                        radius: 6
                        border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.1)
                        border.width: 1

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: faq1.expanded = !faq1.expanded
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12

                            Controls.Label {
                                text: i18n("❓ How to add a new coin to the widget?")
                                font.bold: true
                                Layout.fillWidth: true
                            }

                            Kirigami.Icon {
                                source: faq1.expanded ? "arrow-up" : "arrow-down"
                                implicitWidth: 16
                                implicitHeight: 16
                                opacity: 0.7
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        visible: faq1.expanded
                        implicitHeight: ans1.implicitHeight + 16
                        color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.04)
                        radius: 6

                        Controls.Label {
                            id: ans1
                            anchors.fill: parent
                            anchors.margins: 10
                            text: i18n("Go to the \"Coin List\" tab in settings and use the search bar by name or ticker (btc, eth, sol), or use batch adding separated by dots (btc.eth.sol).")
                            wrapMode: Text.Wrap
                            font.pointSize: 8.5
                            opacity: 0.85
                        }
                    }
                }

                ColumnLayout {
                    id: faq2
                    property bool expanded: false
                    Layout.fillWidth: true

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 38
                        color: faq2.expanded ? Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.12) : Kirigami.Theme.alternateBackgroundColor
                        radius: 6
                        border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.1)
                        border.width: 1

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: faq2.expanded = !faq2.expanded
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12

                            Controls.Label {
                                text: i18n("❓ What does \"Rate limit exceeded\" mean?")
                                font.bold: true
                                Layout.fillWidth: true
                            }

                            Kirigami.Icon {
                                source: faq2.expanded ? "arrow-up" : "arrow-down"
                                implicitWidth: 16
                                implicitHeight: 16
                                opacity: 0.7
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        visible: faq2.expanded
                        implicitHeight: ans2.implicitHeight + 16
                        color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.04)
                        radius: 6

                        Controls.Label {
                            id: ans2
                            anchors.fill: parent
                            anchors.margins: 10
                            text: i18n("The free public CoinGecko API has a request limit per minute. If this limit is exceeded, the widget automatically enables a 60-second protective countdown timer and will resume updating data after it finishes.")
                            wrapMode: Text.Wrap
                            font.pointSize: 8.5
                            opacity: 0.85
                        }
                    }
                }

                ColumnLayout {
                    id: faq3
                    property bool expanded: false
                    Layout.fillWidth: true

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 38
                        color: faq3.expanded ? Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.12) : Kirigami.Theme.alternateBackgroundColor
                        radius: 6
                        border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.1)
                        border.width: 1

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: faq3.expanded = !faq3.expanded
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12

                            Controls.Label {
                                text: i18n("❓ How do system notifications (Alerts) work?")
                                font.bold: true
                                Layout.fillWidth: true
                            }

                            Kirigami.Icon {
                                source: faq3.expanded ? "arrow-up" : "arrow-down"
                                implicitWidth: 16
                                implicitHeight: 16
                                opacity: 0.7
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        visible: faq3.expanded
                        implicitHeight: ans3.implicitHeight + 16
                        color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.04)
                        radius: 6

                        Controls.Label {
                            id: ans3
                            anchors.fill: parent
                            anchors.margins: 10
                            text: i18n("In the \"Alerts\" tab, you can set up triggers for coins reaching specific prices, 24h high/low breakouts, ATH/ATL reach, as well as macro indicators (Fear & Greed index shifts, BTC/ETH dominance, etc.).")
                            wrapMode: Text.Wrap
                            font.pointSize: 8.5
                            opacity: 0.85
                        }
                    }
                }

                ColumnLayout {
                    id: faq4
                    property bool expanded: false
                    Layout.fillWidth: true

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 38
                        color: faq4.expanded ? Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.12) : Kirigami.Theme.alternateBackgroundColor
                        radius: 6
                        border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.1)
                        border.width: 1

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: faq4.expanded = !faq4.expanded
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12

                            Controls.Label {
                                text: i18n("❓ Why does the panel icon emoji change?")
                                font.bold: true
                                Layout.fillWidth: true
                            }

                            Kirigami.Icon {
                                source: faq4.expanded ? "arrow-up" : "arrow-down"
                                implicitWidth: 16
                                implicitHeight: 16
                                opacity: 0.7
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        visible: faq4.expanded
                        implicitHeight: ans4.implicitHeight + 16
                        color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.04)
                        radius: 6

                        Controls.Label {
                            id: ans4
                            anchors.fill: parent
                            anchors.margins: 10
                            text: i18n("The emoji on the Plasma panel reflects the real-time overall state of the crypto market (e.g. 🐻 — panic/correction, 🚀 — rally/growth, ⚖️ — flat/accumulation, ⚡ — altseason).")
                            wrapMode: Text.Wrap
                            font.pointSize: 8.5
                            opacity: 0.85
                        }
                    }
                }

                ColumnLayout {
                    id: faq5
                    property bool expanded: false
                    Layout.fillWidth: true

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 38
                        color: faq5.expanded ? Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.12) : Kirigami.Theme.alternateBackgroundColor
                        radius: 6
                        border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.1)
                        border.width: 1

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: faq5.expanded = !faq5.expanded
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12

                            Controls.Label {
                                text: i18n("❓ How to select an individual card for the desktop?")
                                font.bold: true
                                Layout.fillWidth: true
                            }

                            Kirigami.Icon {
                                source: faq5.expanded ? "arrow-up" : "arrow-down"
                                implicitWidth: 16
                                implicitHeight: 16
                                opacity: 0.7
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        visible: faq5.expanded
                        implicitHeight: ans5.implicitHeight + 16
                        color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.04)
                        radius: 6

                        Controls.Label {
                            id: ans5
                            anchors.fill: parent
                            anchors.margins: 10
                            text: i18n("When placing the widget directly on the desktop (desktop mode), open \"General Settings\" and choose one of the 15 card types (Coin Card, Fear & Greed Index, Global Market Cap, BTC Halving, ETH/BTC, Rainbow Zone, etc.).")
                            wrapMode: Text.Wrap
                            font.pointSize: 8.5
                            opacity: 0.85
                        }
                    }
                }

                ColumnLayout {
                    id: faq6
                    property bool expanded: false
                    Layout.fillWidth: true

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 38
                        color: faq6.expanded ? Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.12) : Kirigami.Theme.alternateBackgroundColor
                        radius: 6
                        border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.1)
                        border.width: 1

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: faq6.expanded = !faq6.expanded
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12

                            Controls.Label {
                                text: i18n("❓ Where does the widget fetch price data from?")
                                font.bold: true
                                Layout.fillWidth: true
                            }

                            Kirigami.Icon {
                                source: faq6.expanded ? "arrow-up" : "arrow-down"
                                implicitWidth: 16
                                implicitHeight: 16
                                opacity: 0.7
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        visible: faq6.expanded
                        implicitHeight: ans6.implicitHeight + 16
                        color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.04)
                        radius: 6

                        Controls.Label {
                            id: ans6
                            anchors.fill: parent
                            anchors.margins: 10
                            text: i18n("The widget receives current price quotes from the CoinGecko API, and the Fear & Greed Index from the Alternative.me API.")
                            wrapMode: Text.Wrap
                            font.pointSize: 8.5
                            opacity: 0.85
                        }
                    }
                }

                ColumnLayout {
                    id: faq7
                    property bool expanded: false
                    Layout.fillWidth: true

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 38
                        color: faq7.expanded ? Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.12) : Kirigami.Theme.alternateBackgroundColor
                        radius: 6
                        border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.1)
                        border.width: 1

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: faq7.expanded = !faq7.expanded
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12

                            Controls.Label {
                                text: i18n("❓ Does the widget work without an internet connection?")
                                font.bold: true
                                Layout.fillWidth: true
                            }

                            Kirigami.Icon {
                                source: faq7.expanded ? "arrow-up" : "arrow-down"
                                implicitWidth: 16
                                implicitHeight: 16
                                opacity: 0.7
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        visible: faq7.expanded
                        implicitHeight: ans7.implicitHeight + 16
                        color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.04)
                        radius: 6

                        Controls.Label {
                            id: ans7
                            anchors.fill: parent
                            anchors.margins: 10
                            text: i18n("Searching and adding coins work offline thanks to a local SQLite database. An active internet connection is required to update real-time prices.")
                            wrapMode: Text.Wrap
                            font.pointSize: 8.5
                            opacity: 0.85
                        }
                    }
                }
            }
        }
    }
}
