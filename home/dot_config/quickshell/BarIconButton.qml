// BarIconButton.qml — botão de ícone reutilizável (barra e dashboard), glifo de Nerd Font
// (mesma família decidida no doc 07 — JetBrains Mono Nerd Font em tudo, inclusive ícones).
// Hover usa accent_dim (não accent puro) — reserva o vermelho vivo pra estado realmente
// ativo/alerta, mantendo a lógica "vermelho espalhado, mas com intenção" do colors.yaml.
import QtQuick

Item {
    id: root

    signal clicked()

    implicitWidth: 22
    implicitHeight: 22

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: mouseArea.containsMouse ? Colors.accentDim : "transparent"
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    Text {
        anchors.centerIn: parent
        text: root.iconGlyph
        color: mouseArea.containsMouse ? Colors.fg : Colors.fgMuted
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 14
    }

    property string iconGlyph: ""

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
