/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.12
import QtQuick.Controls 2.4
import QtQuick.Layouts  1.11
import QtQuick.Dialogs  1.3

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.Palette               1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Controllers           1.0

// Priyanka
import QGroundControl.FactControls  1.0
import QtPositioning                5.3
//import QGroundControl.FlightMap     1.0
//import QGroundControl.FlightDisplay 1.0
//import QGroundControl.Airspace      1.0

//import QGroundControl.Vehicle       1.0


import QtLocation                   5.3
/*
import QGroundControl.Airspace      1.0
import QGroundControl.Vehicle       1.0
*/
Rectangle {
    id:     _root
    color:  qgcPal.toolbarBackground

    property int currentToolbar: flyViewToolbar

    readonly property int flyViewToolbar:   0
    readonly property int planViewToolbar:  1
    readonly property int simpleToolbar:    2

    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property bool   _communicationLost: _activeVehicle ? _activeVehicle.vehicleLinkManager.communicationLost : false
    property color  _mainStatusBGColor: qgcPal.brandingPurple
    property var    _currentWaypoint
    property string _currentState:      "None"

    function dropMessageIndicatorTool() {
        if (currentToolbar === flyViewToolbar) {
            indicatorLoader.item.dropMessageIndicatorTool();
        }
    }

    QGCPalette { id: qgcPal }

    /// Bottom single pixel divider
    Rectangle {
        anchors.left:   parent.left
        anchors.right:  parent.right
        anchors.bottom: parent.bottom
        height:         1
        color:          "black"
        visible:        qgcPal.globalTheme === QGCPalette.Light
    }

    Rectangle {
        anchors.fill:   viewButtonRow
        visible:        currentToolbar === flyViewToolbar

        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0;                                     color: _mainStatusBGColor }
            GradientStop { position: currentButton.x + currentButton.width; color: _mainStatusBGColor }
            GradientStop { position: 1;                                     color: _root.color }
        }
    }

    RowLayout {
        id:                     viewButtonRow
        anchors.bottomMargin:   1
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        spacing:                ScreenTools.defaultFontPixelWidth / 2

        QGCToolBarButton {
            id:                     currentButton
            Layout.preferredHeight: viewButtonRow.height
            icon.source:            "/res/QGCLogoFull"
            logo:                   true
            onClicked:              mainWindow.showToolSelectDialog()
        }

        MainStatusIndicator {
            Layout.preferredHeight: viewButtonRow.height
            visible:                currentToolbar === flyViewToolbar
        }

        QGCButton {
            id:                 disconnectButton
            text:               qsTr("Disconnect")
            onClicked:          _activeVehicle.closeVehicle()
            visible:            _activeVehicle && _communicationLost && currentToolbar === flyViewToolbar
        }

    }

    QGCFlickable {
        id:                     toolsFlickable
        anchors.leftMargin:     ScreenTools.defaultFontPixelWidth * ScreenTools.largeFontPointRatio * 1.5
        anchors.left:           viewButtonRow.right
        anchors.bottomMargin:   1
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.right:          parent.right
        contentWidth:           indicatorLoader.x + indicatorLoader.width
        flickableDirection:     Flickable.HorizontalFlick

        Loader {
            id:                 indicatorLoader
            anchors.left:       parent.left
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            source:             currentToolbar === flyViewToolbar ?
                                    "qrc:/toolbar/MainToolBarIndicators.qml" :
                                    (currentToolbar == planViewToolbar ? "qrc:/qml/PlanToolBarIndicators.qml" : "")
        }
    }

    //-------------------------------------------------------------------------
    //-- Branding Logo
    Image {
        id:                     imageBrandingLogo
        anchors.right:          parent.right
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.margins:        ScreenTools.defaultFontPixelHeight * 0.66
        visible:                currentToolbar !== planViewToolbar && _activeVehicle && !_communicationLost && x > (toolsFlickable.x + toolsFlickable.contentWidth + ScreenTools.defaultFontPixelWidth)
        fillMode:               Image.PreserveAspectFit
        source:                 _outdoorPalette ? _brandImageOutdoor : _brandImageIndoor
        mipmap:                 true

        property bool   _outdoorPalette:        qgcPal.globalTheme === QGCPalette.Light
        property bool   _corePluginBranding:    QGroundControl.corePlugin.brandImageIndoor.length != 0
        property string _userBrandImageIndoor:  QGroundControl.settingsManager.brandImageSettings.userBrandImageIndoor.value
        property string _userBrandImageOutdoor: QGroundControl.settingsManager.brandImageSettings.userBrandImageOutdoor.value
        property bool   _userBrandingIndoor:    _userBrandImageIndoor.length != 0
        property bool   _userBrandingOutdoor:   _userBrandImageOutdoor.length != 0
        property string _brandImageIndoor:      brandImageIndoor()
        property string _brandImageOutdoor:     brandImageOutdoor()

        function brandImageIndoor() {
            if (_userBrandingIndoor) {
                return _userBrandImageIndoor
            } else {
                if (_userBrandingOutdoor) {
                    return _userBrandingOutdoor
                } else {
                    if (_corePluginBranding) {
                        return QGroundControl.corePlugin.brandImageIndoor
                    } else {
                        return _activeVehicle ? _activeVehicle.brandImageIndoor : ""
                    }
                }
            }
        }

        function brandImageOutdoor() {
            if (_userBrandingOutdoor) {
                return _userBrandingOutdoor
            } else {
                if (_userBrandingIndoor) {
                    return _userBrandingIndoor
                } else {
                    if (_corePluginBranding) {
                        return QGroundControl.corePlugin.brandImageOutdoor
                    } else {
                        return _activeVehicle ? _activeVehicle.brandImageOutdoor : ""
                    }
                }
            }
        }
    }

    // Small parameter download progress bar
    Rectangle {
        anchors.bottom: parent.bottom
        height:         _root.height * 0.05
        width:          _activeVehicle ? _activeVehicle.loadProgress * parent.width : 0
        color:          qgcPal.colorGreen
        visible:        !largeProgressBar.visible
    }

    // Large parameter download progress bar
    Rectangle {
        id:             largeProgressBar
        anchors.bottom: parent.bottom
        anchors.left:   parent.left
        anchors.right:  parent.right
        height:         parent.height
        color:          qgcPal.window
        visible:        _showLargeProgress

        property bool _initialDownloadComplete: _activeVehicle ? _activeVehicle.initialConnectComplete : true
        property bool _userHide:                false
        property bool _showLargeProgress:       !_initialDownloadComplete && !_userHide && qgcPal.globalTheme === QGCPalette.Light

        Connections {
            target:                 QGroundControl.multiVehicleManager
            function onActiveVehicleChanged(activeVehicle) { largeProgressBar._userHide = false }
        }

        Rectangle {
            anchors.top:    parent.top
            anchors.bottom: parent.bottom
            width:          _activeVehicle ? _activeVehicle.loadProgress * parent.width : 0
            color:          qgcPal.colorGreen
        }

        QGCLabel {
            anchors.centerIn:   parent
            text:               qsTr("Downloading")
            font.pointSize:     ScreenTools.largeFontPointSize
        }

        QGCLabel {
            anchors.margins:    _margin
            anchors.right:      parent.right
            anchors.bottom:     parent.bottom
            text:               qsTr("Click anywhere to hide")

            property real _margin: ScreenTools.defaultFontPixelWidth / 2
        }

        MouseArea {
            anchors.fill:   parent
            onClicked:      largeProgressBar._userHide = true


        }

    }

    Component {
        id: dialogGoto

        QGCPopupDialog {
            id:         root
            title:      qsTr("Set waypoint position")
            buttons:    mainWindow.showDialogDefaultWidth, StandardButton.Close

            property alias coordinate: controller.coordinate

            property real   _margin:        ScreenTools.defaultFontPixelWidth / 2
            property real   _fieldWidth:    ScreenTools.defaultFontPixelWidth * 10.5

            EditPositionDialogController {
                id: controller

                Component.onCompleted: initValues()
            }

            Column {
                id:         column
                width:      40 * ScreenTools.defaultFontPixelWidth
                spacing:    ScreenTools.defaultFontPixelHeight

                GridLayout {
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                    columnSpacing:  _margin
                    rowSpacing:     _margin
                    columns:        2

                    QGCLabel {
                        text: qsTr("Latitude")
                    }
                    FactTextField {
                        fact:               controller.latitude
                        Layout.fillWidth:   true
                    }

                    QGCLabel {
                        text: qsTr("Longitude")
                    }
                    FactTextField {
                        fact:               controller.longitude
                        Layout.fillWidth:   true
                    }

                    QGCButton {
                        text:               qsTr("Set and go")
                        Layout.alignment:   Qt.AlignRight
                        Layout.columnSpan:  2
                        onClicked: {
                            controller.setFromGeo()
                            //mainWindow.takeOffRequest()
                            console.log(controller.latitude.value)
                            console.log(controller.longitude.value)
                            _currentWaypoint = QtPositioning.coordinate(controller.latitude.value, controller.longitude.value)
                            globals.gotoLocationItemGlobal.show(_currentWaypoint)
                            globals.guidedControllerFlyView.confirmAction(globals.guidedControllerFlyView.actionGoto, _currentWaypoint, globals.gotoLocationItemGlobal)
                            _currentState = "Go"
                            root.close()
                        }
                    }

                }
            }
        }
    }

    RowLayout {
        anchors.right:          imageBrandingLogo.left
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.margins:        ScreenTools.defaultFontPixelHeight * 0.66

        QGCButton{
            id: auto_mode
            text: qsTr("Auto mode")
            enabled: _activeVehicle && !(_activeVehicle.flightMode == "Mission")
            onClicked: {
                _activeVehicle.flightMode = "Mission"
            }
        }

        QGCButton{
            id: guided_mode
            text: qsTr("Guided mode")
            enabled: _activeVehicle && !(_activeVehicle.flightMode == "Manual")
            onClicked: {
                _activeVehicle.flightMode = "Manual"
            }
        }

        QGCButton{
            id: arm
            text: qsTr("Arm")
            enabled: _activeVehicle && !_activeVehicle.armed
            onClicked: {
                mainWindow.armVehicleRequest()
            }
        }

        QGCButton{
            id: takeOff
            text: qsTr("TakeOff")
            enabled: _activeVehicle.armed && !_activeVehicle.flying
            onClicked: {
                mainWindow.takeOffRequest()
            }
        }

        QGCButton{
            id: addWaypoint
            text: qsTr("Patient's Location")
            enabled: _activeVehicle.flying
            onClicked: {
                dialogGoto.createObject(mainWindow).open()
            }
        }

        QGCButton {
            id: pause
            text: (_currentState == "None" || _currentState == "Go" || _currentState == "Stop") ? qsTr("Pause") : qsTr("Continue")
            enabled: _activeVehicle.flying
            onClicked: {
                if(_currentState == "Go")
                {
                    mainWindow.pauseMissionRequest()
                    _currentState = "Pause"
                }
                else // _currentState == "Pause"
                {
                    globals.gotoLocationItemGlobal.show(_currentWaypoint)
                    globals.guidedControllerFlyView.confirmAction(globals.guidedControllerFlyView.actionGoto, _currentWaypoint, globals.gotoLocationItemGlobal)
                    _currentState = "Go"
                }
            }
        }


        QGCButton {
            id: stop
            text: qsTr("Stop/RTL")
            enabled: _activeVehicle.flying
            onClicked: {
                mainWindow.stopMissionRequest()
                _currentState = "Stop"
            }
        }

        QGCButton{
            id: land
            text: qsTr("Landing")
            enabled: _activeVehicle.flying
            onClicked:{
                mainWindow.landRequest()
                _currentState = "Stop"
            }
        }

        QGCButton{
            id: disarm
            text: qsTr("Disarm")
            enabled: _activeVehicle.armed
            onClicked: {
                mainWindow.disarmVehicleRequest()
            }
        }

    }

}
