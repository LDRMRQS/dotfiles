// NetworkTab.qml — aba "Rede" do Dashboard. Usa `nmcli` (NetworkManager, já no doc 02),
// sem dependência nova. Lista redes Wi-Fi visíveis; clicar conecta (sem senha por ora —
// TODO: campo de senha pra redes protegidas, próxima rodada).
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import ".."

ColumnLayout {
    anchors.fill: parent
    spacing: 8

    ListModel { id: networksModel }

    Process {
        id: scan
        command: ["nmcli", "-t", "-f", "SSID,SIGNAL,SECURITY,IN-USE", "dev", "wifi", "list"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                const parts = line.split(":")
                if (parts.length < 4 || parts[0] === "") return
                networksModel.append({
                    ssid: parts[0],
                    signal: parseInt(parts[1]) || 0,
                    secured: parts[2] !== "--" && parts[2] !== "",
                    inUse: parts[3] === "*"
                })
            }
        }
    }

    Text {
        text: "Redes Wi-Fi"
        color: Colors.fgMuted
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 11
    }

    ListView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        model: networksModel
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
                    text: secured ? "󰤪" : "󰤨"
                    color: inUse ? Colors.accent : Colors.fgMuted
                    font.family: "JetBrainsMono Nerd Font"
                }
                Text {
                    Layout.fillWidth: true
                    text: ssid
                    color: Colors.fg
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                    elide: Text.ElideRight
                }
                Text {
                    text: signal + "%"
                    color: Colors.fgMuted
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                }
            }

            MouseArea {
                id: hover
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    connectProc.command = ["nmcli", "dev", "wifi", "connect", ssid]
                    connectProc.running = true
                }
            }
        }
    }

    Process { id: connectProc } // TODO: tratar rede protegida (pedir senha antes de conectar)
}
