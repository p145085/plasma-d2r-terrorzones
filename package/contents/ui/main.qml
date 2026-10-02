import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.notification
import "Zones.js" as Zones

PlasmoidItem {
    id: root

    readonly property string apiUrl: "https://d2runewizard.com/api/trackers/terror-zone"
    readonly property string siteUrl: "https://d2runewizard.com/terror-zone-tracker"
    readonly property string iconPath: Qt.resolvedUrl("../icons/terror.svg").toString().replace("file://", "")
    readonly property int hourMs: 3600000

    property string currentZone: ""
    property string nextZone: ""
    property string errorMsg: ""
    property bool loading: false
    property date lastUpdated
    property bool hasData: false

    // Clock, ticked every second. Terror zones rotate at the top of every (UTC) hour.
    property real now: Date.now()
    readonly property int hourIdx: Math.floor(now / hourMs)
    readonly property real msLeft: (hourIdx + 1) * hourMs - now
    readonly property string countdown: Zones.formatCountdown(msLeft)

    // Hour the displayed currentZone belongs to; used to detect rollover.
    property int dataHour: -1
    // After a rollover the API (cached ~60s) may still serve the previous hour.
    property bool awaitingRollover: false
    property string previousZone: ""

    property var notified: ({})

    readonly property var watched: Plasmoid.configuration.watchedZones
    readonly property bool currentWatched: isWatched(currentZone)
    readonly property bool nextWatched: isWatched(nextZone)

    function isWatched(zone) {
        return zone !== "" && watched.indexOf(zone) !== -1
    }

    function setWatched(zone, on) {
        var list = watched.slice()
        var i = list.indexOf(zone)
        if (on && i === -1)
            list.push(zone)
        else if (!on && i !== -1)
            list.splice(i, 1)
        Plasmoid.configuration.watchedZones = list
    }

    function rememberZone(zone) {
        if (!zone || Zones.isKnown(zone))
            return
        var extra = Plasmoid.configuration.extraZones.slice()
        if (extra.indexOf(zone) === -1) {
            extra.push(zone)
            Plasmoid.configuration.extraZones = extra
        }
    }

    function fetchZones() {
        loading = true
        var xhr = new XMLHttpRequest()
        xhr.open("GET", apiUrl + "?t=" + Date.now())
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return
            loading = false
            if (xhr.status !== 200) {
                errorMsg = i18n("d2runewizard returned HTTP %1", xhr.status || "error")
                retryTimer.restart()
                return
            }
            var data
            try {
                data = JSON.parse(xhr.responseText)
            } catch (e) {
                errorMsg = i18n("Could not parse response")
                retryTimer.restart()
                return
            }
            var cur = data.current || (data.currentTerrorZone && data.currentTerrorZone.zone) || ""
            var nxt = data.next || (data.nextTerrorZone && data.nextTerrorZone.zone) || ""

            if (awaitingRollover && cur === previousZone && (now - hourIdx * hourMs) < 10 * 60000) {
                // Still the previous hour's data; keep the optimistic view and try again shortly.
                retryTimer.restart()
                return
            }
            awaitingRollover = false
            errorMsg = ""
            currentZone = cur
            nextZone = nxt
            dataHour = hourIdx
            hasData = true
            lastUpdated = new Date()
            rememberZone(cur)
            rememberZone(nxt)
            checkNotifications()
        }
        xhr.send()
    }

    function handleRollover() {
        previousZone = currentZone
        if (nextZone !== "") {
            currentZone = nextZone
            nextZone = ""
        }
        dataHour = hourIdx
        awaitingRollover = true
        rolloverFetch.restart()
    }

    function notify(key, title, text) {
        if (notified[key])
            return
        notified[key] = true
        var n = notificationComponent.createObject(root, { title: title, text: text })
        n.sendEvent()
    }

    function checkNotifications() {
        if (!hasData)
            return
        var cfg = Plasmoid.configuration
        if (currentWatched && cfg.notifyOnStart)
            notify("start|" + hourIdx + "|" + currentZone,
                   i18n("Terror zone active"),
                   i18n("%1 is terrorized now. Ends in %2.", currentZone, Zones.formatCountdown(msLeft)))
        if (!nextWatched)
            return
        var startHour = hourIdx + 1
        var remMs = cfg.reminderMinutes * 60000
        if (cfg.notifyOnAnnounce) {
            notify("next|" + startHour + "|" + nextZone,
                   i18n("Upcoming terror zone"),
                   i18n("%1 becomes terrorized in %2.", nextZone, Zones.formatCountdown(msLeft)))
            // An announcement inside the reminder window already serves as the reminder.
            if (cfg.reminderMinutes > 0 && msLeft <= remMs)
                notified["remind|" + startHour + "|" + nextZone] = true
        }
        if (cfg.reminderMinutes > 0 && msLeft <= remMs)
            notify("remind|" + startHour + "|" + nextZone,
                   i18n("Terror zone starting soon"),
                   i18n("%1 becomes terrorized in %2.", nextZone, Zones.formatCountdown(msLeft)))
    }

    Component {
        id: notificationComponent
        Notification {
            componentName: "plasma_workspace"
            eventId: "notification"
            iconName: root.iconPath
            urgency: Notification.HighUrgency
            autoDelete: true
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.now = Date.now()
            if (root.hasData && root.dataHour !== -1 && root.hourIdx !== root.dataHour)
                root.handleRollover()
            root.checkNotifications()
        }
    }

    Timer {
        id: refreshTimer
        interval: Math.max(1, Plasmoid.configuration.refreshMinutes) * 60000
        running: true
        repeat: true
        onTriggered: root.fetchZones()
    }

    // Give the API's cache a moment to turn over after the hour changes.
    Timer {
        id: rolloverFetch
        interval: 15000
        onTriggered: root.fetchZones()
    }

    Timer {
        id: retryTimer
        interval: 30000
        onTriggered: root.fetchZones()
    }

    Component.onCompleted: fetchZones()

    Plasmoid.icon: iconPath

    toolTipMainText: i18n("D2R Terror Zones")
    toolTipSubText: hasData
        ? i18n("Now: %1 (ends in %2)\nNext: %3", currentZone, countdown, nextZone || i18n("unknown"))
        : (errorMsg || i18n("Loading…"))

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("Refresh")
            icon.name: "view-refresh"
            onTriggered: root.fetchZones()
        },
        PlasmaCore.Action {
            text: i18n("Open Terror Zone Tracker")
            icon.name: "internet-web-browser"
            onTriggered: Qt.openUrlExternally(root.siteUrl)
        }
    ]

    compactRepresentation: CompactView {}
    fullRepresentation: FullView {}
}
