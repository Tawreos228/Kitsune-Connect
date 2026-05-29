import QtQuick
import App

// Обычный переключатель в стиле iOS.
Item {
    id: root
    property bool checked: false
    signal toggled(bool value)

    implicitWidth: 46
    implicitHeight: 28

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? Theme.green : Theme.strokeHi
        Behavior on color { ColorAnimation { duration: Theme.durBase } }

        Rectangle {
            width: parent.height - 6
            height: parent.height - 6
            radius: height / 2
            y: 3
            x: root.checked ? parent.width - width - 3 : 3
            color: "white"
            Behavior on x { NumberAnimation { duration: Theme.durBase; easing.type: Easing.OutCubic } }
        }
    }

    TapHandler { onTapped: { root.checked = !root.checked; root.toggled(root.checked) } }
    HoverHandler { cursorShape: Qt.PointingHandCursor }
}
