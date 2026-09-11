// BluetoothTab.qml — aba "Bluetooth" do Dashboard. Usa `bluetoothctl` (bluez-utils, doc 02).
// Lista dispositivos pareados e permite conectar/desconectar. Descoberta de dispositivo novo
// fica de fora por ora (TODO) — o caso comum é reconectar em algo já pareado (fone, mouse).
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import ".."

ColumnLayout {
    anchors.fill: parent
    spacing: 8

    ListModel { id: devicesModel }

    Process {
        id: listPaired
        command: ["bluetoothctl", "devices", "Paired"]
        running: true
        stdout: SplitParser {
            // formato: "Device AA:BB:CC:DD:EE:FF Nome do Dispositivo"
            onRead: line => {
                const match = line.match(/^Device\s+(\S+)\s+(.+)$/)
                if (!match) return
                devicesModel.append({ mac: match[1], name: match[2], connected: false })
                checkConnected.command = ["bluetoothctl", "info", match[1]]
                checkConnected.running = true
            }
        }
    }

    // Simplificação: TODO trocar por parsing por-dispositivo real (hoje só reflete o último
    // `info` chamado) assim que validarmos o comportamento real do bluetoothctl no Arch.
    Process {
        id: checkConnected
        stdout: SplitParser {
            onRead: line => {
                if (line.indexOf("Connected: yes") !== -1 && devicesModel.count > 0) {
                    devicesModel.setProperty(devicesModel.count - 1, "connected", true)
                }
            }
        }
    }

    Text {
        text: "Dispositivos pareados"
        color: Colors.fgMuted
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 11
    }

    ListView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        model: devicesModel
        clip: true
        spacing: 4

        delegate: Rectangle {
            width: ListView.view.width
            height: 32
            radius: 6
            color: hover.containsMouse ? Colors.accentDim : "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8

                Text {
                    text: "󰂯"
                    color: connected ? Colors.accent : Colors.fgMuted
                    font.family: "JetBrainsMono Nerd Font"
                }
                Text {
                    Layout.fillWidth: true
                    text: name
                    color: Colors.fg
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                    elide: Text.ElideRight
                }
                Text {
                    text: connected ? "conectado" : ""
                    color: Colors.accentDim
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 10
                }
            }

            MouseArea {
                id: hover
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    toggleConn.command = ["bluetoothctl", connected ? "disconnect" : "connect", mac]
                    toggleConn.running = true
                }
            }
        }
    }

    Process { id: toggleConn }
}
