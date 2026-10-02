import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import "Zones.js" as Zones

PlasmaExtras.Representation {
    id: full

    Layout.minimumWidth: Kirigami.Units.gridUnit * 20
    Layout.minimumHeight: Kirigami.Units.gridUnit * 18
    Layout.preferredWidth: Kirigami.Units.gridUnit * 24
    Layout.preferredHeight: Kirigami.Units.gridUnit * 28

    collapseMarginsHint: true

    header: PlasmaExtras.PlasmoidHeading {
        contentItem: RowLayout {
            spacing: Kirigami.Units.smallSpacing

            PlasmaComponents.TabBar {
                id: tabs
                Layout.fillWidth: true
                PlasmaComponents.TabButton {
                    text: i18n("Terror Zones")
                }
                PlasmaComponents.TabButton {
                    text: root.watched.length > 0
                        ? i18n("Watch List (%1)", root.watched.length)
                        : i18n("Watch List")
                }
            }

            PlasmaComponents.ToolButton {
                icon.name: "view-refresh"
                enabled: !root.loading
                onClicked: root.fetchZones()
                PlasmaComponents.ToolTip { text: i18n("Refresh") }
            }
            PlasmaComponents.ToolButton {
                icon.name: "internet-web-browser"
                onClicked: Qt.openUrlExternally(root.siteUrl)
                PlasmaComponents.ToolTip { text: i18n("Open d2runewizard.com") }
            }
        }
    }

    StackLayout {
        anchors.fill: parent
        currentIndex: tabs.currentIndex

        // ---- Status tab ----
        ColumnLayout {
            spacing: Kirigami.Units.largeSpacing

            ZoneCard {
                Layout.fillWidth: true
                Layout.topMargin: Kirigami.Units.largeSpacing
                Layout.leftMargin: Kirigami.Units.largeSpacing
                Layout.rightMargin: Kirigami.Units.largeSpacing
                label: i18n("CURRENT")
                zone: root.currentZone
                countdownText: i18n("Ends in %1", root.countdown)
                accent: Kirigami.Theme.negativeTextColor
            }

            ZoneCard {
                Layout.fillWidth: true
                Layout.leftMargin: Kirigami.Units.largeSpacing
                Layout.rightMargin: Kirigami.Units.largeSpacing
                label: i18n("NEXT")
                zone: root.nextZone
                placeholder: root.awaitingRollover ? i18n("Waiting for d2runewizard…") : i18n("Not announced yet")
                countdownText: i18n("Starts in %1", root.countdown)
                accent: Kirigami.Theme.neutralTextColor
            }

            PlasmaComponents.Label {
                Layout.fillWidth: true
                Layout.leftMargin: Kirigami.Units.largeSpacing
                Layout.rightMargin: Kirigami.Units.largeSpacing
                visible: root.watched.length === 0
                wrapMode: Text.WordWrap
                opacity: 0.7
                text: i18n("Star a zone, or pick zones in the Watch List tab, to get notified when they become terrorized.")
            }

            Item { Layout.fillHeight: true }

            PlasmaComponents.Label {
                Layout.fillWidth: true
                Layout.margins: Kirigami.Units.largeSpacing
                horizontalAlignment: Text.AlignHCenter
                font: Kirigami.Theme.smallFont
                wrapMode: Text.WordWrap
                color: root.errorMsg ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.textColor
                opacity: root.errorMsg ? 1 : 0.6
                text: root.errorMsg
                    ? root.errorMsg
                    : root.hasData
                        ? i18n("Data from d2runewizard.com · updated %1", Qt.formatTime(root.lastUpdated, Qt.DefaultLocaleShortDate))
                        : i18n("Loading…")
            }
        }

        // ---- Watch list tab ----
        ColumnLayout {
            spacing: 0

            RowLayout {
                Layout.fillWidth: true
                Layout.margins: Kirigami.Units.smallSpacing
                PlasmaComponents.Label {
                    Layout.fillWidth: true
                    Layout.leftMargin: Kirigami.Units.smallSpacing
                    text: i18n("Notify me about:")
                    elide: Text.ElideRight
                }
                PlasmaComponents.ToolButton {
                    text: i18n("Clear")
                    icon.name: "edit-clear-all"
                    enabled: root.watched.length > 0
                    onClicked: Plasmoid.configuration.watchedZones = []
                }
            }

            PlasmaComponents.ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ListView {
                    id: zoneList
                    clip: true
                    model: Zones.rows(Plasmoid.configuration.extraZones)
                    reuseItems: false

                    delegate: Loader {
                        required property var modelData
                        width: zoneList.width
                        sourceComponent: modelData.header ? headerDelegate : zoneDelegate

                        Component {
                            id: headerDelegate
                            Kirigami.Heading {
                                level: 4
                                text: modelData.name
                                topPadding: Kirigami.Units.largeSpacing
                                leftPadding: Kirigami.Units.largeSpacing
                                bottomPadding: Kirigami.Units.smallSpacing
                                opacity: 0.8
                            }
                        }

                        Component {
                            id: zoneDelegate
                            PlasmaComponents.CheckBox {
                                leftPadding: Kirigami.Units.largeSpacing * 2
                                text: modelData.name
                                checked: root.isWatched(modelData.name)
                                onToggled: root.setWatched(modelData.name, checked)
                                font.bold: modelData.name === root.currentZone || modelData.name === root.nextZone
                                PlasmaComponents.ToolTip {
                                    text: modelData.name === root.currentZone ? i18n("Terrorized now")
                                        : modelData.name === root.nextZone ? i18n("Next up") : ""
                                    visible: text !== "" && parent.hovered
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
