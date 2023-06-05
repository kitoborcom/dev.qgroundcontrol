# QGroundControl Ground Control Station

[![Releases](https://img.shields.io/github/release/mavlink/QGroundControl.svg)](https://github.com/mavlink/QGroundControl/releases)

*QGroundControl* (QGC) is an intuitive and powerful ground control station (GCS) for UAVs.

Key Links:
* [Website](http://qgroundcontrol.com) (qgroundcontrol.com)
* [User Manual](https://docs.qgroundcontrol.com/en/)
* [Developer Guide](https://dev.qgroundcontrol.com/en/)
* [Discussion/Support](https://docs.qgroundcontrol.com/en/Support/Support.html)
* [Contributing](https://dev.qgroundcontrol.com/en/contribute/)
* [License](https://github.com/mavlink/qgroundcontrol/blob/master/COPYING.md)

# Hide Settings in QGroundControl Based on User Access Type

A how-to guide with code samples on configuring and building your own custom QGroundControl
application. We’ll be changing the UI based on a passcode that we supply to unlock different levels of
access.

## Configuring the Project

1. Clone the QGroundControl repository found here:
    a. https://github.com/mavlink/qgroundcontrol
2. Open Qt Creator
3. Select “File” and then “Open File or Project...”
4. Navigate to the repository
5. Select the file “qgroundcontrol.pro”
6. Select “Configure Project”
7. In the terminal window navigate to the [QGroundControl Repository]/custom
8. Update sub dependencies with this command:
    a. git submodule update --recursive
9. Restart Qt Creator
10. The project will now be able to build without any modifications

## Development

Any files that are mentioned from “the Github Repository” can be found above:
The complete working code in in the “**custom**” directory 

### Adding the Access Type cc/h files

There are 3 access types; Basic, Expert, and Factory. In this post, the user will only be able to access the
motor component set up page if their access type is labeled as “Expert” or “Factory”

1. Create 4 new files under custom/src:
    a. AccessType.cpp
    b. AccessTypeConfig.cpp
    c. AccessType.h
    d. AccessTypeConfig.h
2. For AccessType.cpp, copy “ _AccessType.cpp_ ” from the **Github Repository**
3. For AccessTypeConfig.cpp, copy “ _AccessTypeConfig.cpp_ ” from the **Github Repository**
4. For AccessType.h, copy “ _AccessType.h_ ” from the **Github Repository**
5. For AccessTypeConfig.h, copy “ _AccessTypeConfig.h_ ” from the **Github Repository**

### Adding the Custom Plugins

The custom plugins allow the user to have access types depending on the drone firmware. In this case,
the firmware that will have a custom plugin is PX4-based

1. Create 6 new files under custom/src (All these files - CustomCorePlugin are modified
    versions of their original counterparts found under src/FirmwarePlugin/PX4):
       a. CustomFirmwarePluginFactory.h
       b. CustomPX4FirmwarePlugin.h
       c. CustomCorePlugin.h
       d. CustomFirmwarePluginFactory.cc
       e. CustomPX4FirmwarePlugin.cc
       f. CustomCorePlugin.cc
2. In CustomFirmwarePluginFactory.h, copy “ _CustomFirmwarePluginFactory.h_ ” from the
    **Github Repository**
3. In CustomCorePlugin.h, copy “ _CustomCorePlugin.h_ ” from the **Github Repository**
4. In CustomFirmwarePluginFactory.cc, copy “ _CustomFirmwarePluginFactory.cc_ ” from the
    **Github Repository**
5. In CustomPX4FirmwarePlugin.h, copy “ _CustomPX4FirmwarePlugin.h_ ” from the **Github**
    **Repository**
6. In CustomCorePlugin.cc, copy “ _CustomCorePlugin.cc_ ” from the **Github Repository**
7. In CustomPX4FirmwarePlugin.cc, copy “ _CustomPX4FirmwarePlugin.cc_ ” from the
    **Github Repository**

### Passcode Manager

This is how the logic is handled for setting and changing the user’s access types

1. Create 2 new files under custom/src/PasscodeMenu:
    a. PascodeManager.h
    b. PasscodeManager.cc
2. In PasscodeManager.h, copy “ _PascodeManager.h_ ” from the **Github Repository**
3. In PasscodeManager.cc, copy “ _PasscodeManager.cc_ ” from the **Github Repository**

### Configuring the custom.pri file

This is the project initialization file

1. Open the custom.pri file
2. Under SOURCES, add the following:
3. Under HEADERS, add the following:

```
$ $PWD /src/AccessType.cpp \
$ $PWD /src/AccessTypeConfig.cpp \
$ $PWD /src/CustomFirmwarePluginFactory.cc \
$ $PWD /src/CustomPX4FirmwarePlugin.cc \
$ $PWD /src/CustomCorePlugin.cc \
$ $PWD /src/PasscodeMenu/PasscodeManager.cc
```
```
$ $PWD /src/AccessType.h \
$ $PWD /src/AccessTypeConfig.h \
$ $PWD /src/CustomFirmwarePluginFactory.h \
$ $PWD /src/CustomPX4FirmwarePlugin.h \
$ $PWD /src/CustomCorePlugin.h \
$ $PWD /src/PasscodeMenu/PasscodeManager.h
```

## Overriding the QML

### Custom Motor Component QML

This will override the original Motor Component

1. Under custom/res/Custom, create the file CustomMotorComponent.qml and copy
    “ _CustomMotorComponent.qml_ ” from the **Github Repository**
2. In custom/qgroundcontrol.exclusion, add this line:
```
< file alias= "MotorComponent.qml" > ../src/AutoPilotPlugins/Common/MotorComponent.qml </ file >
```
3. In custom/custom.qrc, under the section with the prefix “qml”, add this line:
```
< file > CustomMotorComponent.qml </ file >
```
4. In the terminal window navigate to the [QGroundControl Repository]/custom and run this
    command:
```
python updateqrc. py
```

### Passcode Menu QML

This will be a new view inside the application setup page

1. Under custom/res, create the file, PasswordSettings.qml and copy “ **PasswordSettings.qml**” from the **Github**
    **Repository**
2. In custom/custom.qrc, under the section with the prefix “qml”, add this line:
```
< file alias= "PasswordSettings.qml" > res/PasswordSettings.qml </ file >
```
