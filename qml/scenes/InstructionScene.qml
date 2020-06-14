import Felgo 3.0
import QtQuick 2.0
import "../common"

// scene describing the game rules
SceneBase {
    id: instructionScene

    signal menuButtonPressed(string button)


    // background
    Image {
        id: background
        source: "../../assets/img/BG.png"
        anchors.fill: instructionScene.gameWindowAnchorItem
        fillMode: Image.PreserveAspectCrop
        smooth: true
    }

    // content window
    Rectangle {
        id: infoRect
        radius: 25
        anchors.centerIn: gameWindowAnchorItem
        width: gameWindowAnchorItem.width - 50
        height: gameWindowAnchorItem.height - 50
        color: "white"
        border.color: "black"
        border.width: 2.5
        //}

        // credits
        //Text {
        //    anchors.bottom: infoRect.bottom
        //    anchors.bottomMargin: 5
        //    anchors.right: infoRect.right
        //    anchors.rightMargin: 15
        //    font.pixelSize: 6
        //    color: "black"
        //    text: "Artwork: Felgo.com"
        }

        // the header
        Text {
            anchors.horizontalCenter: gameWindowAnchorItem.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.top: gameWindowAnchorItem.top
            anchors.topMargin: 60
            font.pixelSize: 20
            font.family: standardFont.name
            color: "black"
            text: "Instructions"
        }

        // row with the main game rules
        Row {
            spacing: 10
            anchors.horizontalCenter: gameWindowAnchorItem.horizontalCenter
            anchors.top: gameWindowAnchorItem.top
            anchors.topMargin: 100

            // objectives
            Column {
                spacing: 4

                Image {
                    width: 40
                    height: 40
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: "../../assets/img/Objective.png"
                    smooth: true
                }

                Text {
                    font.pixelSize: 10
                    color: "black"
                    text: "Objectives"
                    font.family: standardFont.name
                }

                Text {
                    font.pixelSize: 9
                    color: "black"
                    width: 100
                    wrapMode: Text.WordWrap
                    text: "Get rid of all cards in your hand before your opponents. When it is your turn, match or trump the card on the Discard pile by number. Some cards have special abilities."
                }
            }

            // choose your bunkercards
            Column {
                spacing: 2

                Rectangle {
                    id: handRect
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 62
                    height: 29
                    color: "transparent"
                    opacity: 0.5
                    border.color: "black"
                    border.width: 0.5
                    radius: 2
                    z: 0


                    Text {
                        id:handText
                        transformOrigin: Item.BottomLeft
                        //anchors.left: parent.left
                        rotation : -90
                        anchors.fill:parent
                        anchors.leftMargin: 5
                        anchors.bottomMargin: 3
                        font.family: "Tahoma"
                        font.pointSize: 3
                        text:  qsTr("hand")
                        verticalAlignment: Text.AlignBottom
                    }
                    Image {
                        id: leftImageHand
                        height: parent.height-3
                        fillMode: Image.PreserveAspectFit
                        anchors.right: centerImageHand.left
                        anchors.rightMargin: 2
                        anchors.verticalCenter: parent.verticalCenter
                        source: "../../assets/img/cards/10_pik.png"
                        smooth: true
                    }
                    Image {
                        id : centerImageHand
                        height: parent.height-3
                        fillMode: Image.PreserveAspectFit
                        anchors.right: rightImageHand.left
                        anchors.rightMargin: 2
                        anchors.verticalCenter: parent.verticalCenter
                        source: "../../assets/img/cards/2_karo.png"
                        smooth: true
                    }

                    Image {
                        id: rightImageHand
                        height: parent.height-3
                        fillMode: Image.PreserveAspectFit
                        anchors.right: parent.right
                        anchors.rightMargin: 2
                        anchors.verticalCenter: parent.verticalCenter
                        source: "../../assets/img/cards/14_pik.png"
                        smooth: true
                    }

                }


                Rectangle {
                    id: chinaRect
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 62
                    height: 29
                    color: "transparent"
                    opacity: 0.5
                    border.color: "black"
                    border.width: 0.5
                    radius: 2
                    z: 0

                    Text {
                        id:bunkerText
                        transformOrigin: Item.BottomLeft
                        //anchors.left: parent.left
                        rotation : -90
                        anchors.fill:parent
                        anchors.leftMargin: 5
                        anchors.bottomMargin: 3
                        font.family: "Tahoma"
                        font.pointSize: 3
                        text:  qsTr("bunker")
                        verticalAlignment: Text.AlignBottom
                    }
                    Image {
                        id: leftImageBunker
                        height: parent.height-3
                        fillMode: Image.PreserveAspectFit
                        anchors.right: centerImageBunker.left
                        anchors.verticalCenter: parent.verticalCenter
                        source: "../../assets/img/cards/12_kreuz.png"
                        smooth: true
                    }
                    Image {
                        id : centerImageBunker
                        height: parent.height-3
                        fillMode: Image.PreserveAspectFit
                        anchors.right: rightImageBunker.left
                        anchors.verticalCenter: parent.verticalCenter
                        source: "../../assets/img/cards/10_herz.png"
                        smooth: true
                    }

                    Image {
                        id: rightImageBunker
                        height: parent.height-3
                        fillMode: Image.PreserveAspectFit
                        anchors.right: parent.right
                        anchors.rightMargin: 1
                        anchors.verticalCenter: parent.verticalCenter
                        source: "../../assets/img/cards/9_pik.png"
                        smooth: true
                    }

                }

                Text {
                    font.pixelSize: 10
                    color: "black"
                    text: "Optimize Hand"
                    font.family: standardFont.name
                }

                Text {
                    font.pixelSize: 9
                    color: "black"
                    width: 100
                    wrapMode: Text.WordWrap
                    text: "Switch your hand and bunker cards in an attempt to produce a strong set of face-up cards."
                }
            }

            Column {
                spacing: 5

                Image {
                    width: 50
                    height: 50
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: "../../assets/img/4of4.png"
                    smooth: true
                }

                Text {
                    font.pixelSize: 10
                    color: "black"
                    text: "4/4 remove"
                    font.family: standardFont.name
                }

                Text {
                    font.pixelSize: 9
                    color: "black"
                    width: 100
                    wrapMode: Text.WordWrap
                    text: "Place four cards with the same numerical value, this removes the discards in the same manner as a ten."
                }
            }

            // Joker button
            Column {
                spacing: 5

                Image {
                    width: 40
                    height: 40
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: "../../assets/img/JokerInstruct.png"
                    smooth: true
                }

                Text {
                    font.pixelSize: 10
                    color: "black"
                    text: "Joker Button"
                    font.family: standardFont.name
                }

                Text {
                    font.pixelSize: 9
                    color: "black"
                    width: 100
                    wrapMode: Text.WordWrap
                    text: "Press the Joker to pick up the depot, even if you are able to discard one card. You can do this only once per game."
                }
            }
        }


    // switch between the scenes with swipe motions
    SwipeArea {
        anchors.fill: parent
        onSwipeRight: cardButton.clicked()
        onSwipeLeft: backButtonPressed()
    }

    // back button to leave scene
    ButtonBase {
        width: 25
        height: 25
        buttonImage.source: "../../assets/img/ArrowLeft.png"
        anchors.left: gameWindowAnchorItem.left
        anchors.leftMargin: 10
        anchors.bottom: gameWindowAnchorItem.bottom
        anchors.bottomMargin: 10
        onClicked: {
            backButtonPressed()
        }
    }

    // button to cardScene
    MenuButton {
        id: cardButton
        action: "cards"
        color: "transparent"
        width: 25
        height: 25
        buttonImage.source: "../../assets/img/ArrowRight.png"
        anchors.right: gameWindowAnchorItem.right
        anchors.rightMargin: 10
        anchors.bottom: gameWindowAnchorItem.bottom
        anchors.bottomMargin: 10
    }

    onVisibleChanged: {
        if(visible) {
        }
    }
}
