import QtQuick
import App

// Круглая иконочная кнопка. spinning -> иконка крутится (для индикации замера пинга).
Item {
    id: root
    property string glyph: ""
    property bool spinning: false
    property int diameter: 44
    signal clicked()

    implicitWidth: diameter
    implicitHeight: diameter

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: tap.pressed ? Theme.surfaceAlt : hover.hovered ? Theme.hover : Theme.surface
        border.width: 1
        border.color: Theme.stroke
        Behavior on color { ColorAnimation { duration: Theme.durFast } }
        scale: tap.pressed ? 0.92 : 1.0
        Behavior on scale { NumberAnimation { duration: Theme.durFast; easing.type: Easing.OutCubic } }

        Text {
            id: ic
            anchors.centerIn: parent
            text: root.glyph
            font.family: Theme.iconFamily
            font.pixelSize: Math.round(root.diameter * 0.42)
            color: root.spinning ? Theme.accent : Theme.textSub
            Behavior on color { ColorAnimation { duration: Theme.durBase } }
            // при замере — мягкая пульсация (как расходящиеся волны)
            SequentialAnimation on scale {
                running: root.spinning
                loops: Animation.Infinite
                NumberAnimation { from: 1.0; to: 1.16; duration: 430; easing.type: Easing.InOutSine }
                NumberAnimation { from: 1.16; to: 1.0; duration: 430; easing.type: Easing.InOutSine }
            }
        }
    }

    HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
    TapHandler { id: tap; onTapped: root.clicked() }
}
