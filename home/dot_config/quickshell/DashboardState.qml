// DashboardState.qml — singleton de ESTADO do dashboard (qual aba está aberta, se está
// visível), separado do Dashboard.qml (que é a JANELA/UI de verdade). Separar os dois evita
// o problema de "quem é dono de quem": qualquer arquivo (Bar.qml em qualquer monitor,
// Dashboard.qml) só lê/escreve esse estado, sem precisar segurar referência direto uns
// dos outros — o mesmo padrão de "fonte única" que já usamos pra cor (Colors.qml).
// Não precisa de .tmpl — não referencia nenhuma cor.
pragma Singleton
import QtQuick

QtObject {
    id: root

    // "" = fechado. Outros valores: "network", "bluetooth", "audio", "power", "notifications".
    property string activeTab: ""
    readonly property bool visible: activeTab !== ""

    function toggle(tab) {
        activeTab = (activeTab === tab) ? "" : tab
    }

    function close() {
        activeTab = ""
    }
}
