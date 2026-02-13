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
    property alias cfg_openRouterApiKey: openRouterApiKeyField.text
    property alias cfg_openRouterModel: openRouterModelField.text
    property alias cfg_provider: providerValue.text
    property alias cfg_googleSearchEnabled: googleSearchEnabledCheckBox.checked
    
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
        
        // Provider Selection
        QQC2.ComboBox {
            id: providerComboBox
            Kirigami.FormData.label: i18n("Provider:")
            Layout.fillWidth: true
            model: ["Google", "OpenRouter"]
            
            onActivated: {
                if (currentText === "Google") providerValue.text = "google"
                else providerValue.text = "openrouter"
            }
            
            Component.onCompleted: {
                if (providerValue.text === "openrouter") currentIndex = 1
                else currentIndex = 0
            }
        }
        
        QQC2.TextField {
            id: providerValue
            visible: false
            text: "google" // Default
        }
        
        // --- Google Settings ---
        
        RowLayout {
            visible: providerValue.text === "google" 
            Kirigami.FormData.label: i18n("Google API Key:")
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
            visible: providerValue.text === "google" 
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
            visible: providerValue.text === "google" 
            Kirigami.FormData.label: i18n("Google Model:")
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

        QQC2.CheckBox {
            id: googleSearchEnabledCheckBox
            visible: providerValue.text === "google" 
            Kirigami.FormData.label: i18n("Grounding:")
            text: i18n("Enable Google Search")
            Layout.fillWidth: true
            
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: i18n("Allow Google AI to search the web for up-to-date information.")
            QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
        }

        // --- OpenRouter Settings ---

        RowLayout {
            visible: providerValue.text === "openrouter"
            Kirigami.FormData.label: i18n("OpenRouter API Key:")
            Layout.fillWidth: true
            
            QQC2.TextField {
                id: openRouterApiKeyField
                Layout.fillWidth: true
                placeholderText: i18n("Enter your OpenRouter API Key")
                echoMode: showOpenRouterApiKey.checked ? TextInput.Normal : TextInput.Password
            }
            
            QQC2.CheckBox {
                id: showOpenRouterApiKey
                text: i18n("Show")
            }
        }

        QQC2.Label {
            visible: providerValue.text === "openrouter"
            Layout.fillWidth: true
            text: i18n("Get your API Key at: <a href='%1'>OpenRouter Settings</a>", "https://openrouter.ai/settings/keys")
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
            id: openRouterModelComboBox
            visible: providerValue.text === "openrouter"
            Kirigami.FormData.label: i18n("OpenRouter Model:")
            Layout.fillWidth: true
            
            textRole: "text"
            valueRole: "value"
            
            model: [
                { text: "DeepSeek: R1 (free)", value: "deepseek/deepseek-r1:free" },
                { text: "DeepSeek: R1 0528 (free)", value: "deepseek/deepseek-r1-0528:free" },
                { text: "TNG: DeepSeek R1T Chimera (free)", value: "tngtech/deepseek-r1t-chimera:free" },
                { text: "TNG: DeepSeek R1T2 Chimera (free)", value: "tngtech/deepseek-r1t2-chimera:free" },
                { text: "TNG: R1T Chimera (free)", value: "tngtech/r1t-chimera:free" },
                { text: "Arcee AI: Trinity Large Preview (free)", value: "arcee-ai/trinity-large-preview:free" },
                { text: "Arcee AI: Trinity Mini (free)", value: "arcee-ai/trinity-mini:free" },
                { text: "StepFun: Step 3.5 Flash (free)", value: "stepfun/step-3.5-flash:free" },
                { text: "Z.ai: GLM 4.5 Air (free)", value: "z-ai/glm-4.5-air:free" },
                { text: "NVIDIA: Nemotron 3 Nano 30B (free)", value: "nvidia/nemotron-3-nano-30b-a3b:free" },
                { text: "NVIDIA: Nemotron Nano 9B V2 (free)", value: "nvidia/nemotron-nano-9b-v2:free" },
                { text: "Aurora Alpha", value: "openrouter/aurora-alpha" },
                { text: "OpenAI: GPT OSS 120B (free)", value: "openai/gpt-oss-120b:free" },
                { text: "Upstage: Solar Pro 3 (free)", value: "upstage/solar-pro-3:free" },
                { text: "Meta: Llama 3.3 70B Instruct (free)", value: "meta-llama/llama-3.3-70b-instruct:free" },
                { text: "Qwen: Qwen3 Coder 480B (free)", value: "qwen/Qwen3-Coder-480B-A35B-Instruct:free" },
                { text: "Qwen: Qwen3 VL 235B Thinking", value: "qwen/Qwen3-VL-235B-A22B-Thinking" }
            ]
            
            onActivated: openRouterModelField.text = currentValue
            
            Component.onCompleted: {
                // Find index by value
                for(let i=0; i<model.length; i++) {
                    if(model[i].value === openRouterModelField.text) {
                        currentIndex = i
                        return
                    }
                }
                // Fallback: if not found (maybe manual entry from config file), try to add it or just show index 0?
                // For now, if not found, we don't change selection, it might show first item but underlying value is preserved in TextField unless activated.
                // Better: if value not in list, maybe add it dynamically? 
                // Or just assume user wants one of these.
            }
            
            QQC2.TextField {
                id: openRouterModelField
                visible: false
                onTextChanged: {
                    for(let i=0; i<parent.model.length; i++) {
                        if(parent.model[i].value === text) {
                            parent.currentIndex = i
                            return
                        }
                    }
                }
            }
        }
    }
}
