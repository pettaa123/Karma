# allows to add DEPLOYMENTFOLDERS and links to the Felgo library and QtCreator auto-completion
CONFIG += felgo
CONFIG += c++11

# uncomment this line to add the Live Client Module and use live reloading with your custom C++ code
# for the remaining steps to build a custom Live Code Reload app see here: https://felgo.com/custom-code-reload-app/
# CONFIG += felgo-live

# Project identifier and version
# More information: https://felgo.com/doc/felgo-publishing/#project-configuration
PRODUCT_IDENTIFIER = de.altocinco.cards.shithead
PRODUCT_VERSION_NAME = 1
PRODUCT_VERSION_CODE = 1

# Optionally set a license key that is used instead of the license key from
# main.qml file (App::licenseKey for your app or GameWindow::licenseKey for your game)
# Only used for local builds and Felgo Cloud Builds (https://felgo.com/cloud-builds)
# Not used if using Felgo Live
PRODUCT_LICENSE_KEY = "E516B373F78007BE87C434CE2CB7EE8E743E629F66FAE9692A5B98CCB7BAD509C1C0F353D3FFD975199C7B941B002D830BFE2D7B075C18E657BB29C7FCA703E78071859FFE5FAF4834F070AB3ED3055B7D150C907D816CE5ABC2CC8D0B0E64999EBFAEFB5EF9F625B039971C4D7F20387884DA8B87F337F7884B30CA3FC0710EE86142F68C24D1C1EA33FC367069AA4D68FFA5C7FFF9594D01C8CB3789E8F50645A4C02B11012DC0CFAC3C18984303DA497FCBAD0CF1DD771DC98CF62D2004F185D4A6CF8A16372E208E4517BB176A40909C462940F8985BCC5A745B0E14180D923F81418223488C8624CAD36C4309D6A20E164C201D878DF818A8770D2A2E9731C3DBE02FF39BB1D57E3CEBE726D13C8DCA773A6E396BF652AA6C2DC1B45A8433B7FEB7EA2B4F2C7D506A95E00CE21657010C0BAFD1381E53AFF634A746A52BC9919289BF9E888AAE634425DD16C6EF"

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
