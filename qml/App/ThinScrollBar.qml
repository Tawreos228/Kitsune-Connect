import QtQuick
import QtQuick.Controls.Basic
import App

// Тонкий минималистичный скроллбар (macOS-style). Подходит и для vertical, и для horizontal.
// Применяется как `ScrollBar.vertical: ThinScrollBar {}` к любому Flickable/ListView.
ScrollBar {
    id: bar
    policy: ScrollBar.AsNeeded            // показываем только когда есть что скроллить
    minimumSize: 0.08                     // минимальная относительная длина ползунка
    // Жёсткое скрытие, когда контент целиком помещается. policy=AsNeeded в Qt может оставлять
    // ползунок «почти-во-всю-высоту» когда контент равен или чуть меньше видимой области —
    // это выглядит как тонкая полоска во всю высоту. `size` = доля видимого / всего; 1.0 = всё влезло.
    visible: bar.size < 1.0 && bar.size > 0

    readonly property color thumbBase:  Theme.dark ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(0, 0, 0, 0.20)
    readonly property color thumbHover: Theme.dark ? Qt.rgba(1, 1, 1, 0.32) : Qt.rgba(0, 0, 0, 0.36)
    readonly property color thumbPress: Theme.accent

    contentItem: Rectangle {
        implicitWidth:  bar.hovered ? 6 : 3
        implicitHeight: bar.hovered ? 6 : 3
        radius: 3
        color: bar.pressed ? bar.thumbPress
             : bar.hovered ? bar.thumbHover
                           : bar.thumbBase
        Behavior on implicitWidth  { NumberAnimation { duration: Theme.durFast; easing.type: Easing.OutCubic } }
        Behavior on implicitHeight { NumberAnimation { duration: Theme.durFast; easing.type: Easing.OutCubic } }
        Behavior on color          { ColorAnimation  { duration: Theme.durBase } }
    }
    // прозрачный фон-трек — только сам ползунок виден
    background: Item {}
}
