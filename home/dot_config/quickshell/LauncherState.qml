// LauncherState.qml — singleton de estado do Launcher (mesmo padrão de DashboardState.qml:
// separa "o que está aberto/o que foi digitado" da UI de verdade, em Launcher.qml).
pragma Singleton
import QtQuick

QtObject {
    property bool visible: false
    property string query: ""
    // "apps" | "wallpaper" | "theme" — as 3 seções do launcher completo decidido no doc 07
    // (busca+calculadora ficam dentro de "apps"; troca de scheme vira "theme").
    property string section: "apps"

    function open() {
        visible = true
        query = ""
    }

    function close() {
        visible = false
        query = ""
    }

    function toggle() {
        if (visible) close(); else open()
    }
}
