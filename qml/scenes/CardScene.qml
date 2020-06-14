import Felgo 3.0
import QtQuick 2.0
import "../common"

// scene describes the main card types
SceneBase {
    id: cardScene

    signal menuButtonPressed(string button)


    // background
    Image {
        id: background
        source: "../../assets/img/BG.png"
        anchors.fill: cardScene.gameWindowAnchorItem
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
    }

    // credits
    Text {
        anchors.bottom: infoRect.bottom
        anchors.bottomMargin: 5
        anchors.right: infoRect.right
        anchors.rightMargin: 15
        font.pixelSize: 6
        color: "black"
        text: "Fonts: 1001FreeFonts.com, kamarashev.deviantart.com"
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
        text: "Cards"
    }

    // a row describing the main card types
    Row {
        spacing: 13
        anchors.horizontalCenter: gameWindowAnchorItem.horizontalCenter
        anchors.top: gameWindowAnchorItem.top
        anchors.topMargin: 100

        // skip card
        Column {
            spacing: 5

            Image {
                width: 37
                height: 60
                anchors.horizontalCenter: parent.horizontalCenter
                source: "../../assets/img/cards/8_pik.png"
                smooth: true
            }

            Text {
                font.pixelSize: 10
                color: "black"
                text: "Skip"
                font.family: standardFont.name
            }

            Text {
                font.pixelSize: 9
                color: "black"
                width: 65
                wrapMode: Text.WordWrap
                text: "The next player is skipped and unable to play a card."
            }
        }

        // lower
        Column {
            spacing: 5

            Image {
              width: 37
              height: 60
              anchors.horizontalCenter: parent.horizontalCenter
              source: "../../assets/img/cards/7_kreuz.png"
              smooth: true
           }

            Text {
                font.pixelSize: 10
                color: "black"
                text: "Lower"
                font.family: standardFont.name
            }

            Text {
                font.pixelSize: 9
                color: "black"
                width: 65
                wrapMode: Text.WordWrap
                text: "Next card lower or equal to seven."
            }
        }

        // transparent card
        Column {
            spacing: 5

            Image {
              width: 37
              height: 60
              anchors.horizontalCenter: parent.horizontalCenter
              source: "../../assets/img/cards/3_karo.png"
              smooth: true
            }

            Text {
                font.pixelSize: 10
                color: "black"
                text: "Transparent"
                font.family: standardFont.name
            }

            Text {
                font.pixelSize: 9
                color: "black"
                width: 65
                wrapMode: Text.WordWrap
                text: "Threes are wilds and considered transparent. The next card has to obey the one under the three."
            }
        }

        // wildcards
        Column {
            spacing: 5
            Row{
                spacing: 5
                Image {
                    id: wild2
                    fillMode: Image.PreserveAspectFit
                    height: 60
                    source: "../../assets/img/cards/2_karo.png"
                    smooth: true
                }

                Image {
                    id:wild10
                    fillMode: Image.PreserveAspectFit
                    height: 60
                    anchors.verticalCenter: wild2.verticalCenter
                    source: "../../assets/img/cards/10_herz.png"
                    smooth: true
                }
            }

            Text {
                font.pixelSize: 10
                color: "black"
                text: "Wildcards"
                font.family: standardFont.name
            }

            Text {
                font.pixelSize: 9
                color: "black"
                width: 150
                wrapMode: Text.WordWrap
                text: "Twos and tens are wildcards and can be played on any card. No restrictions after two. Ten removes depot and starts another turn for same player."
            }
        }
    }

    // switch between the scenes with swipe motions
    SwipeArea {
        anchors.fill: parent
        onSwipeRight: menuButton.clicked()
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

    // button to main menu
    MenuButton {
        id: menuButton
        action: "menu"
        color: "transparent"
        width: 25
        height: 25
        buttonImage.source: "../../assets/img/Exit.png"
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
