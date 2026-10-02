import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

MouseArea {
    id: compact

    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    readonly property bool showText: Plasmoid.configuration.showCountdownInPanel && !vertical
    readonly property bool highlight: root.currentWatched || root.nextWatched

    Layout.minimumWidth: vertical ? -1 : row.implicitWidth
    Layout.preferredWidth: Layout.minimumWidth

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
    onClicked: mouse => {
        if (mouse.button === Qt.MiddleButton)
            root.fetchZones()
        else
            root.expanded = !root.expanded
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        height: parent.height
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Icon {
            source: root.iconPath
            Layout.preferredHeight: Math.min(compact.height, Kirigami.Units.iconSizes.medium)
            Layout.preferredWidth: Layout.preferredHeight
            Layout.alignment: Qt.AlignVCenter
            opacity: root.hasData ? 1 : 0.5

            // Dot marking that a watched zone is active (filled) or next (ring).
            Rectangle {
                visible: compact.highlight
                width: Math.round(parent.width * 0.4)
                height: width
                radius: width / 2
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                color: root.currentWatched ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.backgroundColor
                border.color: Kirigami.Theme.positiveTextColor
                border.width: 2
            }
        }

        PlasmaComponents.Label {
            visible: compact.showText
            text: root.countdown
            font.features: { "tnum": 1 }
            font.bold: compact.highlight
            color: root.nextWatched ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.textColor
            Layout.alignment: Qt.AlignVCenter
            Layout.rightMargin: Kirigami.Units.smallSpacing
        }
    }
}
