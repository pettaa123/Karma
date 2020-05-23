# allows to add DEPLOYMENTFOLDERS and links to the Felgo library and QtCreator auto-completion
CONFIG += felgo

# uncomment this line to add the Live Client Module and use live reloading with your custom C++ code
# for the remaining steps to build a custom Live Code Reload app see here: https://felgo.com/custom-code-reload-app/
# CONFIG += felgo-live

# Project identifier and version
# More information: https://felgo.com/doc/felgo-publishing/#project-configuration
PRODUCT_IDENTIFIER = net.altocinco.cards.SHITHEAD
PRODUCT_VERSION_NAME = 0.0.1
PRODUCT_VERSION_CODE = 1

# Optionally set a license key that is used instead of the license key from
# main.qml file (App::licenseKey for your app or GameWindow::licenseKey for your game)
# Only used for local builds and Felgo Cloud Builds (https://felgo.com/cloud-builds)
# Not used if using Felgo Live
PRODUCT_LICENSE_KEY = "A7E64A57ED9981908EEB122D1F09A60C7B10BF71AABA6F01862265395B2868B119EC71B77FFC44AECE81E7B3CAC9F60E3A78C36DAB65A8CE5D6659790610A692ABB6948E3FFA441C156C7D44AFD6DD818433DFA1165C06086DAA87DEF9A47055BBE369AFC31BBBC331AC13E0103E37AA5C95258D22BB5D5FB03690B1A800C0C7A483E82B412C435400FDF4E55E44F50F1F4EB6B5B52F22EA9663EE37473FB580A9B9A0C7657A9F8DE18C145F1DBFE4C115B16809FB7C4384DDD8DCBA532B8B2BD9967CFE27A03A8B5B2405588355CAB3A4861E94C24F692568F72B591EBD0376B96E24CE0A4F14AE9A64FADDBEC3180C25541E647D2359A598E56A1D2A75BF758EA902E97AE4B51040F869A9FB91E9770494DCAE173865F65A150EE446F4AAED27CB576D16299AC06936B5861F42CC35"

QT += websockets

qmlFolder.source = qml
DEPLOYMENTFOLDERS += qmlFolder # comment for publishing

assetsFolder.source = assets
DEPLOYMENTFOLDERS += assetsFolder

# Add more folders to ship with the application here

RESOURCES += #    resources.qrc # uncomment for publishing

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

    # Uncomment for using iOS plugin libraries
    # FELGO_PLUGINS += facebook onesignal flurry admob chartboost soomla
}

DISTFILES += \
    qml/game/Removed.qml \
    qml/scenes/CardScene.qml \
    qml/scenes/InstructionScene.qml
