// Dashboard.qml — painel secundário aberto sob demanda a partir da barra (decisão do doc 07:
// "só top bar", sem sidebar — tudo que seria sidebar/painel lateral no Caelestia mora aqui
// dentro, num dropdown/dashboard, em vez de ganhar superfície lateral própria).
//
// Conteúdo real de cada aba em tabs/{Network,Bluetooth,Audio,Power,Notifications}Tab.qml —
// carregado por um Loader conforme DashboardState.activeTab. MediaWidget.qml (MPRIS) fica
// sempre visível no topo, independente da aba — contexto útil o tempo todo, não só numa aba
// específica. Todos os pontos do doc 07 "Em aberto" pra essa rodada estão fechados.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: dashboard

    // Só existe/ocupa espaço quando alguma aba está ativa — parado (sem `exclusiveZone`)
    // quando fechado, pra não empurrar janelas do Hyprland à toa.
    visible: DashboardState.visible
    exclusiveZone: 0

    anchors {
        top: true
        right: true
    }

    implicitWidth: 340
    implicitHeight: 400
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        anchors.margins: 8
        radius: 12
        color: Colors.bgAlt
        border.width: 1
        border.color: Colors.borderInactive

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: titleFor(DashboardState.activeTab)
                    color: Colors.fg
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                    font.bold: true
                    Layout.fillWidth: true
                }
                BarIconButton {
                    iconGlyph: "󰅖" // fechar
                    onClicked: DashboardState.close()
                }
            }

            // Sempre visível (independe da aba ativa) — só ocupa espaço quando há player
            // MPRIS de fato tocando algo (ver `hasPlayer` em MediaWidget.qml).
            MediaWidget {}

            // Cada aba é um arquivo próprio em tabs/ — o Loader troca o componente carregado
            // conforme DashboardState.activeTab, sem manter os 5 módulos instanciados o tempo
            // todo (só o ativo existe de fato).
            Loader {
                Layout.fillWidth: true
                Layout.fillHeight: true
                source: sourceFor(DashboardState.activeTab)
            }
        }
    }

    function titleFor(tab) {
        switch (tab) {
            case "network": return "Rede"
            case "bluetooth": return "Bluetooth"
            case "audio": return "Áudio"
            case "power": return "Energia"
            case "notifications": return "Notificações"
            default: return ""
        }
    }

    function sourceFor(tab) {
        switch (tab) {
            case "network": return "tabs/NetworkTab.qml"
            case "bluetooth": return "tabs/BluetoothTab.qml"
            case "audio": return "tabs/AudioTab.qml"
            case "power": return "tabs/PowerTab.qml"
            case "notifications": return "tabs/NotificationsTab.qml"
            default: return ""
        }
    }
}
