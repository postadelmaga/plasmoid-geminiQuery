import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

Item {
    id: configGeneral
    
    property alias cfg_apiKey: apiKeyField.text
    property alias cfg_widgetTitle: widgetTitleField.text
    property alias cfg_geminiModel: geminiModelValue.text
    
    Kirigami.FormLayout {
        anchors.fill: parent

        // --- Sezione Aspetto ---
        Item {
            Kirigami.FormData.label: i18n("Appearance")
            Kirigami.FormData.isSection: true
        }

        QQC2.TextField {
            id: widgetTitleField
            Kirigami.FormData.label: i18n("Widget Title:")
            Layout.fillWidth: true
            placeholderText: i18n("Enter a custom title (e.g. Daily Quote)")
        }

        // --- Sezione API e Modello ---
        Item {
            Kirigami.FormData.label: i18n("API & Model")
            Kirigami.FormData.isSection: true
        }
        
        RowLayout {
             Kirigami.FormData.label: i18n("Gemini API Key:")
            Layout.fillWidth: true
            
            QQC2.TextField {
                id: apiKeyField
                Layout.fillWidth: true
                placeholderText: i18n("Enter your Google Gemini API Key")
                echoMode: showApiKey.checked ? TextInput.Normal : TextInput.Password
            }
            
            QQC2.CheckBox {
                id: showApiKey
                text: i18n("Show")
            }
        }

        QQC2.Label {
            Layout.fillWidth: true
            text: i18n("Get a free API Key at: <a href='%1'>Google AI Studio</a>", "https://aistudio.google.com/app/apikey")
            textFormat: Text.RichText
            wrapMode: Text.WordWrap
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            onLinkActivated: (link) => Qt.openUrlExternally(link)
            
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
            }
        }

        QQC2.ComboBox {
            id: geminiModelComboBox
            Kirigami.FormData.label: i18n("Gemini Model:")
            Layout.fillWidth: true
            model: [
                "gemini-3-pro-preview",
                "gemini-3-flash-preview",
                "gemini-2.5-flash",
                "gemini-2.5-flash-lite",
                "gemini-2.5-pro"
            ]
            
            onActivated: geminiModelValue.text = currentText
            
            Component.onCompleted: {
                let index = find(geminiModelValue.text)
                if (index !== -1) {
                    currentIndex = index
                }
            }
            
            QQC2.TextField {
                id: geminiModelValue
                visible: false
                onTextChanged: {
                    let index = geminiModelComboBox.find(text)
                    if (index !== -1) {
                        geminiModelComboBox.currentIndex = index
                    }
                }
            }
        }
    }
}
