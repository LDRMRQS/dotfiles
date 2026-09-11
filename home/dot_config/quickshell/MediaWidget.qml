// MediaWidget.qml — controle de mídia (play/pause/próxima/capa), via MPRIS nativo do
// Quickshell (Quickshell.Services.Mpris) — sem dependência nova, é o mesmo protocolo que
// `playerctl` já usa nos binds de multimídia do hyprland.conf.tmpl, só que lido direto pelo
// Quickshell em vez de invocar um binário externo.
// Fica sempre visível no topo do Dashboard (não é uma aba — é contexto útil em qualquer aba
// aberta), decisão implícita do doc 07: os módulos "ricos" do Caelestia vivem no Dashboard.
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris

Rectangle {
    id: root
    Layout.fillWidth: true
    implicitHeight: hasPlayer ? 64 : 0
    visible: hasPlayer
    radius: 10
    color: Colors.bg
    border.width: 1
    border.color: Colors.borderInactive

    readonly property var player: Mpris.players.length > 0 ? Mpris.players[0] : null
    readonly property bool hasPlayer: player !== null

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10
        visible: root.hasPlayer

        // Capa do álbum — se o player não expuser art (nem todos expõem), cai no glifo genérico.
        Rectangle {
            width: 44
            height: 44
            radius: 6
            color: Colors.bgAlt
            Image {
                anchors.fill: parent
                source: root.player ? (root.player.trackArtUrl || "") : ""
                fillMode: Image.PreserveAspectCrop
                visible: source !== ""
            }
            Text {
                anchors.centerIn: parent
                visible: !root.player || !root.player.trackArtUrl
                text: "󰝚"
                color: Colors.fgMuted
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 18
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            Text {
                Layout.fillWidth: true
                text: root.player ? (root.player.trackTitle || "Sem título") : ""
                color: Colors.fg
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                text: root.player ? (root.player.trackArtist || "") : ""
                color: Colors.fgMuted
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 10
                elide: Text.ElideRight
            }
        }

        RowLayout {
            spacing: 4
            BarIconButton {
                iconGlyph: "󰒮"
                onClicked: root.player && root.player.previous()
            }
            BarIconButton {
                iconGlyph: root.player && root.player.playbackState === MprisPlaybackState.Playing ? "󰏤" : "󰐊"
                onClicked: root.player && root.player.togglePlaying()
            }
            BarIconButton {
                iconGlyph: "󰒭"
                onClicked: root.player && root.player.next()
            }
        }
    }
}
