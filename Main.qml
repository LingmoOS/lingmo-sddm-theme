import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12 as QQC2
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0

import Lingmo.Accounts 1.0 as Accounts
import Lingmo.System 1.0 as System
import LingmoUI 1.0 as LingmoUI

import SddmComponents 2.0
import "./"

Item {
    id: root

    property string notificationMessage
    property bool loginVisible: false  // 登录界面显示状态
    property color timeColor: "white"  // 时间颜色，根据背景亮度调整
    property real initialY: timeLabel.y // 初始时间标签的y坐标
    property real initialBlur: 0 // 初始模糊半径

    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    TextConstants { id: textConstants }

    Image {
        id: wallpaperImage
        anchors.fill: parent
        source: "/etc/system/wallpaper/img.jpg"
        sourceSize: Qt.size(width * Screen.devicePixelRatio,
                            height * Screen.devicePixelRatio)
        fillMode: Image.PreserveAspectCrop
        asynchronous: false
        clip: true
        cache: false
        smooth: true
        onStatusChanged: checkTimeColor()  // 当背景图像加载完成后检测颜色
    }

    function checkTimeColor() {
        var imageBrightness = wallpaperImage.colorAt(0, 0).lightness
        timeColor = imageBrightness > 0.5 ? "black" : "white"
    }

    FastBlur {
        id: wallpaperBlur
        anchors.fill: parent
        radius: initialBlur
        source: wallpaperImage
        cached: true
        visible: true  // 始终显示，但可以通过radius控制模糊程度
    }

    Timer {
        repeat: true
        running: true
        interval: 1000

        onTriggered: {
            timeLabel.updateInfo()
            dateLabel.updateInfo()
        }
    }

    Component.onCompleted: {
        timeLabel.updateInfo()
        dateLabel.updateInfo()
    }

    // // 按下任意键进入登录页面
    // Keys.onPressed: {
    //     if (!loginVisible) {
    //         startLoginAnimation()
    //     }
    // }

    Keys.onPressed: {
        if (!loginVisible && (event.key === Qt.Key_Space || event.key === Qt.Key_Return)) {
            startLoginAnimation()
            event.accepted = true
        }
    }

    MouseArea {
        id: rootMouseArea
        anchors.fill: parent
        property real startY: 0
        property bool isPressing: false

        onPressed: {
            if (!loginVisible) {
                startY = mouseY
                isPressing = true
            }
        }

        onPositionChanged: {
            if (isPressing && mouseY < startY) {
                var deltaY = startY - mouseY
                if (deltaY > 5) { // 只需要滑动一点点
                    startLoginAnimation()
                    isPressing = false
                }
            }
        }

        onReleased: {
            isPressing = false
        }

        acceptedButtons: Qt.LeftButton
    }

    Item {
        id: _topItem
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: _mainItem.top
        anchors.bottomMargin: root.height * 0.1

        QQC2.Label {
            id: timeLabel
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            Layout.alignment: Qt.AlignHCenter
            font.pointSize: 60
            font.bold: true  // 加粗时间文本
            color: root.timeColor  // 自动反色
            opacity: 1  // 初始不透明

            function updateInfo() {
                timeLabel.text = new Date().toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
            }

            NumberAnimation on y {
                id: timeYAnimation
                from: 0
                to: -root.height * 0.2
                duration: 1000
            }

            NumberAnimation on opacity {
                id: timeOpacityAnimation
                from: 1
                to: 0
                duration: 1000
            }
        }

        QQC2.Label {
            id: dateLabel
            anchors.top: timeLabel.bottom
            anchors.topMargin: LingmoUI.Units.largeSpacing
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: 24
            color: root.timeColor  // 自动反色
            opacity: 1  // 初始不透明

            function updateInfo() {
                dateLabel.text = new Date().toLocaleDateString(Qt.locale(), Locale.LongFormat)
            }

            NumberAnimation on y {
                id: dateYAnimation
                from: 0
                to: -root.height * 0.2
                duration: 1000
            }

            NumberAnimation on opacity {
                id: dateOpacityAnimation
                from: 1
                to: 0
                duration: 1000
            }
        }

        DropShadow {
            anchors.fill: timeLabel
            source: timeLabel
            z: -1
            horizontalOffset: 1
            verticalOffset: 1
            radius: 10
            samples: radius * 4
            spread: 0.35
            color: Qt.rgba(0, 0, 0, 0.8)
            opacity: 0
            visible: true
        }

        DropShadow {
            anchors.fill: dateLabel
            source: dateLabel
            z: -1
            horizontalOffset: 1
            verticalOffset: 1
            radius: 10
            samples: radius * 4
            spread: 0.35
            color: Qt.rgba(0, 0, 0, 0.8)
            opacity: 0
            visible: true
        }
    }

    Item {
        id: _mainItem
        anchors.centerIn: parent
        width: 260 + LingmoUI.Units.largeSpacing * 3
        height: _mainLayout.implicitHeight + LingmoUI.Units.largeSpacing * 4

        visible: loginVisible  // 动态控制可见性
        opacity: loginVisible ? 1 : 0

        Behavior on opacity {
            OpacityAnimator { duration: 1000 }
        }

        Rectangle {
            anchors.fill: parent
            radius: LingmoUI.Theme.bigRadius + 2
            color: LingmoUI.Theme.darkMode ? "#424242" : "white"
            opacity: 0.5
        }

        ColumnLayout {
            id: _mainLayout
            anchors.fill: parent
            anchors.margins: LingmoUI.Units.largeSpacing * 1.5
            spacing: LingmoUI.Units.smallSpacing * 1.5

            UserView {
                id: _userView
                model: userModel
                Layout.fillWidth: true
            }

            QQC2.TextField {
                id: passwordField
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: 40
                Layout.preferredWidth: 260
                placeholderText: qsTr("Password")
                focus: true
                selectByMouse: true
                echoMode: TextInput.Password

                background: Rectangle {
                    color: LingmoUI.Theme.darkMode ? "#B6B6B6" : "white"
                    radius: LingmoUI.Theme.bigRadius
                    opacity: 0.5
                }

                Keys.onEnterPressed: root.startLogin()
                Keys.onReturnPressed: root.startLogin()
                Keys.onEscapePressed: passwordField.text = ""
            }

            QQC2.Button {
                id: unlockBtn
                hoverEnabled: true
                focusPolicy: Qt.NoFocus
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: 40
                Layout.preferredWidth: 260
                text: qsTr("Login")
                onClicked: root.startLogin()

                scale: unlockBtn.pressed ? 0.95 : 1.0

                Behavior on scale {
                    NumberAnimation {
                        duration: 100
                    }
                }

                background: Rectangle {
                    color: LingmoUI.Theme.darkMode ? "#B6B6B6" : "white"
                    opacity: unlockBtn.pressed ? 0.3 : unlockBtn.hovered ? 0.4 : 0.5
                    radius: LingmoUI.Theme.bigRadius
                }
            }
        }
    }

    Item {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: LingmoUI.Units.largeSpacing
        anchors.bottomMargin: LingmoUI.Units.largeSpacing

        width: sessionMenu.implicitWidth + LingmoUI.Units.largeSpacing
        height: sessionMenu.implicitHeight

        visible: loginVisible  // 动态控制可见性

        SessionMenu {
            id: sessionMenu
            anchors.fill: parent
            rootFontSize: 10
            height: 30
            Layout.fillWidth: true
        }
    }

    Item {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: LingmoUI.Units.largeSpacing
        anchors.bottomMargin: LingmoUI.Units.smallSpacing * 1.5

        width: 50
        height: 50 + LingmoUI.Units.largeSpacing

        visible: true  // 无论登录状态显示电源选项

        LingmoUI.RoundImageButton {
            anchors.fill: parent
            width: 50
            height: 50 + LingmoUI.Units.largeSpacing

            size: 50
            source: "system-shutdown-symbolic.svg"
            iconMargins: LingmoUI.Units.largeSpacing

            onClicked: actionMenu.popup()
        }
    }

    LingmoUIMenu {
        id: actionMenu

        QQC2.MenuItem {
            text: qsTr("Suspend")
            onClicked: sddm.suspend()
            visible: sddm.canSuspend
        }

        QQC2.MenuItem {
            text: qsTr("Reboot")
            onClicked: sddm.reboot()
            visible: sddm.canReboot
        }

        QQC2.MenuItem {
            text: qsTr("Shutdown")
            onClicked: sddm.powerOff()
            visible: sddm.canPowerOff
        }
    }

    QQC2.Label {
        id: message
        anchors.top: _mainItem.bottom
        anchors.topMargin: LingmoUI.Units.largeSpacing
        anchors.horizontalCenter: parent.horizontalCenter
        font.bold: true
        text: root.notificationMessage
        color: "white"

        visible: loginVisible  // 仅在登录界面显示

        Behavior on opacity {
            NumberAnimation {
                duration: 250
            }
        }

        opacity: text == "" ? 0 : 1
    }

    DropShadow {
        anchors.fill: message
        source: message
        z: -1
        horizontalOffset: 1
        verticalOffset: 1
        radius: 10
        samples: radius * 4
        spread: 0.35
        color: Qt.rgba(0, 0, 0, 0.8)
        opacity: 0.1
        visible: true
    }

    function startLogin() {
        var username = _userView.currentItem.userName
        var password = passwordField.text
        root.notificationMessage = ""
        console.log("Starting login for user:", username)  // 调试信息
        sddm.login(username, password, sessionMenu.currentIndex)
    }

    Timer {
        id: notificationResetTimer
        interval: 3000
        onTriggered: root.notificationMessage = ""
    }

    Timer {
        id: idleTimer
        interval: 30000 // 30秒
        running: false
        repeat: false
        onTriggered: {
            if (loginVisible) {
                startIdleAnimation()
            }
        }
    }

    function startLoginAnimation() {
        loginVisible = true
        wallpaperBlur.radius = 64
        timeLabel.y = -root.height * 0.2
        timeLabel.opacity = 0
        dateLabel.y = -root.height * 0.2
        dateLabel.opacity = 0
        idleTimer.restart()
    }

    function startIdleAnimation() {
        loginVisible = false
        wallpaperBlur.radius = initialBlur
        timeLabel.y = initialY
        timeLabel.opacity = 1
        dateLabel.y = initialY + LingmoUI.Units.largeSpacing
        dateLabel.opacity = 1
    }

    Connections {
        target: sddm

        function onLoginFailed() {
            notificationMessage = textConstants.loginFailed
            console.log("Login failed")  // 调试信息
            notificationResetTimer.start()
        }

        function onLoginSuccess() {
            notificationMessage = textConstants.loginSuccess
            console.log("Login successful")  // 调试信息
            loginVisible = false  // 登录成功后隐藏登录界面
        }
    }
}
