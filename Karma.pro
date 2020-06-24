# allows to add DEPLOYMENTFOLDERS and links to the Felgo library and QtCreator auto-completion
CONFIG += felgo
CONFIG += c++11
CONFIG -= qtquickcompiler

# uncomment this line to add the Live Client Module and use live reloading with your custom C++ code
# for the remaining steps to build a custom Live Code Reload app see here: https://felgo.com/custom-code-reload-app/
# CONFIG += felgo-live

# Project identifier and version
# More information: https://felgo.com/doc/felgo-publishing/#project-configuration
PRODUCT_IDENTIFIER = de.altocinco.cards.karma
PRODUCT_VERSION_NAME = 1
PRODUCT_VERSION_CODE = 1

# Optionally set a license key that is used instead of the license key from
# main.qml file (App::licenseKey for your app or GameWindow::licenseKey for your game)
# Only used for local builds and Felgo Cloud Builds (https://felgo.com/cloud-builds)
# Not used if using Felgo Live
PRODUCT_LICENSE_KEY = "20BACC37F6D35C7A87E96ACC09E030DB8569DEAF23145B78C264774E769953F61DF59185B699318A2C6FDEDE457B6DE06B972C9F73EC89E7884D2D8588ADEE5AB50AC99496B84864CB4BBD6D07558C9BC3A437190744456EEFD88EF9DB4A2A8C560575C2B4694456C9A4698550D73C428615AFD748B45059C64EDEBCC09BF4B4E5764C9E4042B63DDF61D6FBF16669F74304B91EBFBE25E35D555FD6D60F98DE84511B7517DC57D43E76BEB32E0DF5DC4EDBDE3E83A7D0B6659D75913F6973565D0CC87515AEC0045DFFBDCFE78618247C81BF47BC04C73A7A33FE378EF7C8BD9F43C69EF9A9DC12417AE40981A21A4EE863300EEAF5AE42BE9525439B110B5812C35EA33E2B7134D446E7C9614001782ECEE53A23042DAD8119BBF27CB49B0BC9424D2620CD9B7B3A82FECC6B7AB23932C7DA9789FA0B31C07004453E833E5CE0725F264D6906B1D96962D11CFFDDCA"

QT += websockets

qmlFolder.source = qml
#DEPLOYMENTFOLDERS += qmlFolder # comment for publishing

assetsFolder.source = assets
DEPLOYMENTFOLDERS += assetsFolder

# Add more folders to ship with the application here

RESOURCES += resources.qrc # uncomment for publishing


# NOTE: for PUBLISHING, perform the following steps:
# 1. comment the DEPLOYMENTFOLDERS += qmlFolder line above, to avoid shipping your qml files with the application (instead they get compiled to the app binary)
# 2. uncomment the resources.qrc file inclusion and add any qml subfolders to the .qrc file; this compiles your qml files and js files to the app binary and protects your source code
# 3. change the setMainQmlFile() call in main.cpp to the one starting with "qrc:/" - this loads the qml files from the resources
# for more details see the "Deployment Guides" in the Felgo Documentation

# during development, use the qmlFolder deployment because you then get shorter compilation times (the qml files do not need to be compiled to the binary but are just copied)
# also, for quickest deployment on Desktop disable the "Shadow Build" option in Projects/Builds - you can then select "Run Without Deployment" from the Build menu in Qt Creator if you only changed QML files; this speeds up application start, because your app is not copied & re-compiled but just re-interpreted


# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp

android {
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
    OTHER_FILES += android/AndroidManifest.xml \
      android/build.gradle

}

ios {
    QMAKE_INFO_PLIST = ios/Project-Info.plist
    OTHER_FILES += $$QMAKE_INFO_PLIST

    QMAKE_ASSET_CATALOGS += $$PWD/ios/Images.xcassets
    QMAKE_ASSET_CATALOGS_APP_ICON = "AppIcon"

    # Uncomment for using iOS plugin libraries
    # FELGO_PLUGINS += facebook onesignal flurry admob chartboost soomla
}

DISTFILES += \
    qml/ShitheadMain.qml \
    qml/ShitheadMainItem.qml \
    qml/common/ButtonBase.qml \
    qml/common/Constants.qml \
    qml/common/GConsole.qml \
    qml/common/MenuButton.qml \
    qml/common/SceneBase.qml \
    qml/common/SwipeArea.qml \
    qml/common/qmldir \
    qml/config.json \
    qml/game/Card.qml \
    qml/game/Deck.qml \
    qml/game/Depot.qml \
    qml/game/GameLogic.qml \
    qml/game/PlayerHand.qml \
    qml/game/Removed.qml \
    qml/interface/Chat.qml \
    qml/interface/GameOverWindow.qml \
    qml/interface/LeaveGameWindow.qml \
    qml/interface/LikeWindow.qml \
    qml/interface/PlayerInfo.qml \
    qml/interface/PlayerTag.qml \
    qml/interface/SwitchNameWindow.qml \
    qml/scenes/CardScene.qml \
    qml/scenes/GameNetworkScene.qml \
    qml/scenes/GameScene.qml \
    qml/scenes/InstructionScene.qml \
    qml/scenes/LoadingScene.qml \
    qml/scenes/MenuScene.qml \
    qml/scenes/MultiplayerScene.qml
