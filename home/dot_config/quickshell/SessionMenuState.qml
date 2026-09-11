// SessionMenuState.qml — singleton de estado do menu de sessão/power (mesmo padrão de
// DashboardState.qml e LauncherState.qml). Substitui o `wlogout` da config antiga (decisão
// do doc 07: menu de sessão vira módulo do próprio Quickshell, não um binário separado).
pragma Singleton
import QtQuick

QtObject {
    property bool visible: false

    function open() { visible = true }
    function close() { visible = false }
    function toggle() { visible = !visible }
}
