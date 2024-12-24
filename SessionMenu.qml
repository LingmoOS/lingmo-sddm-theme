

/*
 * SPDX-FileCopyrightText: 2021 Reion Wong <reionwong@gmail.com>
 * SPDX-FileCopyrightText: 2024 Elysia <elysia@lingmo.org>
 *
 * SPDX-License-Identifier: GPL-3.0
 */
import QtQuick
import QtQuick.Controls as QC
import Qt5Compat.GraphicalEffects
import LingmoUI.CompatibleModule as LingmoUI
import SddmComponents

QC.ToolButton {
    id: root

    property int currentIndex: -1
    property int rootFontSize

    visible: menu.count > 1
    implicitHeight: _currentLabel.implicitHeight + 4
    implicitWidth: _currentLabel.implicitWidth + 8

    contentItem: QC.Label {
        id: _currentLabel
        anchors.centerIn: parent
        color: "white"
        font.pointSize: rootFontSize
        text: {
            instantiator.objectAt(currentIndex).text || ""
        }
    }

    background: Rectangle {
        color: "transparent"
        border.color: "white"
        border.width: 1
    }

    DropShadow {
        id: dropShadow
        anchors.fill: _currentLabel
        source: _currentLabel
        z: -1
        horizontalOffset: 1
        verticalOffset: 1
        radius: 15
        samples: radius * 4
        spread: 0.35
        color: Qt.rgba(0, 0, 0, 0.2)
        opacity: 0.5
        visible: true
    }

    onClicked: menu.open()

    Component.onCompleted: {
        currentIndex = sessionModel.lastIndex
    }

    QC.Menu {
        id: menu
        Instantiator {
            id: instantiator
            model: sessionModel
            onObjectAdded: (index, object) => menu.insertItem(index, object)
            onObjectRemoved: (index, object) => menu.removeItem(object)
            delegate: QC.MenuItem {
                text: model.name
                onTriggered: {
                    root.currentIndex = model.index
                }
            }
        }
    }
}
