// Launcher.qml — launcher completo decidido no doc 07 (Caelestia completo, não um
// wofi/rofi só-busca): busca de apps + calculadora + wallpaper picker + seção de tema.
// Substitui o `$menu = wofi -n` transitório do hyprland.conf.tmpl — `wofi` continua
// instalado como fallback manual de emergência (doc 02), mas não é mais o bind padrão.
//
// Aberto via IPC (`qs ipc call launcher toggle`), chamado pelo bind $mainMod, A no
// hyprland.conf.tmpl (já atualizado).
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io

PanelWindow {
    id: launcher
    visible: LauncherState.visible
    exclusiveZone: 0
    color: "transparent"

    // Ancorado no topo, alinhado horizontalmente ao centro via margem — um "spotlight"
    // que desce logo abaixo da barra, não um modal cobrindo a tela inteira (mantém a
    // sensação "leve" da barra/dashboard, não introduz um elemento pesado novo).
    anchors { top: true }
    margins.top: 48

    implicitWidth: 480
    implicitHeight: 420

    IpcHandler {
        target: "launcher"
        // TODO(validar no Arch real): confirmar que `function toggle(): void` é a assinatura
        // aceita pelo IpcHandler desta versão do Quickshell — é o padrão mais comum, mas sem
        // rodar de verdade não dá pra garantir. `qs ipc call launcher toggle` é o comando final.
        function toggle(): void { LauncherState.toggle() }
    }

    // Fecha ao perder o foco/clicar fora — comportamento padrão de launcher.
    // TODO(validar no Arch real): `HyprlandFocusGrab` e `Quickshell.env()` (usado mais abaixo,
    // pra resolver o caminho de `~/.config/backgrounds/`) são os nomes mais prováveis dessas
    // APIs no Quickshell.Hyprland/Quickshell core, mas — como o resto do arquivo — não dá pra
    // confirmar sem rodar de verdade.
    HyprlandFocusGrab {
        active: LauncherState.visible
        onCleared: LauncherState.close()
    }

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: Colors.bgAlt
        border.width: 1
        border.color: Colors.borderInactive

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            // -- Campo de busca / calculadora ----------------------------------------
            Rectangle {
                Layout.fillWidth: true
                height: 40
                radius: 8
                color: Colors.bg
                border.width: 1
                border.color: isCalculator ? Colors.accent : Colors.borderInactive

                readonly property bool isCalculator: LauncherState.query.startsWith("=")

                TextInput {
                    id: searchInput
                    anchors.fill: parent
                    anchors.margins: 10
                    color: Colors.fg
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                    focus: LauncherState.visible
                    text: LauncherState.query
                    onTextChanged: LauncherState.query = text

                    Keys.onEscapePressed: LauncherState.close()
                    Keys.onReturnPressed: {
                        if (LauncherState.query.startsWith("=")) return // calculadora não "executa"
                        if (filteredApps.length > 0) launchApp(filteredApps[0])
                    }
                }

                Text {
                    visible: searchInput.text.length === 0
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    text: "Buscar apps, ou \"=\" pra calculadora…"
                    color: Colors.fgMuted
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                }
            }

            // -- Abas: apps / wallpaper / tema ---------------------------------------
            RowLayout {
                spacing: 6
                Repeater {
                    model: [
                        { key: "apps", label: "Apps" },
                        { key: "wallpaper", label: "Wallpaper" },
                        { key: "theme", label: "Tema" }
                    ]
                    Rectangle {
                        required property var modelData
                        implicitWidth: tabLabel.width + 16
                        height: 24
                        radius: 6
                        color: LauncherState.section === modelData.key ? Colors.accent : "transparent"
                        Text {
                            id: tabLabel
                            anchors.centerIn: parent
                            text: modelData.label
                            color: LauncherState.section === modelData.key ? Colors.bg : Colors.fgMuted
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: LauncherState.section = modelData.key
                        }
                    }
                }
            }

            // -- Conteúdo: calculadora tem prioridade sobre a seção ativa ------------
            Text {
                visible: searchInput.parent.isCalculator
                Layout.fillWidth: true
                text: "= " + calculatorResult(LauncherState.query.slice(1))
                color: Colors.accentBright
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 20
                font.bold: true
            }

            Loader {
                visible: !searchInput.parent.isCalculator
                Layout.fillWidth: true
                Layout.fillHeight: true
                sourceComponent: LauncherState.section === "apps" ? appsSection
                    : LauncherState.section === "wallpaper" ? wallpaperSection
                    : themeSection
            }
        }
    }

    readonly property var filteredApps: {
        // TODO(validar no Arch real): `Quickshell.DesktopEntries.applications` é o nome mais
        // provável dessa API pra entradas .desktop — cada item deve expor `.name`/`.execute()`.
        // Se o nome real for outro, é só ajustar essa binding, o resto do Launcher não muda.
        const all = DesktopEntries.applications || []
        const q = LauncherState.query.toLowerCase()
        if (q === "" || q.startsWith("=")) return all
        return all.filter(a => (a.name || "").toLowerCase().includes(q))
    }

    function launchApp(app) {
        app.execute()
        LauncherState.close()
    }

    // Calculadora simples: só dígitos/operadores/parênteses/ponto — nunca eval de texto livre,
    // pra não virar um jeito acidental de rodar JS arbitrário a partir do campo de busca.
    function calculatorResult(expr) {
        if (!/^[\d\s+\-*/().]*$/.test(expr)) return "expressão inválida"
        try {
            return String(Function('"use strict"; return (' + expr + ')')())
        } catch (e) {
            return "…"
        }
    }

    Component {
        id: appsSection
        ListView {
            clip: true
            spacing: 4
            model: launcher.filteredApps
            delegate: Rectangle {
                required property var modelData
                width: ListView.view.width
                height: 32
                radius: 6
                color: hover.containsMouse ? Colors.accentDim : "transparent"
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    text: modelData.name
                    color: Colors.fg
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                }
                MouseArea {
                    id: hover
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: launcher.launchApp(modelData)
                }
            }
        }
    }

    Component {
        id: wallpaperSection
        GridView {
            clip: true
            cellWidth: 140
            cellHeight: 90
            model: ["wpp3.jpg", "wpp1.jpg"] // os 2 wallpapers de desktop candidatos (ver doc 07)

            delegate: Rectangle {
                required property string modelData
                width: 130
                height: 80
                radius: 8
                color: Colors.bg
                border.width: 1
                border.color: Colors.borderInactive

                Image {
                    anchors.fill: parent
                    anchors.margins: 3
                    source: "file://" + Quickshell.env("HOME") + "/.config/backgrounds/" + modelData
                    fillMode: Image.PreserveAspectCrop
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        setWallpaper.command = ["hyprctl", "hyprpaper", "wallpaper",
                            "," + Quickshell.env("HOME") + "/.config/backgrounds/" + modelData]
                        setWallpaper.running = true
                    }
                }
            }
        }
    }

    Component {
        id: themeSection
        ColumnLayout {
            Text {
                Layout.fillWidth: true
                text: "Só existe um scheme por enquanto: o mashup brutalism + NES (ver doc 07)."
                color: Colors.fgMuted
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
                wrapMode: Text.WordWrap
            }
            Text {
                Layout.fillWidth: true
                text: "Troca de scheme fica pra quando decidirmos ter uma segunda paleta — a arquitetura já suporta (bastaria outro colors.yaml + apontar o chezmoi pra ele), só não tem UI aqui ainda."
                color: Colors.fgMuted
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 10
                wrapMode: Text.WordWrap
            }
            Item { Layout.fillHeight: true }
        }
    }

    Process { id: setWallpaper }
}
