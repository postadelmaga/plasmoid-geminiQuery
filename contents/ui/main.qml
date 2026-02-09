import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import "../code/gemini.js" as Gemini

PlasmoidItem {
    id: root
    
    property string apiKey: plasmoid.configuration.apiKey
    property string widgetTitle: plasmoid.configuration.widgetTitle
    property string geminiModel: plasmoid.configuration.geminiModel
    onGeminiModelChanged: invalidateCacheAndReload()
    
    property string question: plasmoid.configuration.question
    onQuestionChanged: invalidateCacheAndReload()
    
    property string cachedResponse: ""
    property string cacheDate: ""
    property string statusText: ""
    property bool loading: false
    
    width: Kirigami.Units.gridUnit * 20
    height: Kirigami.Units.gridUnit * 15
    
    // Carica la cache all'avvio
    Component.onCompleted: {
        loadCache()
        if (needsRefresh()) {
            queryGemini()
        }
    }
    
    // Funzione per verificare se serve un refresh
    function needsRefresh() {
        var today = new Date().toDateString()
        return cacheDate !== today || cachedResponse === ""
    }
    
    // Funzione per salvare la cache
    function saveCache(response) {
        let now = new Date();
        let dateStr = now.toLocaleDateString() + " " + now.toLocaleTimeString();
        cachedResponse = response;
        cacheDate = dateStr;
        plasmoid.configuration.cachedResponse = response;
        plasmoid.configuration.cacheDate = dateStr;
    }
    
    // Funzione per invalidare la cache e ricaricare
    function invalidateCacheAndReload() {
        // Evitiamo ricariche multiple all'avvio o se già in caricamento
        if (loading) return;
        
        cachedResponse = "";
        cacheDate = "";
        plasmoid.configuration.cachedResponse = "";
        plasmoid.configuration.cacheDate = "";
        queryGemini();
    }
    
    // Funzione per caricare la cache
    function loadCache() {
        cachedResponse = plasmoid.configuration.cachedResponse || ""
        cacheDate = plasmoid.configuration.cacheDate || ""
    }
    
    // Funzione per interrogare Gemini
    function queryGemini() {
        if (!apiKey || apiKey === "") {
            statusText = i18n("Error: API Key not configured.\nGo to settings to configure it.")
            return
        }
        
        if (!question || question === "") {
            statusText = i18n("Error: No question configured.\nGo to settings to configure it.")
            return
        }
        
        loading = true
        statusText = i18n("Loading...")
        
        Gemini.queryGemini(apiKey, geminiModel, question, function(success, response) {
            loading = false
            if (success) {
                statusText = ""
                saveCache(response)
            } else {
                statusText = i18n("Error: %1", response)
            }
        })
    }
    
    // Interfaccia compatta (icona nel pannello)
    compactRepresentation: Item {
        Layout.fillWidth: false
        Layout.fillHeight: false
        Layout.minimumWidth: Kirigami.Units.iconSizes.small
        Layout.minimumHeight: Kirigami.Units.iconSizes.small
        
        Kirigami.Icon {
            id: icon
            anchors.fill: parent
            source: "brain"
            active: compactMouse.containsMouse
            
            MouseArea {
                id: compactMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.expanded = !root.expanded
            }
        }
        
        // Indicatore di caricamento
        QQC2.BusyIndicator {
            anchors.centerIn: parent
            width: Kirigami.Units.iconSizes.small
            height: Kirigami.Units.iconSizes.small
            running: loading
            visible: loading
        }
    }
    
    // Interfaccia espansa (popup)
    fullRepresentation: ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumWidth: Kirigami.Units.gridUnit * 20
        Layout.minimumHeight: Kirigami.Units.gridUnit * 15
        spacing: Kirigami.Units.smallSpacing
        
        // Header con titolo e pulsanti
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing
            
            Kirigami.Heading {
                Layout.fillWidth: true
                level: 3
                text: widgetTitle !== "" ? widgetTitle : i18n("Gemini Query")
            }
            
            QQC2.ToolButton {
                icon.name: "view-refresh"
                text: i18n("Refresh")
                display: QQC2.AbstractButton.IconOnly
                enabled: !loading
                onClicked: queryGemini()
                
                QQC2.ToolTip.visible: hovered
                QQC2.ToolTip.text: i18n("Refresh response")
                QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
            }
            
            QQC2.ToolButton {
                icon.name: "configure"
                text: i18n("Configure")
                display: QQC2.AbstractButton.IconOnly
                onClicked: plasmoid.internalAction("configure").trigger()
                
                QQC2.ToolTip.visible: hovered
                QQC2.ToolTip.text: i18n("Settings")
                QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
            }
        }
        
        KSvg.SvgItem {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            imagePath: "widgets/line"
            elementId: "horizontal-line"
        }
        
        // Question is now hidden per user request
        // RowLayout and SvgItem removed
        
        // Area di risposta scrollabile
        QQC2.ScrollView {
            id: responseScrollView
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
            
            QQC2.Label {
                id: responseText
                width: responseScrollView.availableWidth
                text: statusText !== "" ? statusText : (cachedResponse !== "" ? cachedResponse : i18n("No response in cache.\nPress 'Refresh' to query Gemini."))
                wrapMode: Text.WordWrap
                textFormat: Text.MarkdownText
            }
        }
        
        // Footer con info cache
        KSvg.SvgItem {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            imagePath: "widgets/line"
            elementId: "horizontal-line"
            visible: cacheDate !== ""
        }
        
        QQC2.Label {
            Layout.fillWidth: true
            visible: cacheDate !== ""
            text: i18n("Cache from: %1", cacheDate)
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            opacity: 0.6
            horizontalAlignment: Text.AlignRight
        }
    }
}
