// shell.qml — ponto de entrada do Quickshell (equivalente ao "main" da nossa shell).
// Roda com `qs` (Quickshell) lendo este diretório. Referenciado em hyprland.conf.tmpl como
// `exec-once = qs` (já habilitado — ver comentário lá sobre por que chegamos nesse ponto).
//
// Arquitetura (ver doc 07, seção "Quickshell — decisões de arquitetura"):
// - Bar: só top bar, enxuta/semitransparente — sempre visível.
// - Dashboard: painel de dropdown com os módulos "ricos" do Caelestia (mídia, wifi,
//   bluetooth, notificações, agora com agrupamento) — aberto sob demanda a partir da barra.
//   SEM sidebar própria.
// - Launcher: completo (apps + calculadora + wallpaper + tema), aberto via IPC
//   (`qs ipc call launcher toggle`, bind $mainMod, A).
// - SessionMenu: substitui o `wlogout` antigo, aberto via IPC
//   (`qs ipc call sessionmenu toggle`, bind $mainMod, M).
import QtQuick
import Quickshell

ShellRoot {
    // Uma Bar por monitor conectado — hoje é só o painel interno do notebook (tela única,
    // ver doc 02/07), mas Variants sobre Quickshell.screens já deixa pronto pra um segundo
    // monitor no futuro sem precisar reescrever nada aqui.
    Variants {
        model: Quickshell.screens

        Bar {
            required property var modelData
            screen: modelData
        }
    }

    // Painéis únicos, compartilhados entre monitores — cada um controlado pelo seu próprio
    // singleton de estado (DashboardState/LauncherState/SessionMenuState).
    Dashboard { id: dashboard }
    Launcher { id: launcher }
    SessionMenu { id: sessionMenu }
}
