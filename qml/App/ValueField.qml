import QtQuick
import QtQuick.Controls.Basic
import App

// Редактируемое значение (порт / MTU / DNS / адрес). Стиль — минималистичный,
// рамка подсвечивается в фокусе.
Item {
    id: root
    property alias text: tf.text
    property string placeholder: ""
    property int fieldWidth: 130
    property bool numeric: false
    property int align: TextInput.AlignRight
    signal edited(string value)

    implicitWidth: fieldWidth
    implicitHeight: 32

    Rectangle {
        anchors.fill: parent
        radius: 9
        color: tf.activeFocus ? Theme.surfaceAlt : "transparent"
        border.width: 1
        border.color: tf.activeFocus ? Qt.rgba(0.04, 0.52, 1.0, 0.6)
                     : hover.hovered ? Theme.strokeHi : Theme.stroke
        Behavior on color { ColorAnimation { duration: Theme.durFast } }
        Behavior on border.color { ColorAnimation { duration: Theme.durFast } }

        TextField {
            id: tf
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            placeholderText: root.placeholder
            placeholderTextColor: Theme.textMuted
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: 13
            horizontalAlignment: root.align
            verticalAlignment: TextInput.AlignVCenter
            selectByMouse: true
            background: null
            inputMethodHints: root.numeric ? Qt.ImhDigitsOnly : Qt.ImhNone
            onTextChanged: root.edited(text)
        }

        HoverHandler { id: hover; cursorShape: Qt.IBeamCursor }
    }
}
