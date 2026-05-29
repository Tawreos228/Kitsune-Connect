import QtQuick
import App

// Универсальный сегментный селектор (2-4 опции) со скользящим бегунком.
Item {
    id: root
    property var options: []        // ["A", "B", "C"]
    property int currentIndex: 0
    signal selected(int index)

    implicitHeight: 30
    implicitWidth: Math.max(60, options.length * 64)

    readonly property real seg: width / Math.max(1, options.length)

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Theme.surfaceAlt
        border.width: 1
        border.color: Theme.stroke

        Rectangle {
            id: thumb
            width: root.seg - 6
            height: parent.height - 6
            radius: height / 2
            y: 3
            x: 3 + root.currentIndex * root.seg
            color: Theme.accent
            Behavior on x { NumberAnimation { duration: Theme.durBase; easing.type: Easing.OutCubic } }
        }

        Row {
            anchors.fill: parent
            Repeater {
                model: root.options
                delegate: Item {
                    id: seg
                    required property int index
                    required property var modelData
                    width: root.seg
                    height: root.height
                    Text {
                        anchors.centerIn: parent
                        text: seg.modelData
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        color: root.currentIndex === seg.index ? "white" : Theme.textSub
                        Behavior on color { ColorAnimation { duration: Theme.durBase } }
                    }
                    TapHandler { onTapped: { root.currentIndex = seg.index; root.selected(seg.index) } }
                    HoverHandler { cursorShape: Qt.PointingHandCursor }
                }
            }
        }
    }
}
