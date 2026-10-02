import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import "Zones.js" as Zones

Rectangle {
    id: card

    property string label
    property string zone
    property string placeholder: i18n("Unknown")
    property string countdownText
    property color accent

    readonly property bool watched: root.isWatched(zone)

    implicitHeight: content.implicitHeight + Kirigami.Units.largeSpacing * 2
    radius: Kirigami.Units.cornerRadius
    color: Qt.alpha(Kirigami.Theme.textColor, 0.05)
    border.width: watched ? 2 : 1
    border.color: watched ? Kirigami.Theme.positiveTextColor : Qt.alpha(Kirigami.Theme.textColor, 0.12)

    Rectangle {
        width: 4
        radius: 2
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: Kirigami.Units.smallSpacing
        color: card.accent
    }

    RowLayout {
        id: content
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        anchors.leftMargin: Kirigami.Units.largeSpacing * 1.5
        spacing: Kirigami.Units.smallSpacing

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing / 2

            PlasmaComponents.Label {
                text: {
                    var act = Zones.actOf(card.zone)
                    return act ? card.label + " · " + act : card.label
                }
                font: Kirigami.Theme.smallFont
                color: card.accent
                Layout.fillWidth: true
            }
            Kirigami.Heading {
                level: 3
                text: card.zone || card.placeholder
                opacity: card.zone ? 1 : 0.6
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
            PlasmaComponents.Label {
                visible: card.zone !== ""
                text: card.countdownText
                font.features: { "tnum": 1 }
                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.15
                Layout.fillWidth: true
            }
        }

        PlasmaComponents.ToolButton {
            visible: card.zone !== ""
            Layout.alignment: Qt.AlignTop
            icon.name: card.watched ? "starred-symbolic" : "non-starred-symbolic"
            icon.color: card.watched ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.textColor
            onClicked: root.setWatched(card.zone, !card.watched)
            PlasmaComponents.ToolTip {
                text: card.watched ? i18n("Stop notifying about this zone") : i18n("Notify me about this zone")
            }
        }
    }
}
