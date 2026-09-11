// SessionMenu.qml — menu de sessão/power decidido no doc 07: módulo do Quickshell, substitui
// o `wlogout` (config antiga, binário separado + CSS próprio) — uma fonte de cor a menos pra
// manter sincronizada com o colors.yaml.
//
// Aberto via IPC (`qs ipc call sessionmenu toggle`), chamado pelo bind $mainMod, M no
// hyprland.conf.tmpl (que antes fazia `exit` direto — agora abre este menu, que tem "sair"
// como uma das opções, em vez de matar a sessão sem confirmação).
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io

PanelWindow {
    id: sessionMenu
    visible: SessionMenuState.visible
    exclusiveZone: 0
    color: "transparent"

    // Overlay coberindo a tela toda (WlrLayershell full — mesmo espírito de um wlogout
    // tradicional), com o cartão de opções centralizado.
    anchors { top: true; bottom: true; left: true; right: true }

    IpcHandler {
        target: "sessionmenu"
        // TODO(validar no Arch real): mesma ressalva do Launcher.qml sobre a assinatura exata
        // aceita pelo IpcHandler nesta versão do Quickshell.
        function toggle(): void { SessionMenuState.toggle() }
    }

    HyprlandFocusGrab {
        active: SessionMenuState.visible
        onCleared: SessionMenuState.close()
    }

    // Fundo escurecido — clicar fora fecha o menu.
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.35)
        MouseArea { anchors.fill: parent; onClicked: SessionMenuState.close() }
    }

    Rectangle {
        anchors.centerIn: parent
        width: 380
        height: 96
        radius: 14
        color: Colors.bgAlt
        border.width: 1
        border.color: Colors.borderInactive

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            SessionMenuButton {
                iconGlyph: "󰌾"
                label: "Bloquear"
                onClicked: { runCmd("hyprlock"); SessionMenuState.close() }
            }
            SessionMenuButton {
                iconGlyph: "󰗽"
                label: "Sair"
                // Sai da sessão Hyprland de verdade — o antigo bind direto de $mainMod, M.
                onClicked: { Hyprland.dispatch("exit"); SessionMenuState.close() }
            }
            SessionMenuButton {
                iconGlyph: "󰤄"
                label: "Suspender"
                onClicked: { runCmd("systemctl suspend"); SessionMenuState.close() }
            }
            SessionMenuButton {
                iconGlyph: "󰜉"
                label: "Reiniciar"
                onClicked: { runCmd("systemctl reboot"); SessionMenuState.close() }
            }
            SessionMenuButton {
                iconGlyph: "󰐥"
                label: "Desligar"
                onClicked: { runCmd("systemctl poweroff"); SessionMenuState.close() }
            }
        }
    }

    function runCmd(cmd) {
        cmdProc.command = ["sh", "-c", cmd]
        cmdProc.running = true
    }

    Process { id: cmdProc }

    component SessionMenuButton: ColumnLayout {
        id: btn
        property string iconGlyph: ""
        property string label: ""
        signal clicked()

        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 4

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 10
            color: hover.containsMouse ? Colors.accentDim : Colors.bg
            border.width: 1
            border.color: Colors.borderInactive

            Behavior on color { ColorAnimation { duration: 120 } }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 4
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: btn.iconGlyph
                    color: Colors.fg
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 20
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: btn.label
                    color: Colors.fgMuted
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 10
                }
            }

            MouseArea {
                id: hover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: btn.clicked()
            }
        }
    }
}
