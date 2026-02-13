import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

Item {
    id: configQuery
    
    property alias cfg_question: questionField.text
    property alias cfg_formattingInstructions: formattingInstructionsField.text
    
    Kirigami.FormLayout {
        anchors.fill: parent

        // --- Sezione Domanda ---
        Item {
            Kirigami.FormData.label: i18n("Query Settings")
            Kirigami.FormData.isSection: true
        }
        
        ColumnLayout {
            Kirigami.FormData.label: i18n("Question to ask:")
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing
            
            QQC2.TextArea {
                id: questionField
                Layout.fillWidth: true
                Layout.minimumHeight: Kirigami.Units.gridUnit * 6
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

        ColumnLayout {
            Kirigami.FormData.label: i18n("Formatting Instructions:")
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing
            
            QQC2.TextArea {
                id: formattingInstructionsField
                Layout.fillWidth: true
                Layout.minimumHeight: Kirigami.Units.gridUnit * 4
                placeholderText: i18n("Ex: Respond only with the quote and the author, use a formal tone...")
                wrapMode: TextEdit.Wrap
            }
            
            QQC2.Label {
                Layout.fillWidth: true
                text: i18n("These instructions will be added to your question.")
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                opacity: 0.6
                wrapMode: Text.WordWrap
            }
        }
    }
}
