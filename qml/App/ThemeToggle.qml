import QtQuick
import App

// Переключатель темы: солнце плавно перетекает в полумесяц.
// День: жёлтое солнце с лучами на голубом небе. Ночь: бледный полумесяц + звёзды.
Item {
    id: root
    implicitWidth: 62
    implicitHeight: 30
    readonly property bool dark: Theme.dark

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: root.dark ? "#2A3156" : "#9FD0F5"   // ночь / день
        Behavior on color { ColorAnimation { duration: Theme.durBase } }

        // звёзды (видны ночью)
        Repeater {
            model: 3
            delegate: Rectangle {
                required property int index
                width: 2.5; height: 2.5; radius: 1.25
                color: "white"
                opacity: root.dark ? 0.9 : 0
                Behavior on opacity { NumberAnimation { duration: Theme.durBase } }
                x: [13, 19, 15][index]
                y: [9, 17, 22][index]
            }
        }
    }

    // бегунок
    Item {
        id: thumb
        width: 24; height: 24
        y: 3
        x: root.dark ? root.width - width - 3 : 3
        Behavior on x { NumberAnimation { duration: Theme.durBase; easing.type: Easing.OutBack } }

        // лучи солнца (за телом)
        Item {
            anchors.fill: parent
            opacity: root.dark ? 0 : 1
            scale: root.dark ? 0.3 : 1
            Behavior on opacity { NumberAnimation { duration: Theme.durBase } }
            Behavior on scale { NumberAnimation { duration: Theme.durBase; easing.type: Easing.OutBack } }
            Repeater {
                model: 8
                delegate: Item {
                    required property int index
                    anchors.centerIn: parent
                    width: 24; height: 24
                    rotation: index * 45
                    Rectangle {
                        width: 2.5; height: 4; radius: 1.25
                        color: "#FFD15C"
                        x: parent.width / 2 - width / 2
                        y: -4.5
                    }
                }
            }
        }

        // тело (солнце / луна)
        Rectangle {
            id: body
            anchors.fill: parent
            radius: width / 2
            color: root.dark ? "#E6EAF5" : "#FFD15C"
            Behavior on color { ColorAnimation { duration: Theme.durBase } }
        }

        // «прикус» — кружок цвета неба, наезжает ночью и вырезает полумесяц
        Rectangle {
            id: bite
            width: 24; height: 24; radius: 12
            color: track.color
            x: root.dark ? 8 : 24
            y: root.dark ? -7 : -24
            opacity: root.dark ? 1 : 0
            Behavior on x { NumberAnimation { duration: Theme.durBase; easing.type: Easing.OutCubic } }
            Behavior on y { NumberAnimation { duration: Theme.durBase; easing.type: Easing.OutCubic } }
            Behavior on opacity { NumberAnimation { duration: Theme.durFast } }
        }
    }

    TapHandler { onTapped: Theme.scheme = (Theme.dark ? "light" : "dark") }
    HoverHandler { cursorShape: Qt.PointingHandCursor }
}
