import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

Item {
    id: configAdvanced
    
    property alias cfg_cachedResponse: cachedResponseField.text
    property alias cfg_cacheDate: cacheDateField.text
    
    Kirigami.FormLayout {
        anchors.fill: parent

        // --- Sezione Avanzate/Cache ---
        Item {
            Kirigami.FormData.label: i18n("Maintenance")
            Kirigami.FormData.isSection: true
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
        
        RowLayout {
            Layout.fillWidth: true
            
            QQC2.Label {
                text: i18n("Clear local query cache:")
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
        
        Item {
            Kirigami.FormData.isSection: false
            height: Kirigami.Units.largeSpacing
        }
        
        QQC2.Label {
            Layout.fillWidth: true
            text: i18n("The cache is used to avoid redundant API calls and is refreshed once a day or when settings change.")
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            opacity: 0.6
            wrapMode: Text.WordWrap
        }
    }
}
