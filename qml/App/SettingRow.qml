import QtQuick
import QtQuick.Layouts
import App

// Строка настройки: иконка + название (+подпись) + контрол справа (слот `control`).
Item {
    id: row
    implicitHeight: 56
    property string glyph: ""
    property string label: ""
    property string sub: ""
    property alias control: holder.data

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 14

        Text {
            Layout.alignment: Qt.AlignVCenter
            text: row.glyph
            font.family: Theme.iconFamily
            font.pixelSize: 18
            color: Theme.textSub
            visible: row.glyph.length > 0
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 1
            Text {
                text: row.label
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: 14
                font.weight: Font.Medium
            }
            Text {
                text: row.sub
                visible: row.sub.length > 0
                color: Theme.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: 11
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
        }

        Item {
            id: holder
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height
        }
    }
}
