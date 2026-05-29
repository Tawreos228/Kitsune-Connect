import QtQuick
import App

// Поле захвата горячей клавиши: клик -> «Нажмите…» -> ловит модификатор + букву/цифру.
// На время захвата приостанавливаем глобальный хоткей, чтобы он не «съел» нажатие.
Rectangle {
    id: hf
    property bool capturing: false
    implicitWidth: 150
    implicitHeight: 32
    radius: 8
    color: capturing ? Theme.accentSoft : Theme.surfaceAlt
    border.width: 1
    border.color: capturing ? Qt.rgba(0.04, 0.52, 1.0, 0.6) : Theme.stroke
    Behavior on color { ColorAnimation { duration: Theme.durFast } }

    Text {
        anchors.centerIn: parent
        text: hf.capturing ? "Нажмите…" : backend.hotkeyText
        color: hf.capturing ? Theme.accent : Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: 12
        font.weight: Font.Medium
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            hf.capturing = true
            backend.suspendHotkey(true)
            hf.forceActiveFocus()
        }
    }

    onActiveFocusChanged: {
        if (!activeFocus && capturing) {
            capturing = false
            backend.suspendHotkey(false)
        }
    }

    Keys.onPressed: (event) => {
        if (!hf.capturing) return
        event.accepted = true
        var k = event.key
        var isLetter = (k >= Qt.Key_A && k <= Qt.Key_Z)
        var isDigit = (k >= Qt.Key_0 && k <= Qt.Key_9)
        if (!isLetter && !isDigit) return
        if (event.modifiers === Qt.NoModifier) return
        var mods = 0
        var parts = []
        if (event.modifiers & Qt.ControlModifier) { mods |= 2; parts.push("Ctrl") }
        if (event.modifiers & Qt.AltModifier) { mods |= 1; parts.push("Alt") }
        if (event.modifiers & Qt.ShiftModifier) { mods |= 4; parts.push("Shift") }
        if (event.modifiers & Qt.MetaModifier) { mods |= 8; parts.push("Win") }
        parts.push(String.fromCharCode(k))
        backend.setHotkey(parts.join("+"), mods, k)
        hf.capturing = false
        backend.suspendHotkey(false)
    }
}
