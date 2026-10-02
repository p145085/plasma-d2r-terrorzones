.pragma library

// Terror zone names exactly as d2runewizard.com reports them, grouped by act.
var acts = [
    { name: "Act I", zones: [
        "Blood Moor and Den of Evil",
        "Cold Plains and The Cave",
        "Burial Grounds, Crypt, and Mausoleum",
        "Stony Field",
        "Tristram",
        "Dark Wood and Underground Passage",
        "Black Marsh and The Hole",
        "The Forgotten Tower",
        "The Pit",
        "Jail and Barracks",
        "Cathedral and Catacombs",
        "Moo Moo Farm"
    ]},
    { name: "Act II", zones: [
        "Lut Gholein Sewers",
        "Rocky Waste and Stony Tomb",
        "Dry Hills and Halls of the Dead",
        "Far Oasis",
        "Lost City, Valley of Snakes, and Claw Viper Temple",
        "Ancient Tunnels",
        "Arcane Sanctuary",
        "Tal Rasha's Tombs and Tal Rasha's Chamber"
    ]},
    { name: "Act III", zones: [
        "Spider Forest and Spider Cavern",
        "Great Marsh",
        "Flayer Jungle and Flayer Dungeon",
        "Kurast Bazaar, Ruined Temple, and Disused Fane",
        "Travincal",
        "Durance of Hate"
    ]},
    { name: "Act IV", zones: [
        "Outer Steppes and Plains of Despair",
        "River of Flame and City of the Damned",
        "The Chaos Sanctuary"
    ]},
    { name: "Act V", zones: [
        "Bloody Foothills, Frigid Highlands, and Abaddon",
        "Glacial Trail and Drifter Cavern",
        "Crystalline Passage and Frozen River",
        "Arreat Plateau and Pit of Acheron",
        "Nihlathak's Temple, Halls of Anguish, Halls of Pain, and Halls of Vaught",
        "Ancient's Way and Icy Cellar",
        "Worldstone Keep, Throne of Destruction, and Worldstone Chamber"
    ]}
];

function isKnown(zone) {
    for (var i = 0; i < acts.length; i++)
        if (acts[i].zones.indexOf(zone) !== -1)
            return true;
    return false;
}

function actOf(zone) {
    for (var i = 0; i < acts.length; i++)
        if (acts[i].zones.indexOf(zone) !== -1)
            return acts[i].name;
    return "";
}

// Flat list model rows: section headers followed by their zones.
function rows(extraZones) {
    var out = [];
    for (var i = 0; i < acts.length; i++) {
        out.push({ header: true, name: acts[i].name });
        for (var j = 0; j < acts[i].zones.length; j++)
            out.push({ header: false, name: acts[i].zones[j] });
    }
    var extra = (extraZones || []).filter(function (z) { return !isKnown(z); });
    if (extra.length) {
        out.push({ header: true, name: "Other" });
        for (var k = 0; k < extra.length; k++)
            out.push({ header: false, name: extra[k] });
    }
    return out;
}

function formatCountdown(ms) {
    if (ms < 0) ms = 0;
    var s = Math.floor(ms / 1000);
    var h = Math.floor(s / 3600);
    var m = Math.floor((s % 3600) / 60);
    var sec = s % 60;
    var mm = (m < 10 ? "0" : "") + m;
    var ss = (sec < 10 ? "0" : "") + sec;
    return h > 0 ? h + ":" + mm + ":" + ss : mm + ":" + ss;
}
