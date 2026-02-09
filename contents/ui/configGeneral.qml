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
    property alias cfg_question: questionField.text
    property alias cfg_cachedResponse: cachedResponseField.text
    property alias cfg_cacheDate: cacheDateField.text
    
    Kirigami.FormLayout {
        anchors.fill: parent

        // Titolo Widget
        QQC2.TextField {
            id: widgetTitleField
            Kirigami.FormData.label: i18n("Widget Title:")
            Layout.fillWidth: true
            placeholderText: i18n("Enter a custom title (e.g. Daily Quote)")
        }

        Item {
            Kirigami.FormData.isSection: false
            height: Kirigami.Units.smallSpacing
        }
        
        // API Key
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

        // Modello Gemini
        QQC2.ComboBox {
            id: geminiModelComboBox
            Kirigami.FormData.label: i18n("Gemini Model:")
            Layout.fillWidth: true
            model: [
                "gemini-3-pro-preview",
                "gemini-3-flash-preview",
                "gemini-2.5-flash",
                "gemini-2.5-flash-lite",
                "gemini-2.5-pro",
                "gemini-2.0-flash-exp",
                "gemini-1.5-flash-latest",
                "gemini-1.5-flash",
                "gemini-1.5-pro-latest",
                "gemini-1.5-pro"
            ]
            
            // Note: I'm using the models suggested by the user and standard ones.
            // Documentation mentions gemini-2.0/2.5/3 but let's stick to the most common/stable ones for now 
            // while allowing the user to see the "code model" as requested.
            
            onActivated: geminiModelValue.text = currentText
            
            Component.onCompleted: {
                let index = find(geminiModelValue.text)
                if (index !== -1) {
                    currentIndex = index
                }
            }
            
            // Hidden text field to bridge Plasma configuration (expects a text property to alias)
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

        Item {
            Kirigami.FormData.isSection: false
            height: Kirigami.Units.smallSpacing
        }
        
        Item {
            Kirigami.FormData.isSection: false
            height: Kirigami.Units.smallSpacing
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
        
        Item {
            Kirigami.FormData.isSection: false
            height: Kirigami.Units.largeSpacing
        }
        
        // Question
        ColumnLayout {
            Kirigami.FormData.label: i18n("Question to ask:")
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing
            
            QQC2.TextArea {
                id: questionField
                Layout.fillWidth: true
                Layout.minimumHeight: Kirigami.Units.gridUnit * 4
                placeholderText: i18n("Ex: What is the motivational quote of the day?")
                wrapMode: TextEdit.Wrap
            }
            
            QQC2.Label {
                Layout.fillWidth: true
                text: i18n("This question will be sent to Gemini once a day")
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                opacity: 0.6
                wrapMode: Text.WordWrap
            }
        }
        
        Item {
            Kirigami.FormData.isSection: false
            height: Kirigami.Units.largeSpacing
        }
        
        // Example questions
        Kirigami.FormData.label: i18n("Example questions:")
        
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing
            
            Repeater {
                model: [
                    i18n("Give me a motivational quote to start the day well"),
                    i18n("What is an interesting fact from today in history?"),
                    i18n("Give me a productivity tip for today"),
                    i18n("Suggest a quick recipe for dinner"),
                    i18n("What is the word of the day with its definition?")
                ]
                
                QQC2.Button {
                    Layout.fillWidth: true
                    text: modelData
                    flat: true
                    icon.name: "edit-copy"
                    
                    onClicked: {
                        questionField.text = modelData
                    }
                    
                    contentItem: RowLayout {
                        Kirigami.Icon {
                            source: "edit-copy"
                            Layout.preferredWidth: Kirigami.Units.iconSizes.small
                            Layout.preferredHeight: Kirigami.Units.iconSizes.small
                        }
                        
                        QQC2.Label {
                            Layout.fillWidth: true
                            text: parent.parent.text
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignLeft
                        }
                    }
                }
            }
        }
        
        Item {
            Kirigami.FormData.isSection: false
            height: Kirigami.Units.largeSpacing
        }
        
        // Gestione cache (nascosta)
        QQC2.TextField {
            id: cachedResponseField
            visible: false
        }
        
        QQC2.TextField {
            id: cacheDateField
            visible: false
        }
        
        // Pulsante per pulire la cache
        RowLayout {
            Layout.fillWidth: true
            
            Item {
                Layout.fillWidth: true
            }
            
            QQC2.Button {
                text: i18n("Clear cache")
                icon.name: "edit-clear"
                onClicked: {
                    cachedResponseField.text = ""
                    cacheDateField.text = ""
                }
            }
        }
    }
}
