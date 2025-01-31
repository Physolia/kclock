// SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import kclock

RowLayout {
    id: root
    
    property int hours: 0
    property int minutes: 0
    readonly property bool twelveHourTime: !UtilModel.use24HourTime // am/pm
    
    onHoursChanged: updateHours()
    onMinutesChanged: minutesSpinbox.value = minutes

    Component.onCompleted: {
        // needs to manually be triggered because onHoursChanged doesn't emit when set to 0
        updateHours();
    }

    function updateHours() {
        if (twelveHourTime) {
            hoursSpinbox.value = ((hours % 12) == 0) ? 12 : hours % 12;
        } else {
            hoursSpinbox.value = hours;
        }
    }
    
    RowLayout {
        spacing: Kirigami.Units.largeSpacing
        Layout.alignment: Qt.AlignHCenter

        // note: for 12-hour time, we have hours from 1-12 (0'o clock displays as 12)
        //       for 24-hour time, we have hours from 0-23
        TimePickerSpinBox {
            id: hoursSpinbox
            editable: true
            from: root.twelveHourTime ? 1 : 0
            to: root.twelveHourTime ? 12 : 23
            
            onValueModified: {
                if (root.twelveHourTime) {
                    if (root.hours >= 12) {
                        root.hours = value % 12 + 12;
                    } else {
                        root.hours = value % 12;
                    }
                } else {
                    root.hours = value;
                }
            }
        }
        
        Kirigami.Heading {
            level: 1
            text: ":"
        }
        
        TimePickerSpinBox {
            id: minutesSpinbox
            editable: true
            from: 0
            to: 59
            
            onValueModified: {
                root.minutes = value;
            }
        }
        
        Button {
            id: amPmToggle
            visible: root.twelveHourTime
            leftPadding: Kirigami.Units.largeSpacing
            rightPadding: Kirigami.Units.largeSpacing
            topPadding: Kirigami.Units.largeSpacing
            bottomPadding: Kirigami.Units.largeSpacing
            Layout.alignment: Qt.AlignVCenter

            contentItem: Item {
                implicitWidth: label.implicitWidth
                implicitHeight: label.implicitHeight
                Label {
                    id: label
                    anchors.centerIn: parent
                    font.weight: Font.Light
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.3
                    text: i18n(hours < 12 ? i18n("AM") : i18n("PM"))
                }
            }

            background: Rectangle {
                radius: Kirigami.Units.smallSpacing
                border.color: minutesSpinbox.buttonBorderColor
                border.width: 1
                color: amPmToggle.pressed ? minutesSpinbox.buttonPressedColor : (amPmToggle.hovered ? minutesSpinbox.buttonHoverColor : minutesSpinbox.buttonColor)
            }

            onClicked: {
                if (root.hours >= 12) {
                    root.hours -= 12;
                } else {
                    root.hours += 12;
                }
            }
        }
    }
}
