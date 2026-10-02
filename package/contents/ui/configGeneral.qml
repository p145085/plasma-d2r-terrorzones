import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_notifyOnAnnounce: notifyOnAnnounce.checked
    property alias cfg_reminderMinutes: reminderMinutes.value
    property alias cfg_notifyOnStart: notifyOnStart.checked
    property alias cfg_showCountdownInPanel: showCountdown.checked
    property alias cfg_refreshMinutes: refreshMinutes.value

    Kirigami.FormLayout {
        QQC2.CheckBox {
            id: notifyOnAnnounce
            Kirigami.FormData.label: i18n("Notify for watched zones:")
            text: i18n("When announced as the next zone")
        }
        RowLayout {
            QQC2.SpinBox {
                id: reminderMinutes
                from: 0
                to: 29
            }
            QQC2.Label {
                text: reminderMinutes.value === 0
                    ? i18n("no reminder before start")
                    : i18np("minute before it starts", "minutes before it starts", reminderMinutes.value)
            }
        }
        QQC2.CheckBox {
            id: notifyOnStart
            text: i18n("When it becomes terrorized")
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.CheckBox {
            id: showCountdown
            Kirigami.FormData.label: i18n("Panel:")
            text: i18n("Show countdown next to icon")
        }
        QQC2.SpinBox {
            id: refreshMinutes
            Kirigami.FormData.label: i18n("Refresh every (minutes):")
            from: 1
            to: 60
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.Label {
            Layout.maximumWidth: Kirigami.Units.gridUnit * 22
            wrapMode: Text.WordWrap
            opacity: 0.7
            text: i18n("Choose which zones to watch from the widget's Watch List tab, or star the current/next zone.")
        }
    }
}
