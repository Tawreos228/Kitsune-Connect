import QtQuick
import QtQuick.Shapes
import QtQuick.Effects
import App

// Кольцо подключения: градиентная обводка (синий→бирюза→зелёный), мягкое свечение,
// иконка питания + статус внутри. Состояния: disconnected / connecting / connected.
Item {
    id: root
    width: 224
    height: 224

    readonly property string st: backend.status
    readonly property bool on: st === "connected"
    // мягкие тона для тёмной темы (чтобы не бить в глаза)
    readonly property color softOn: Theme.glowOn
    readonly property color softConn: Theme.accent

    // ---- мягкое свечение под кольцом ----
    Rectangle {
        id: glow
        anchors.centerIn: parent
        width: 150
        height: 150
        radius: width / 2
        color: root.on ? Theme.glowOn : Theme.accent
        opacity: root.st === "disconnected" ? 0.0 : (Theme.dark ? 0.18 : 0.28)
        visible: opacity > 0.01
        Behavior on opacity { NumberAnimation { duration: Theme.durSlow; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation { duration: Theme.durBase } }
        layer.enabled: true
        layer.effect: MultiEffect { blurEnabled: true; blur: 1.0; blurMax: 64 }

        SequentialAnimation on scale {
            running: root.on
            loops: Animation.Infinite
            NumberAnimation { from: 1.0; to: 1.14; duration: 1800; easing.type: Easing.InOutSine }
            NumberAnimation { from: 1.14; to: 1.0; duration: 1800; easing.type: Easing.InOutSine }
        }
    }

    // ---- градиентное кольцо ----
    Canvas {
        id: ring
        anchors.fill: parent
        antialiasing: true

        property string s: root.st
        onSChanged: requestPaint()
        property string dd: Theme.scheme
        onDdChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            var cx = width / 2
            var cy = height / 2
            var lw = 13
            var r = width / 2 - lw / 2 - 22

            ctx.lineWidth = lw
            ctx.lineCap = "round"

            if (s === "disconnected") {
                // приглушённое серое кольцо
                ctx.strokeStyle = Theme.ringIdle
                ctx.beginPath()
                ctx.arc(cx, cy, r, 0, 2 * Math.PI)
                ctx.stroke()
            } else {
                // конический градиент: старт сверху
                var grad = ctx.createConicalGradient(cx, cy, -Math.PI / 2)
                grad.addColorStop(0.00, Theme.ringA)
                grad.addColorStop(0.45, Theme.ringB)
                grad.addColorStop(0.75, Theme.ringC)
                grad.addColorStop(1.00, Theme.ringA)
                ctx.strokeStyle = grad
                ctx.beginPath()
                ctx.arc(cx, cy, r, 0, 2 * Math.PI)
                ctx.stroke()
            }
        }
    }

    // ---- вращающийся блик на этапе подключения ----
    Item {
        id: spinner
        anchors.fill: parent
        opacity: root.st === "connecting" ? 1 : 0
        visible: opacity > 0.01
        Behavior on opacity { NumberAnimation { duration: Theme.durBase } }

        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer
            ShapePath {
                strokeColor: Theme.dark ? Qt.rgba(0.62, 0.80, 0.85, 0.85) : "#FFFFFF"
                strokeWidth: 13
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                PathAngleArc {
                    centerX: spinner.width / 2
                    centerY: spinner.height / 2
                    radiusX: spinner.width / 2 - 6.5 - 22
                    radiusY: spinner.height / 2 - 6.5 - 22
                    startAngle: -90
                    sweepAngle: 70
                }
            }
        }
        RotationAnimator on rotation {
            running: root.st === "connecting"
            from: 0; to: 360
            duration: 1000
            loops: Animation.Infinite
        }
    }

    // ---- центр: иконка питания + статус ----
    Column {
        anchors.centerIn: parent
        spacing: 6

        Canvas {
            id: glyph
            width: 46; height: 46
            anchors.horizontalCenter: parent.horizontalCenter
            antialiasing: true
            property color c: root.on ? root.softOn
                            : root.st === "connecting" ? root.softConn
                            : Theme.textMuted
            onCChanged: requestPaint()
            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                var cx = width / 2, cy = height / 2, r = 13
                ctx.lineWidth = 3.4
                ctx.lineCap = "round"
                ctx.strokeStyle = c
                ctx.beginPath()
                ctx.arc(cx, cy + 1, r, (-40) * Math.PI / 180, (220) * Math.PI / 180, false)
                ctx.stroke()
                ctx.beginPath()
                ctx.moveTo(cx, cy - r - 4)
                ctx.lineTo(cx, cy)
                ctx.stroke()
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.on ? T.s("ring.protected")
                : root.st === "connecting" ? T.s("ring.connecting")
                : T.s("ring.disconnected")
            color: root.on ? root.softOn
                 : root.st === "connecting" ? root.softConn
                 : Theme.textMuted
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.weight: Font.DemiBold
            font.letterSpacing: 1.5
            Behavior on color { ColorAnimation { duration: Theme.durBase } }
        }
    }

    // ---- нажатие ----
    scale: ma.pressed ? 0.96 : 1.0
    Behavior on scale { NumberAnimation { duration: Theme.durFast; easing.type: Easing.OutCubic } }

    MouseArea {
        id: ma
        anchors.centerIn: parent
        width: 150
        height: 150
        cursorShape: Qt.PointingHandCursor
        onClicked: backend.toggle()
    }
}
