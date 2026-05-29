import QtQuick
import App

// Сегментный переключатель режима: Прокси / TUN, с плавно скользящим «бегунком».
Item {
    id: root
    implicitWidth: 190
    implicitHeight: 34

    readonly property bool tun: backend.mode === "tun"

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Theme.surface
        border.width: 1
        border.color: Theme.stroke

        // бегунок
        Rectangle {
            id: thumb
            width: parent.width / 2 - 3
            height: parent.height - 6
            radius: height / 2
            y: 3
            x: root.tun ? parent.width / 2 : 3
            color: Theme.accent
            Behavior on x { NumberAnimation { duration: Theme.durBase; easing.type: Easing.OutCubic } }
        }

        Row {
            anchors.fill: parent
            Repeater {
                model: [
                    { k: "proxy", t: "Прокси" },
                    { k: "tun", t: "TUN" }
                ]
                delegate: Item {
                    id: seg
                    required property int index
                    required property var modelData
                    width: parent.width / 2
                    height: parent.height
                    Text {
                        anchors.centerIn: parent
                        text: seg.modelData.t
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        font.letterSpacing: 0.3
                        color: (backend.mode === seg.modelData.k) ? "white" : Theme.textSub
                        Behavior on color { ColorAnimation { duration: Theme.durBase } }
                    }
                    TapHandler { onTapped: backend.setMode(seg.modelData.k) }
                    HoverHandler { cursorShape: Qt.PointingHandCursor }
                }
            }
        }
    }
}
