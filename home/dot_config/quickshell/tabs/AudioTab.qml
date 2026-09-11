// AudioTab.qml — aba "Áudio" do Dashboard. Sem dependência nova de UI (nada de
// QtQuick.Controls Slider — evitamos puxar qt6-quickcontrols2 só pra isso): o slider é um
// MouseArea+Rectangle simples, no mesmo espírito "mínimo de dependências" do resto do doc 02.
// Controla via `wpctl` (Wireplumber CLI, já no doc 02) — mesmo binário que os binds de
// volume do hyprland.conf.tmpl já usam, então não é uma ferramenta nova no sistema.
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import ".."

ColumnLayout {
    anchors.fill: parent
    spacing: 12

    property real volume: 0.5 // 0.0–1.0, atualizado pelo Process abaixo
    property bool muted: false

    // Lê o volume atual assim que a aba abre.
    Process {
        id: readVolume
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                // formato típico: "Volume: 0.45 [MUTED]"
                const match = line.match(/Volume:\s*([\d.]+)/)
                if (match) volume = parseFloat(match[1])
                muted = line.indexOf("MUTED") !== -1
            }
        }
    }

    RowLayout {
        Text {
            text: muted ? "󰝟" : "󰕾"
            color: Colors.fg
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 16
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    muted = !muted
                    toggleMute.running = true
                }
            }
        }
        Text {
            text: Math.round(volume * 100) + "%"
            color: Colors.fgMuted
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
        }
    }

    // Slider caseiro — barra de fundo (border_inactive) + preenchimento (accent).
    Rectangle {
        Layout.fillWidth: true
        height: 8
        radius: 4
        color: Colors.borderInactive

        Rectangle {
            width: parent.width * volume
            height: parent.height
            radius: 4
            color: Colors.accent
        }

        MouseArea {
            anchors.fill: parent
            onPressed: mouse => updateVolume(mouse.x)
            onPositionChanged: mouse => { if (pressed) updateVolume(mouse.x) }
        }
    }

    Item { Layout.fillHeight: true } // TODO: lista de dispositivos de saída (sink switcher)

    function updateVolume(x) {
        volume = Math.max(0, Math.min(1, x / width))
        setVolume.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", volume.toFixed(2)]
        setVolume.running = true
    }

    Process { id: setVolume }
    Process { id: toggleMute; command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"] }
}
