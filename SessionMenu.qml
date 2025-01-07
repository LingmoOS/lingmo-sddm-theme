

/*
 * SPDX-FileCopyrightText: 2021 Reion Wong <reionwong@gmail.com>
 * SPDX-FileCopyrightText: 2024 Elysia <elysia@lingmo.org>
 *
 * SPDX-License-Identifier: GPL-3.0
 */
import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import SddmComponents

import QtQuick.Controls.LingmoStyle
import LingmoUI

ToolButton {
    id: root

    property int currentIndex: -1
    property int rootFontSize

    visible: menu.count > 1
    implicitHeight: _currentLabel.implicitHeight + 10
    implicitWidth: _currentLabel.implicitWidth + 16

    padding: 6
    spacing: 8

    icon.width: 20
    icon.height: 20
    icon.color: Color.transparent(root.textColor, enabled ? 1.0 : 0.2)

    contentItem: IconLabel {
        id: _currentLabel
        anchors.centerIn: parent
        spacing: root.spacing
        mirrored: root.mirrored
        display: root.display

        icon: root.icon
        text: {
            instantiator.objectAt(currentIndex).text || ""
        }
        font: root.font
        color: root.textColor
    }

    background: LingmoControlBackground {
        implicitWidth: 30
        implicitHeight: 30
        radius: LingmoUnits.smallRadius
        color: {
            if (!enabled) {
                return disableColor
            }
            return hovered ? hoverColor : normalColor
        }
        shadow: !pressed && enabled
        LingmoFocusRectangle {
            visible: root.activeFocus
            radius: LingmoUnits.smallRadius
        }
    }

    DropShadow {
        id: dropShadow
        anchors.fill: _currentLabel
        source: _currentLabel
        z: -1
        horizontalOffset: 1
        verticalOffset: 1
        radius: LingmoUnits.smallRadius
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

    LingmoMenu {
        id: menu
        Instantiator {
            id: instantiator
            model: sessionModel
            onObjectAdded: (index, object) => menu.insertItem(index, object)
            onObjectRemoved: (index, object) => menu.removeItem(object)
            delegate: LingmoMenuItem {
                text: model.name
                onTriggered: {
                    root.currentIndex = model.index
                }
            }
        }
    }
}
