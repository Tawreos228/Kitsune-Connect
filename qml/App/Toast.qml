import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import App

// Аккуратно всплывающее уведомление: мягко съезжает сверху, авто-скрытие,
// цветовой акцент по типу (success / error / info). Никакой агрессии.
Item {
    id: root
    height: 56
    z: 1000

    property bool shown: false
    property string message: ""
    property string kind: "info"   // success | error | info

    readonly property color accentColor: kind === "success" ? Theme.green
                                        : kind === "error" ? Theme.red
                                        : Theme.accent

    function show(msg, k) {
        message = msg
        kind = k || "info"
        shown = true
        hideTimer.restart()
    }

    Timer { id: hideTimer; interval: 3200; onTriggered: root.shown = false }

    // состояние видимости -> opacity + мягкий сдвиг (через transform, чтобы не конфликтовать с anchors)
    opacity: shown ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: Theme.durBase; easing.type: Easing.OutCubic } }
    visible: opacity > 0.01
    transform: Translate {
        y: root.shown ? 0 : 14
        Behavior on y { NumberAnimation { duration: Theme.durBase; easing.type: Easing.OutCubic } }
    }

    Rectangle {
        id: pill
        anchors.fill: parent
        radius: 14
        color: Theme.surface
        border.width: 1
        border.color: Theme.stroke

        // мягкая тень
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Theme.shadow
            shadowBlur: 0.9
            shadowVerticalOffset: 6
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 18
            spacing: 12

            // цветной кружок-индикатор
            Rectangle {
                width: 26; height: 26; radius: 13
                color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.15)
                Text {
                    anchors.centerIn: parent
                    text: root.kind === "success" ? "✓" : root.kind === "error" ? "!" : "i"
                    color: root.accentColor
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    font.weight: Font.Bold
                }
            }

            Text {
                Layout.fillWidth: true
                text: root.message
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: 13
                font.weight: Font.Medium
                elide: Text.ElideRight
            }
        }
    }

    MouseArea { anchors.fill: parent; onClicked: root.shown = false }
}
