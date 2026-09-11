// PowerTab.qml — aba "Energia" do Dashboard. Bateria via /sys (sem dependência nova) +
// troca de perfil de energia via `powerprofilesctl` (power-profiles-daemon, já no doc 02).
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import ".."

ColumnLayout {
    anchors.fill: parent
    spacing: 12

    property int batteryPercent: 100
    property string batteryStatus: "Unknown"
    property string activeProfile: "balanced"

    Process {
        id: readBattery
        // BAT0 é o nome mais comum, mas varia por hardware — TODO: descobrir o caminho real
        // (`ls /sys/class/power_supply/`) na primeira instalação e ajustar se for diferente.
        command: ["sh", "-c", "cat /sys/class/power_supply/BAT0/capacity /sys/class/power_supply/BAT0/status"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                if (/^\d+$/.test(line)) batteryPercent = parseInt(line)
                else batteryStatus = line
            }
        }
    }

    Process {
        id: readProfile
        command: ["powerprofilesctl", "get"]
        running: true
        stdout: SplitParser { onRead: line => activeProfile = line.trim() }
    }

    RowLayout {
        Text {
            text: "󰁹"
            color: Colors.accent
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 18
        }
        Text {
            text: batteryPercent + "%  ·  " + batteryStatus
            color: Colors.fg
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
        }
    }

    Text {
        text: "Perfil de energia"
        color: Colors.fgMuted
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 11
    }

    RowLayout {
        spacing: 6
        Repeater {
            model: ["power-saver", "balanced", "performance"]

            Rectangle {
                required property string modelData
                width: profileLabel.width + 16
                height: 26
                radius: 6
                color: activeProfile === modelData ? Colors.accent : Colors.borderInactive

                Text {
                    id: profileLabel
                    anchors.centerIn: parent
                    text: modelData
                    color: activeProfile === modelData ? Colors.bg : Colors.fgMuted
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        activeProfile = modelData
                        setProfile.command = ["powerprofilesctl", "set", modelData]
                        setProfile.running = true
                    }
                }
            }
        }
    }

    Item { Layout.fillHeight: true }

    Process { id: setProfile }
}
