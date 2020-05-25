import Felgo 3.0
import QtQuick 2.12
import "../common"
import "../game"
import "../interface"

SceneBase {
    id: gameScene
    height: 640
    width: 960

    // game signals
    signal cardSelected(var cardId)

    // access the elements from outside
    property alias deck: deck
    property alias depot: depot
    property alias gameLogic: gameLogic
    property alias gameOver: gameOver
    property alias leaveGame: leaveGame
    property alias switchName: switchName
    property alias bottomHand: bottomHand
    property alias playerInfoPopup: playerInfoPopup
    property alias rightPlayerTag: rightPlayerTag // ad banner will be aligned based on rightPlayerTag

    property alias jokerButton: jokerButton


    // connect to the FelgoMultiplayer object and handle all signals
    Connections {
        // this is important! only handle the messages when we are currently in the game scene
        // otherwise, we would handle the playerJoined signal when the player is still in matchmaking view!
        // do not use the visible property here! as visible only gets triggered with the opacity animation in SceneBase
        target: multiplayer
        enabled: activeScene === gameScene

        onPlayerJoined: {
            console.debug("GameScene.onPlayerJoined:", JSON.stringify(player))
            console.debug(multiplayer.localPlayer.name + " is leader? " + multiplayer.amLeader)

            // send a new message with the new sync value to the new player (or actually to all), as we now support late-joins of the game
            if(multiplayer.amLeader && activeScene === gameScene) {
                console.debug("Leader send game state to player")
                gameLogic.sendGameStateToPlayer(player.userId)

            }
        }

        onPlayerChanged: {

        }

        onPlayersReady: {

        }

        onGameStarted: {

        }

        onPlayerLeft:{

        }

        onLeaderPlayerChanged:{
            console.debug("leaderPlayer changed to:", multiplayer.leaderPlayer)
        }

        onActivePlayerChanged:{
        }

        onTurnStarted:{
            gameLogic.turnStarted(playerId)
        }
    }


    // background
    Image {
        id: background
        source: "../../assets/img/BG.png"
        anchors.fill: gameScene.gameWindowAnchorItem
        fillMode: Image.PreserveAspectCrop
        smooth: true
    }

    // contains all game logic functions
    GameLogic {
        id: gameLogic
    }

    // lose keyboard focus after clicking outside of the chat
    MouseArea {
        id: unfocus
        anchors.fill: gameWindowAnchorItem
        enabled: chat.inputText.focus
        onClicked: chat.inputText.focus = false
        z: multiplayer.myTurn ? 0 : 150
    }

    // back button to leave scene
    ButtonBase {
        id: backButton
        width: 50
        height: 50
        buttonImage.source: "../../assets/img/Home.png"
        anchors.right: gameWindowAnchorItem.right
        anchors.rightMargin: 10
        anchors.bottom: gameWindowAnchorItem.bottom
        anchors.bottomMargin: 5
        onClicked: leaveGame.visible = true
    }

    // back button to leave scene
    ButtonBase {
        id: jokerButton
        width: 90
        height: 90
        buttonImage.source: "../../assets/img/Joker.png"
        anchors.right: gameWindowAnchorItem.right
        anchors.rightMargin: 10
        anchors.bottom: backButton.top
        anchors.bottomMargin: 75
        //anchors.bottom: gameWindowAnchorItem.bottom
        //anchors.bottomMargin: 5
        onClicked: {

            if(gameLogic.joker())            jokerButton.visible=false
        }
        z:500

        property alias shaker: shaker

        SequentialAnimation {
            alwaysRunToEnd: true
            loops:2
            id: shaker
            running: false
            NumberAnimation { target: jokerButton; property: "rotation";to: rotation+3; duration: 50 }
            NumberAnimation { target: jokerButton; property: "rotation";to: rotation-3; duration: 50 }
            NumberAnimation { target: jokerButton; property: "rotation";to: rotation; duration: 50 }
        }
    }



    // button to finish the game
    // the player who clicked the button will be the winner
    // for debug purposes
    ButtonBase {
        text: "Close\nRound"
        width: buttonText.contentWidth + 30
        visible: system.debugBuild && !gameLogic.gameOver
        anchors.horizontalCenter: GameWindow.horizontalCenter
        anchors.bottom: depot.top
        anchors.bottomMargin: 20
        onClicked: {
            gameLogic.endGame(multiplayer.localPlayer.userId)
            multiplayer.sendMessage(gameLogic.messageEndGame, {userId: multiplayer.localPlayer.userId, test: true})
        }
    }
    ButtonBase {
        text: "Switch Name"
        //width: buttonText.contentWidth + 30
        // for testing the switch name dialog, only for debugging
        visible: system.debugBuild
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 10
        z: 1
        onClicked: {
            switchName.visible = true
        }
    }

    // the deck on the right of the depot
    Deck {
        id: deck
        anchors.verticalCenter: depot.verticalCenter
        anchors.left: depot.right
        anchors.leftMargin: 90
    }

    // the four playerHands placed around the main game field
    Item {
        id: playerHands
        anchors.fill: gameWindowAnchorItem

        PlayerHand {
            id: bottomHand
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            z: 100
        }

        PlayerHand {
            id: leftHand
            anchors.left: parent.left
            anchors.leftMargin: -width/2 + height/2
            anchors.verticalCenter: parent.verticalCenter
            rotation: 90
        }

        PlayerHand {
            id: topHand
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            rotation: 180
        }

        PlayerHand {
            id: rightHand
            anchors.right: parent.right
            anchors.rightMargin: -width/2 + height/2
            anchors.verticalCenter: parent.verticalCenter
            rotation: 270
        }
    }

    // the depot in the middle of the game field
    Depot {
        id: depot
        //anchors.centerIn: gameWindowAnchorItem
        anchors.horizontalCenter: gameWindowAnchorItem.horizontalCenter
        anchors.bottom: gameWindowAnchorItem.bottom
        anchors.bottomMargin: move()

        function move(){
            return(gameWindowAnchorItem.height - depot.height ) / 2 + (bottomHand.height - bottomHand.originalHeight) / 2.5
        }
    }

    // the playerTags for each playerHand
    Item {
        id: playerTags
        anchors.fill: gameWindowAnchorItem

        PlayerTag {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5
            anchors.right: parent.right
            anchors.rightMargin: (parent.width - bottomHand.width) / 2 - width * 0.8
        }

        PlayerTag {
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.top: parent.top
            anchors.topMargin: 10
        }

        PlayerTag {
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: (parent.width - topHand.width) / 2 - width
        }

        PlayerTag {
            id: rightPlayerTag
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.top: parent.top
            anchors.topMargin: 10
        }
    }

    // the gameOver message in the middle of the screen
    GameOverWindow {
        anchors.centerIn: gameWindowAnchorItem
        id: gameOver
        visible: false
    }

    // the gameOver message in the middle of the screen
    SwitchNameWindow {
        anchors.centerIn: gameWindowAnchorItem
        id: switchName
        visible: false
    }

    // the playerInfoPopup shows detailed information of a user
    PlayerInfo {
        id: playerInfoPopup
        anchors.centerIn: gameWindowAnchorItem
        refTag: playerTags.children[0]
    }

    // the leaveGame message in the middle of the screen
    LeaveGameWindow {
        anchors.centerIn: gameWindowAnchorItem
        id: leaveGame
        visible: false
    }

    // chat on the bottom left corner for all connected players
    Chat {
        id: chat
        height: gameWindowAnchorItem.height - bottomHand.width / 2
        width: (gameWindowAnchorItem.width - bottomHand.width) / 2 - 20
        anchors.left: gameWindowAnchorItem.left
        anchors.leftMargin: 20
        anchors.bottom: gameWindowAnchorItem.bottom
        anchors.bottomMargin: 20
    }

    // init the game after switching to the gameScene
    onVisibleChanged: {
        if(visible){
            gameLogic.initGame()
        }
    }
}
