pragma Singleton
import QtQuick

// Тема: dark / light / kitsune. `scheme` — единственный переключатель.
// dark оставлен как производный флаг для совместимости (kitsune — тоже тёмная база).
QtObject {
    property string scheme: "dark"            // "dark" | "light" | "kitsune"
    readonly property bool dark: scheme !== "light"
    readonly property bool kitsune: scheme === "kitsune"

    // --- surfaces ---
    readonly property color bg:         kitsune ? "#1A1220" : dark ? "#15171C" : "#FFFFFF"
    readonly property color sidebar:    kitsune ? "#140E1C" : dark ? "#0F1115" : "#F5F6F8"
    readonly property color surface:    kitsune ? "#241A30" : dark ? "#1D2026" : "#FFFFFF"
    readonly property color surfaceAlt: kitsune ? "#322543" : dark ? "#272B33" : "#EDEFF2"
    readonly property color stroke:     kitsune ? Qt.rgba(1, 1, 1, 0.09) : dark ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.09)
    readonly property color strokeHi:   kitsune ? Qt.rgba(1, 1, 1, 0.18) : dark ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(0, 0, 0, 0.18)
    readonly property color shadow:     kitsune ? Qt.rgba(0, 0, 0, 0.60) : dark ? Qt.rgba(0, 0, 0, 0.55) : Qt.rgba(0, 0, 0, 0.14)
    readonly property color hover:      kitsune ? "#2C2139" : dark ? "#212429" : "#F0F1F4"
    readonly property color ringIdle:   dark ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(0, 0, 0, 0.12)
    readonly property color waveIdle:   dark ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(0, 0, 0, 0.14)

    // --- accents ---
    readonly property color accent:     kitsune ? "#FF7A2F" : "#0A84FF"
    readonly property color accentSoft: kitsune ? Qt.rgba(1.0, 0.48, 0.18, 0.18)
                                       : dark ? Qt.rgba(0.04, 0.52, 1.0, 0.20) : Qt.rgba(0.04, 0.52, 1.0, 0.12)
    readonly property color teal:       kitsune ? "#C77DFF" : dark ? "#2BD4C9" : "#0FB5AE"
    readonly property color green:      kitsune ? "#3DDC97" : dark ? "#30D158" : "#34C759"
    readonly property color amber:      dark ? "#FFD60A" : "#FF9F0A"
    readonly property color red:        dark ? "#FF453A" : "#FF3B30"

    // --- кольцо подключения (стопы градиента + свечение) ---
    readonly property color ringA:      kitsune ? "#FF7A2F" : dark ? "#3473B8" : "#0A84FF"
    readonly property color ringB:      kitsune ? "#FF4D6D" : dark ? "#2A8F8F" : "#1FC7C2"
    readonly property color ringC:      kitsune ? "#9B5CFF" : dark ? "#3473B8" : "#34C759"
    readonly property color glowOn:     kitsune ? "#FF7A2F" : dark ? "#2A8F8F" : "#34C759"

    // --- text ---
    readonly property color text:       kitsune ? Qt.rgba(1, 0.97, 1, 0.96) : dark ? Qt.rgba(1, 1, 1, 0.95) : "#1C1C1E"
    readonly property color textSub:    kitsune ? Qt.rgba(0.95, 0.90, 0.98, 0.62) : dark ? Qt.rgba(0.92, 0.92, 0.96, 0.60) : Qt.rgba(0.235, 0.235, 0.262, 0.62)
    readonly property color textMuted:  kitsune ? Qt.rgba(0.95, 0.90, 0.98, 0.32) : dark ? Qt.rgba(0.92, 0.92, 0.96, 0.30) : Qt.rgba(0.235, 0.235, 0.262, 0.34)

    // --- metrics ---
    readonly property int radius:    13
    readonly property int radiusLg:  20
    readonly property int gap:       12
    readonly property int pad:       28

    // --- type ---
    readonly property string fontFamily: "Segoe UI Variable Display"
    readonly property string iconFamily: "Segoe Fluent Icons"

    // --- motion ---
    readonly property int durFast: 130
    readonly property int durBase: 240
    readonly property int durSlow: 380
}
