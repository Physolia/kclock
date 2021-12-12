/*
 * Copyright 2021 Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.2

import org.kde.kirigami 2.19 as Kirigami

import "../components"
import "../components/formatUtil.js" as FormatUtil
import kclock 1.0

Kirigami.Dialog {
    id: root
    
    property Alarm alarm
    
    readonly property int hours: alarm ? alarm.hours : 0
    readonly property int minutes: alarm ? alarm.minutes : 0
    readonly property string name: alarm ? alarm.name : ""

    padding: Kirigami.Units.gridUnit * 3
    
    title: i18n("Alarm is ringing")
    showCloseButton: false
    closePolicy: Popup.NoAutoClose
    
    contentItem: ColumnLayout {
        width: implicitWidth
        implicitWidth: Kirigami.Units.gridUnit * 20
        Label {
            Layout.alignment: Qt.AlignHCenter
            font.weight: Font.Light
            font.pointSize: Math.round(Kirigami.Theme.defaultFont.pointSize * 2)
            text: kclockFormat.formatTimeString(root.hours, root.minutes)
        }
        
        Label {
            Layout.alignment: Qt.AlignHCenter
            font.weight: Font.Bold
            font.pointSize: Math.round(Kirigami.Theme.defaultFont.pointSize * 1.25)
            text: root.name ? root.name : i18n("Alarm")
            wrapMode: Text.Wrap
        }
    }
    
    standardButtons: Kirigami.Dialog.NoButton
    flatFooterButtons: true
    
    customFooterActions: [
        Kirigami.Action {
            text: i18n("Snooze")
            onTriggered: alarm.snooze()
        },
        Kirigami.Action {
            text: i18n("Dismiss")
            onTriggered: {
                alarm.dismiss();
            }
        }
    ]
}
