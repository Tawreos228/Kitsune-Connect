import QtQuick
import App

// Ряд выбираемых «чипов» (один активный). Используется для протокола / метода / транспорта.
Flow {
    id: root
    property var options: []
    property string current: ""
    signal picked(string value)
    spacing: 8

    Repeater {
        model: root.options
        delegate: Rectangle {
            id: chip
            required property var modelData
            readonly property bool sel: root.current === modelData
            width: t.width + 24
            height: 30
            radius: 15
            color: chip.sel ? Theme.accent : Theme.surfaceAlt
            border.width: 1
            border.color: chip.sel ? Theme.accent : Theme.stroke
            Behavior on color { ColorAnimation { duration: Theme.durFast } }
            Text {
                id: t
                anchors.centerIn: parent
                text: chip.modelData
                color: chip.sel ? "white" : Theme.textSub
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.weight: Font.Medium
            }
            TapHandler { onTapped: root.picked(chip.modelData) }
            HoverHandler { cursorShape: Qt.PointingHandCursor }
        }
    }
}
