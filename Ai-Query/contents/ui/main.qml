import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import "../code/gemini.js" as Gemini
import "../code/openrouter.js" as OpenRouter

PlasmoidItem {
    id: root
    
    Plasmoid.icon: "applications-education-science"
    
    property string apiKey: plasmoid.configuration.apiKey
    property string widgetTitle: plasmoid.configuration.widgetTitle
    property string geminiModel: plasmoid.configuration.geminiModel
    property string provider: plasmoid.configuration.provider
    property string openRouterApiKey: plasmoid.configuration.openRouterApiKey
    property string openRouterModel: plasmoid.configuration.openRouterModel

    onGeminiModelChanged: invalidateCacheAndReload()
    onProviderChanged: invalidateCacheAndReload()
    onOpenRouterModelChanged: invalidateCacheAndReload()
    
    property string question: plasmoid.configuration.question
    onQuestionChanged: invalidateCacheAndReload()
    
    property string formattingInstructions: plasmoid.configuration.formattingInstructions
    onFormattingInstructionsChanged: invalidateCacheAndReload()
    
    property bool googleSearchEnabled: plasmoid.configuration.googleSearchEnabled
    onGoogleSearchEnabledChanged: invalidateCacheAndReload()
    
    property string cachedResponse: ""
    property string cacheDate: ""
    property string cachedModel: ""
    property string statusText: ""
    property bool loading: false
    property bool isReady: false
    
    width: Kirigami.Units.gridUnit * 20
    height: Kirigami.Units.gridUnit * 15
    
    // Carica la cache all'avvio
    Component.onCompleted: {
        loadCache()
        if (needsRefresh()) {
            queryAI()
        }
        // Utilizziamo un piccolo ritardo per assicurarci che tutti i segnali di inizializzazione siano passati
        isReady = true
    }
    
    // Funzione per verificare se serve un refresh
    function needsRefresh() {
        if (!cacheDate || cachedResponse === "") return true;
        
        var now = new Date();
        var cached = new Date(cacheDate);
        
        // Verifica se è un giorno diverso
        return now.getFullYear() !== cached.getFullYear() || 
               now.getMonth() !== cached.getMonth() || 
               now.getDate() !== cached.getDate();
    }
    
    // Funzione per salvare la cache
    function saveCache(response, modelName) {
        let now = new Date();
        let dateIso = now.toISOString();
        cachedResponse = response;
        cacheDate = dateIso;
        cachedModel = modelName;
        plasmoid.configuration.cachedResponse = response;
        plasmoid.configuration.cacheDate = dateIso;
        plasmoid.configuration.cachedModel = modelName;
        
        // Tenta di forzare il salvataggio della configurazione
        if (typeof plasmoid.configuration.save === "function") {
            plasmoid.configuration.save();
        } else if (typeof plasmoid.configuration.writeConfig === "function") {
            plasmoid.configuration.writeConfig();
        }
    }
    
    // Funzione per invalidare la cache e ricaricare
    function invalidateCacheAndReload() {
        // Evitiamo ricariche multiple all'avvio o se già in caricamento
        if (!isReady || loading) return;
        
        cachedResponse = "";
        cacheDate = "";
        cachedModel = "";
        plasmoid.configuration.cachedResponse = "";
        plasmoid.configuration.cacheDate = "";
        plasmoid.configuration.cachedModel = "";
        
        // Forza il salvataggio anche dopo l'invalidazione
        if (typeof plasmoid.configuration.save === "function") {
            plasmoid.configuration.save();
        } else if (typeof plasmoid.configuration.writeConfig === "function") {
            plasmoid.configuration.writeConfig();
        }
        
        queryAI();
    }
    
    // Funzione per caricare la cache
    function loadCache() {
        cachedResponse = plasmoid.configuration.cachedResponse || ""
        cacheDate = plasmoid.configuration.cacheDate || ""
        cachedModel = plasmoid.configuration.cachedModel || ""
    }
    
    // Helper per formattare la data della cache
    function formatCacheDate(isoString) {
        if (!isoString) return "";
        let d = new Date(isoString);
        if (isNaN(d.getTime())) return isoString; // Fallback per vecchie date salvate come stringhe locali
        
        return d.toLocaleDateString(undefined, { day: 'numeric', month: 'short' }) + ", " + 
               d.toLocaleTimeString(undefined, { hour: '2-digit', minute: '2-digit' });
    }
    
    // Funzione per interrogare l'AI (Gemini o OpenRouter)
    function queryAI() {
        if (provider === "openrouter") {
             if (!openRouterApiKey || openRouterApiKey === "") {
                statusText = i18n("Error: OpenRouter API Key not configured.\nGo to settings to configure it.")
                return
            }
        } else {
            // Default to Google/Gemini
            if (!apiKey || apiKey === "") {
                statusText = i18n("Error: Google API Key not configured.\nGo to settings to configure it.")
                return
            }
        }
        
        if (!question || question === "") {
            statusText = i18n("Error: No question configured.\nGo to settings to configure it.")
            return
        }
        
        loading = true
        statusText = i18n("Loading...")
        
        let fullQuery = question
        if (formattingInstructions && formattingInstructions.trim() !== "") {
            fullQuery += "\n\n" + formattingInstructions
        }
        
        if (provider === "openrouter") {
             OpenRouter.queryOpenRouter(openRouterApiKey, openRouterModel, fullQuery, function(success, response) {
                loading = false
                if (success) {
                    statusText = ""
                    saveCache(response, openRouterModel)
                } else {
                    statusText = i18n("Error: %1", response)
                }
            })
        } else {
            Gemini.queryGemini(apiKey, geminiModel, fullQuery, googleSearchEnabled, function(success, response) {
                loading = false
                if (success) {
                    statusText = ""
                    saveCache(response, geminiModel)
                } else {
                    statusText = i18n("Error: %1", response)
                }
            })
        }
    }
    
    // Interfaccia compatta (icona nel pannello)
    compactRepresentation: Item {

        Kirigami.Icon {
            id: icon
            anchors.fill: parent
            source: plasmoid.icon
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
                text: widgetTitle 
            }

            QQC2.Label {
                Layout.fillWidth: true
                text: "(" + cachedModel + ")"
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                opacity: 0.6
                horizontalAlignment: Text.AlignRight
            }
            
            QQC2.ToolButton {
                icon.name: "view-refresh"
                text: i18n("Refresh")
                display: QQC2.AbstractButton.IconOnly
                enabled: !loading
                onClicked: queryAI()
                
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
                text: statusText !== "" ? statusText : (cachedResponse !== "" ? cachedResponse : i18n("No response in cache.\nPress 'Refresh' to query AI."))
                wrapMode: Text.WordWrap
                textFormat: Text.MarkdownText
                onLinkActivated: (link) => Qt.openUrlExternally(link)
                
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
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
            text: i18n("Cache: %1", formatCacheDate(cacheDate))
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            opacity: 0.6
            horizontalAlignment: Text.AlignRight
        }
    }
}
