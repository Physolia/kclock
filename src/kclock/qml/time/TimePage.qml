/*
 * Copyright 2020 Devin Lin <espidev@gmail.com>
 * Copyright 2019 Nick Reitemeyer <nick.reitemeyer@web.de>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.2
import QtQuick.Shapes 1.12

import org.kde.kirigami 2.15 as Kirigami

import "../components"
import kclock 1.0

Kirigami.ScrollablePage {
    id: timePage
    
    property int yTranslate: 0

    property int clockRadius: Kirigami.Units.gridUnit * 4

    title: i18n("Time")
    icon.name: "clock"

    // desktop action
    mainAction: Kirigami.Action {
        iconName: "globe"
        text: i18n("Edit")
        onTriggered: timePage.openEditSheet()
        visible: !Kirigami.Settings.isMobile
    }
    
    actions.contextualActions: [
        Kirigami.Action {
            displayHint: Kirigami.Action.IconOnly
            visible: !applicationWindow().isWidescreen
            iconName: "settings-configure"
            text: i18n("Settings")
            onTriggered: applicationWindow().pageStack.layers.push(applicationWindow().getPage("Settings"))
        }
    ]
    
    function openEditSheet() {
        timeZoneSelect.active = true;
        timeZoneSelect.item.open();
    }
    
    TimeZoneSelectWrapper {
        id: timeZoneSelect
        active: false
    }
    
    header: RowLayout {
        id: bigTimeDisplay
        height: clockItemLoader.height + Kirigami.Units.gridUnit * 0.5
        implicitHeight: height
        anchors.left: parent.left
        anchors.right: parent.right
        
        transform: Translate { y: yTranslate }
        
        // left side - analog clock
        Loader {
            id: clockItemLoader
            
            Layout.alignment: Qt.AlignHCenter
            width: Math.round(clockRadius * 2 + Kirigami.Units.gridUnit * 0.5)
            height: clockRadius * 2 + Kirigami.Units.gridUnit
            
            // reload clock when page opens for animation
            asynchronous: true
            Connections {
                target: applicationWindow().pageStack                
                function onCurrentItemChanged() {
                    clockItemLoader.active = applicationWindow().pageStack.currentItem == applicationWindow().getPage("Time");
                }
            }
            
            // clock item
            sourceComponent: Item {
                id: clockItem
                AnalogClock {
                    id: analogClock
                    anchors.centerIn: parent
                    height: clockRadius * 2 
                    width: clockRadius * 2
                }
            }
        }
        
        // right side - digital clock + location
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.rightMargin: Kirigami.Units.smallSpacing
            Label {
                Layout.alignment: Qt.AlignRight
                font.pointSize: Math.round(Kirigami.Theme.defaultFont.pointSize * 2.8)
                font.weight: Font.Light
                text: kclockFormat.currentTime
            }
            Label {
                Layout.alignment: Qt.AlignRight
                font.pointSize: Math.round(Kirigami.Theme.defaultFont.pointSize * 1.2)
                text: utilModel.tzName
                color: Kirigami.Theme.textColor
            }
        }
    }
    
    // time zones
    ListView {
        model: SavedTimeZonesModel {}
        id: zoneList
        currentIndex: -1 // no default selection
        transform: Translate { y: yTranslate }
        
        reuseItems: true
        
        add: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: Kirigami.Units.shortDuration }
        }
        remove: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: Kirigami.Units.shortDuration }
        }
        displaced: Transition {
            NumberAnimation { properties: "x,y"; duration: Kirigami.Units.longDuration; easing.type: Easing.InOutQuad}
        }
        
        // no timezones placeholder
        Kirigami.PlaceholderMessage {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: Math.round(parent.height / 2 - bigTimeDisplay.height / 2)
            visible: zoneList.count == 0
            text: i18n("No timezones configured")
            icon.name: "globe"
        }
        
        // mobile action
        FloatingActionButton {
            anchors.fill: parent
            iconName: "globe"
            onClicked: timePage.openEditSheet()
            visible: Kirigami.Settings.isMobile
        }
        
        delegate: Kirigami.BasicListItem {
            leftPadding: Kirigami.Units.largeSpacing * 2
            rightPadding: Kirigami.Units.largeSpacing * 2
            topPadding: Kirigami.Units.largeSpacing
            bottomPadding: Kirigami.Units.largeSpacing
            activeBackgroundColor: "transparent"
            activeTextColor: Kirigami.Theme.textColor

            label: model.id
            subtitle: model.relativeTime
            bold: true
            
            trailing: Item {
                implicitWidth: timeText.width
                implicitHeight: timeText.height
                Kirigami.Heading {
                    id: timeText
                    level: 2
                    text: model.timeString
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}