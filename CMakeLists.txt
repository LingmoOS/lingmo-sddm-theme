cmake_minimum_required(VERSION 3.15)

project(lingmo-sddm-theme)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

install(FILES Main.qml DESTINATION /usr/share/sddm/themes/lingmo)
install(FILES SessionMenu.qml DESTINATION /usr/share/sddm/themes/lingmo)
install(FILES UserView.qml DESTINATION /usr/share/sddm/themes/lingmo)
install(FILES LingmoUIMenu.qml DESTINATION /usr/share/sddm/themes/lingmo)
install(FILES LingmoUIMenuItem.qml DESTINATION /usr/share/sddm/themes/lingmo)
install(FILES system-shutdown-symbolic.svg DESTINATION /usr/share/sddm/themes/lingmo)
install(DIRECTORY faces DESTINATION /usr/share/sddm/themes/lingmo)
install(FILES theme.conf DESTINATION /usr/share/sddm/themes/lingmo)
install(FILES screenshot.png DESTINATION /usr/share/sddm/themes/lingmo)
install(FILES metadata.desktop DESTINATION /usr/share/sddm/themes/lingmo)

install(FILES hidpi.conf DESTINATION /etc/sddm.conf.d/)
install(FILES sddm_lingmo.conf DESTINATION /etc/sddm.conf.d/)


