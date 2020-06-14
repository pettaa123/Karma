# allows to add DEPLOYMENTFOLDERS and links to the Felgo library and QtCreator auto-completion
CONFIG += felgo
CONFIG += c++11

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
PRODUCT_LICENSE_KEY = "33A5BD15029EDFE6AF6AF969C029F7786A1C304D56C89FC73C5E36188F5B1AE06FF53FB58F5C61CE57691DD9F4B8F17F8CC9B62D5E3A8609F9834FD1299F83177A99EDC4255310E92F817EA57D9D4EFC54D98F2B6EBA794AF00C5D6A74C09258346A843B4F37F5D488365FF0FA0B07F1D84AEDD05AC8203AAB5DB4DCE8BA0B8475774E1EA91B31E9D93D4222145B45D7CB3D4A86D36BEEF4113797F87C3401AA0F917B0680AC19682579201C77303D7BEADB2245A4E45483D807764516BC868E86B66CF619D4D58D7D7F12A927A1AA2EE06284AF90D0E57492BF003C6A72DFD4E0112C97CF215DEBAACA77F0BFF3CA44B7B043B137D7177CB6257AB43E46E7DFBAF9E0CDEF8315DAF8664FB485D8B2425F4B92CBED621599495EA19E28C372F1FEE0BD20B2AF136C02577D07DE80321482F5E6953E0298788E40D6F1F252F1EBDC9F18E619E825BA764E5FBAF59F9426"

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
