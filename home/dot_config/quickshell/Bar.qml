// Bar.qml — a top bar, decisão do doc 07 ("Quickshell — decisões de arquitetura"):
// enxuta, fundo semitransparente (identidade visual da config antiga em
// rgba(80,4,23,0.8) + densidade minimalista do Omarchy), SEM sidebar — os módulos "ricos"
// do Caelestia (mídia, wifi, bluetooth, notificações) abrem no Dashboard via clique num
// ícone daqui, em vez de ficar cravados na barra ou ganhar um painel lateral próprio.
//
// Baseado na estrutura de barra do Caelestia (caelestia-dots/shell), mas com o
// background/opacidade reduzidos pro nível de transparência da nossa config antiga em vez
// do chrome padrão dele — ver doc 07 pra decisão completa.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io

PanelWindow {
    id: bar

    required property var screen

    anchors {
        top: true
        left: true
        right: true
    }

    // Altura da janela do painel = altura visual da barra + a margem que deixa ela
    // "flutuando" (não colada na borda da tela), no espírito do gap_out do Hyprland.
    implicitHeight: barHeight + barMargin * 2
    color: "transparent" // a janela em si é invisível — quem desenha é o Rectangle abaixo
    exclusiveZone: barHeight + barMargin * 2 // reserva espaço real (janelas não passam por baixo)

    readonly property int barHeight: 32
    readonly property int barMargin: 6
    readonly property int barRadius: 10 // ecoa o `rounding = 10` do hyprland.conf.tmpl

    // Fundo semitransparente — o "corpo" visível da barra, flutuante dentro da janela do painel.
    Rectangle {
        id: barBody
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: barMargin
        }
        height: barHeight
        radius: barRadius
        color: Colors.barBackground()
        border.width: 1
        border.color: Colors.borderInactive

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 12

            // -- Seção esquerda: workspaces do Hyprland ------------------------------
            RowLayout {
                id: workspacesRow
                Layout.alignment: Qt.AlignVCenter
                spacing: 6

                // Binding real via Quickshell.Hyprland — tela única (doc 02/07), então não
                // filtramos por monitor aqui; se um segundo monitor entrar no futuro, filtrar
                // `Hyprland.workspaces` por `modelData.monitor` vira necessário.
                Repeater {
                    model: Hyprland.workspaces

                    Rectangle {
                        id: wsDot
                        required property var modelData
                        width: modelData.active ? 20 : 8
                        height: 8
                        radius: 4
                        color: modelData.active ? Colors.accent : Colors.borderInactive

                        Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutQuint } }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Hyprland.dispatch("workspace " + wsDot.modelData.id)
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true } // empurra o relógio pro centro

            // -- Seção central: relógio/data -----------------------------------------
            Text {
                id: clockText
                Layout.alignment: Qt.AlignVCenter
                text: Qt.formatDateTime(clockTimer.now, "ddd, dd MMM  hh:mm")
                color: Colors.fg
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13

                property var now: new Date()
                Timer {
                    id: clockTimer
                    interval: 1000
                    running: true
                    repeat: true
                    property var now: new Date()
                    onTriggered: now = new Date()
                }
            }

            Item { Layout.fillWidth: true } // empurra os ícones de status pra direita

            // -- Seção direita: ícones de estado (abrem o Dashboard) -----------------
            // Cada ícone aqui é só indicador — o controle/detalhe fino mora no Dashboard,
            // aberto sob demanda (decisão de densidade do doc 07: nada de sidebar).
            RowLayout {
                Layout.alignment: Qt.AlignVCenter
                spacing: 10

                BarIconButton {
                    iconGlyph: "󰤨" // wifi — placeholder glyph (Nerd Font), trocar pelo ícone real
                    onClicked: DashboardState.toggle("network")
                }
                BarIconButton {
                    iconGlyph: "󰂯" // bluetooth
                    onClicked: DashboardState.toggle("bluetooth")
                }
                BarIconButton {
                    iconGlyph: "󰕾" // volume
                    onClicked: DashboardState.toggle("audio")
                }
                BarIconButton {
                    // Glifo varia por faixa de carga — mesmo dado que a aba "Energia" do
                    // Dashboard lê (/sys/class/power_supply/), aqui só um resumo rápido.
                    iconGlyph: batteryPercent >= 80 ? "󰂅"
                        : batteryPercent >= 50 ? "󰂀"
                        : batteryPercent >= 20 ? "󰁾"
                        : "󰁺"
                    onClicked: DashboardState.toggle("power")

                    property int batteryPercent: 100
                    Process {
                        command: ["sh", "-c", "cat /sys/class/power_supply/BAT0/capacity 2>/dev/null"]
                        running: true
                        stdout: SplitParser {
                            // "batteryPercent" resolve direto contra a propriedade do
                            // BarIconButton que contém este Process (escopo QML, sem "parent").
                            onRead: line => { if (/^\d+$/.test(line)) batteryPercent = parseInt(line) }
                        }
                    }
                }
                BarIconButton {
                    iconGlyph: "󰂚" // notificações
                    onClicked: DashboardState.toggle("notifications")
                }

                // Botão liga/desliga da VM Windows (doc 01/07) — o único módulo
                // genuinamente "funcional" da barra, não só um atalho pro Dashboard.
                // TODO: confirmar o nome real do domain libvirt quando a VM for criada —
                // "win-sharepoint" é só a sugestão de nome usada aqui como placeholder.
                BarIconButton {
                    id: vmButton
                    property bool vmRunning: false
                    iconGlyph: vmRunning ? "󰐥" : "󰐊"

                    Process {
                        id: vmStatus
                        command: ["virsh", "-c", "qemu:///system", "domstate", "win-sharepoint"]
                        running: true
                        stdout: SplitParser {
                            onRead: line => vmButton.vmRunning = line.trim() === "running"
                        }
                    }
                    Process {
                        id: vmToggle
                        onExited: vmStatus.running = true // re-checa o estado após start/shutdown
                    }

                    onClicked: {
                        vmToggle.command = ["virsh", "-c", "qemu:///system",
                            vmRunning ? "shutdown" : "start", "win-sharepoint"]
                        vmToggle.running = true
                    }
                }
            }
        }
    }
}
