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
PRODUCT_LICENSE_KEY = "CF1A3A9276DEE33B42302670D49A3C09404F8002C9422DEAB1A0F9A9D9FFEDD7562BF5BD59F64CFBF2FDFAE246C484B931DC546257F73188B984ADF8E97B60549C2263221FF2621E5FCCD2019687175DADE8BB78BF374DF4404BC0D48D599DFDA0529A9B63F2F65DE10A01211ACC3C5F50CAB949E464B070BE9E1494C3F9C3B1A62FF41D996C9BB0A341D37B7D8FBB4D7BF986DE1155F5EAC03E160B3092AA38C16AFDBEEE9B9F3B11D135AFA27840BB3CE63F26D30C2828C74EE34C13DA6BACBBC2EA1BE5BC52C1A551F254E0FD0EAB5FF7B508499937CC50628DEAD15A0FD7405A108C4B7F60091011876184E9F301789FE5539603CCBE184FEA9C32EBD1A3FF8FF47CCD15D1ED9C85F558BFACA732B9B83210A359EE75B291C016B362EBD13FF065BC318D0742BDE50CF40CD1DF76C3C301A396EC2BCB408AFB5176AD377FDCE020F46F1DCFA9F5E34399F15F6000"

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

    #ios_icon.files = $$files($$PWD/ios/Icon*.png)
    #QMAKE_BUNDLE_DATA += ios_icon

    # Uncomment for using iOS plugin libraries
    # FELGO_PLUGINS += facebook onesignal flurry admob chartboost soomla
}

DISTFILES += \
    qml/game/Removed.qml \
    qml/scenes/CardScene.qml \
    qml/scenes/InstructionScene.qml
