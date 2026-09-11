// NotificationsTab.qml — aba "Notificações" do Dashboard: a central com agrupamento decidida
// no doc 07 (substitui o `swaync` da config antiga). Usa o servidor de notificações nativo do
// Quickshell (Quickshell.Services.Notifications) em vez de rodar um daemon separado — o
// Quickshell passa a ser o próprio "notification daemon" do sistema.
// Agrupamento por app: cada app vira um grupo colapsável (cabeçalho com nome + contador),
// clique expande/recolhe — em vez da lista simples "mais nova em cima" que tínhamos antes.
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications
import ".."

ColumnLayout {
    id: root
    anchors.fill: parent
    spacing: 8

    // appName -> bool. Sobrevive a recálculos de `groups` (que reconstrói a cada notificação
    // nova/removida) porque é um estado separado, indexado por nome — não por posição na lista.
    property var expandedApps: ({})

    // Deriva a lista agrupada a partir do estado bruto do NotificationServer. Recalculado
    // manualmente (em vez de um binding direto) porque `trackedNotifications` é uma lista
    // que muda por inserção/remoção, não por reatribuição — precisa de sinal explícito.
    property var groups: []

    function regroup() {
        const byApp = {}
        const order = []
        for (const n of notifServer.trackedNotifications) {
            const key = n.appName || "Outros"
            if (!byApp[key]) { byApp[key] = []; order.push(key) }
            byApp[key].push(n)
        }
        groups = order.map(key => ({ appName: key, items: byApp[key] }))
    }

    NotificationServer {
        id: notifServer
        // TODO: decidir se o Quickshell assume 100% o papel de notification daemon (precisa
        // desabilitar/desinstalar qualquer outro, ex: dunst/mako, se algum vier de dependência
        // transitiva) ou se convive com um — ver doc 02/07 quando formos instalar de verdade.
        keepOnReload: true
        onNotificationReceived: root.regroup()
    }

    // TODO(validar no Arch real): os nomes exatos dos sinais aqui (`onNotificationReceived`
    // no NotificationServer, `onCountChanged` numa lista de trackedNotifications) são os mais
    // prováveis pela API do Quickshell, mas não dá pra confirmar sem rodar de verdade — se o
    // agrupamento não atualizar sozinho ao chegar/sumir notificação, é o primeiro lugar a olhar.
    Connections {
        target: notifServer.trackedNotifications
        function onCountChanged() { root.regroup() }
    }

    Component.onCompleted: regroup()

    RowLayout {
        Text {
            text: "Notificações"
            color: Colors.fgMuted
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 11
            Layout.fillWidth: true
        }
        Text {
            text: "limpar tudo"
            color: Colors.accentDim
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 10
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    for (const n of notifServer.trackedNotifications) n.dismiss()
                    root.regroup()
                }
            }
        }
    }

    ListView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        spacing: 6
        model: root.groups

        delegate: Column {
            id: groupDelegate
            required property var modelData
            width: ListView.view.width
            spacing: 4

            readonly property bool expanded: !!root.expandedApps[modelData.appName]

            // -- Cabeçalho do grupo (app + contador) — clique expande/recolhe -----------
            Rectangle {
                width: parent.width
                height: 36
                radius: 8
                color: Colors.bg
                border.width: 1
                border.color: Colors.borderInactive

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10

                    Text {
                        text: groupDelegate.expanded ? "󰅀" : "󰅂"
                        color: Colors.fgMuted
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 10
                    }
                    Text {
                        Layout.fillWidth: true
                        text: groupDelegate.modelData.appName
                        color: Colors.accent
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                        font.bold: true
                        elide: Text.ElideRight
                    }
                    Rectangle {
                        visible: groupDelegate.modelData.items.length > 1
                        width: countLabel.width + 12
                        height: 18
                        radius: 9
                        color: Colors.accentDim
                        Text {
                            id: countLabel
                            anchors.centerIn: parent
                            text: groupDelegate.modelData.items.length
                            color: Colors.fg
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 10
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        const apps = Object.assign({}, root.expandedApps)
                        apps[groupDelegate.modelData.appName] = !apps[groupDelegate.modelData.appName]
                        root.expandedApps = apps
                    }
                }
            }

            // -- Notificações individuais (só quando o grupo está expandido) ------------
            Column {
                width: parent.width
                spacing: 4
                visible: groupDelegate.expanded
                Repeater {
                    model: groupDelegate.expanded ? groupDelegate.modelData.items : []

                    delegate: Rectangle {
                        required property var modelData
                        width: groupDelegate.width
                        height: 50
                        radius: 8
                        color: Colors.bgAlt
                        border.width: 1
                        border.color: Colors.borderInactive

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 2

                            RowLayout {
                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.summary
                                    color: Colors.fg
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                }
                                Text {
                                    text: "󰅖"
                                    color: Colors.fgMuted
                                    font.family: "JetBrainsMono Nerd Font"
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: { modelData.dismiss(); root.regroup() }
                                    }
                                }
                            }
                            Text {
                                Layout.fillWidth: true
                                text: modelData.body
                                color: Colors.fgMuted
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 10
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }
    }
}
