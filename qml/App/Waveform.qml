import QtQuick
import App

// Живой график активности. Плавность достигается двумя приёмами:
//  1) непрерывная прокрутка по кадрам (60fps) через дробную фазу — без рывков;
//  2) сглаживание значений (низкочастотный фильтр) — линия мягкая, без пилы.
Item {
    id: root
    implicitHeight: 96

    property bool active: backend.status === "connected"

    property var _v: []
    readonly property int _count: 84
    readonly property int _stepMs: 420   // время прокрутки на один шаг (больше = спокойнее)
    property real _phase: 0              // 0..1 внутри одного шага

    Component.onCompleted: {
        var a = []
        for (var i = 0; i < _count; i++) a.push(0)
        _v = a
    }

    Timer {
        interval: 16
        running: true
        repeat: true
        onTriggered: {
            root._phase += interval / root._stepMs
            var a = root._v
            while (root._phase >= 1) {
                root._phase -= 1
                a.shift()
                var prev = a.length > 0 ? a[a.length - 1] : 0
                var raw
                if (root.active) {
                    raw = 0.30 + (Math.random() - 0.5) * 0.14
                    if (Math.random() < 0.08) raw = 0.62 + Math.random() * 0.28  // редкий мягкий всплеск
                } else {
                    raw = prev * 0.55   // плавное затухание в ноль
                }
                a.push(prev * 0.62 + raw * 0.38)  // сглаживание
            }
            root._v = a
            canvas.requestPaint()
        }
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true
        renderStrategy: Canvas.Cooperative
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            var c = Theme.teal
            var a = root._v
            var n = a.length
            if (n < 3) return
            var w = width, h = height
            var mid = h * 0.64
            var amp = h * 0.40
            var step = w / (n - 2)
            var off = root._phase * step   // дробный сдвиг влево

            function px(i) { return i * step - off }
            function py(i) { return mid - a[i] * amp }

            // путь линии (сглаженный по средним точкам)
            ctx.beginPath()
            ctx.moveTo(px(0), py(0))
            for (var i = 1; i < n; i++) {
                var mx = (px(i - 1) + px(i)) / 2
                var my = (py(i - 1) + py(i)) / 2
                ctx.quadraticCurveTo(px(i - 1), py(i - 1), mx, my)
            }

            // заливка под линией
            ctx.lineTo(w, h)
            ctx.lineTo(-off, h)
            ctx.closePath()
            var fill = ctx.createLinearGradient(0, 0, 0, h)
            fill.addColorStop(0.0, Qt.rgba(c.r, c.g, c.b, root.active ? 0.22 : 0.04))
            fill.addColorStop(1.0, Qt.rgba(c.r, c.g, c.b, 0.0))
            ctx.fillStyle = fill
            ctx.fill()

            // линия поверх
            ctx.beginPath()
            ctx.moveTo(px(0), py(0))
            for (var j = 1; j < n; j++) {
                var mx2 = (px(j - 1) + px(j)) / 2
                var my2 = (py(j - 1) + py(j)) / 2
                ctx.quadraticCurveTo(px(j - 1), py(j - 1), mx2, my2)
            }
            ctx.lineWidth = 2.0
            ctx.lineCap = "round"
            ctx.lineJoin = "round"
            ctx.strokeStyle = root.active ? Qt.rgba(c.r, c.g, c.b, 1) : Theme.waveIdle
            ctx.stroke()
        }
    }
}
