import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("General")
        icon: "configure"
        source: "configGeneral.qml"
    }
    ConfigCategory {
        name: i18n("Query")
        icon: "help-about"
        source: "configQuery.qml"
    }
    ConfigCategory {
        name: i18n("Advanced")
        icon: "applications-system"
        source: "configAdvanced.qml"
    }
}
