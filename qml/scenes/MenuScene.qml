import QtQuick 2.12
import QtQuick.Controls 1.4
import Felgo 3.0
import "../common"
import "../interface"

SceneBase {
  id: menuScene

  // signal that indicates that other scenes should be displayed
  signal menuButtonPressed(string button)

  property alias localStorage: localStorage   // is used by ONUMain to access gamesPlayed counter
  //property alias tokenInfo: tokenInfo         // used by ONUMainItem to trigger tokenInfo animation
  //property bool _initialTokens: false         // is set to true when user gets initial tokens

  // background music
  //BackgroundMusic {
  //  volume: 0.20
  //  id: ambienceMusic
  //  source: "../../assets/snd/bg.mp3"
  //}

  // timer plays the background music
  //Timer {
  //  id: timerMusic
  //  interval: 100; running: true; repeat: true
  //  onTriggered: {
  //    ambienceMusic.play()
  //    running = false
  //  }
  //}

  // background
  Image {
    id: background
    source: "../../assets/img/BG.png"
    anchors.fill: menuScene.gameWindowAnchorItem
    fillMode: Image.PreserveAspectCrop
    smooth: true
  }

  // the title image
  Image {
    id: titleImage
    anchors.horizontalCenter: gameWindowAnchorItem.horizontalCenter
    anchors.top: gameWindowAnchorItem.top
    anchors.topMargin: 15
    source: "../../assets/img/Title.png"
    fillMode: Image.PreserveAspectFit
    width: 380
  }

  // button opens powered by Felgo message and links to the website
  MouseArea {
    anchors.top: titleImage.top
    anchors.bottom: titleImage.bottom
    anchors.left: titleImage.left
    anchors.leftMargin: 55
    anchors.right: titleImage.right
    anchors.rightMargin: 55
    width: 240
    height: 30

    onClicked: {
      website.visible = true
    }
  }

  // detailed playerInfo window
  Rectangle {
    id: info
    radius: 15
    color: "white"
    border.color: "#28a3c1"
    border.width: 2.5
    visible: true
    width: 130

    anchors {
      top: localTag.top
      bottom: localTag.bottom
      right: localTag.right
      topMargin: localTag.height / 2 - 9
      bottomMargin: - 6
      rightMargin: - 3
    }

    // detailed playerInfo text
    Item {
      y: 34

      Text {
        id: infoText
        text: "Rank: " + rank + "\nLevel: " + localTag.level + "\nScore: " + localTag.highscore
        font.family: standardFont.name
        color: "black"
        font.pixelSize: 8
        width: contentWidth
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 14
        verticalAlignment: Text.AlignVCenter

        property string rank: localTag.rank > 0 ? "#" + localTag.rank : "-"
      }
    }

    // clickable area to hide the detailed playerInfo
    MouseArea {
      anchors.fill: parent
      onClicked: info.visible ^= true
    }
  }

  // button leading to the profile view
  MenuButton {
    action: "profile"
    color: "transparent"
    width: 30
    height: 30
    buttonImage.source: "../../assets/img/Settings.png"
    anchors.bottom: gameWindowAnchorItem.bottom
    anchors.bottomMargin: 10
    anchors.right: info.left
    anchors.rightMargin: 5
    visible: info.visible
  }


  // local player tag
  PlayerTag {
    id: localTag
    player: gameNetwork.user
    nameColor: info.visible ? "#28a3c1" : "white"
    menu: true
    avatarSource: gameNetwork.user.profileImageUrl ? gameNetwork.user.profileImageUrl : "../../assets/img/User.png"
    level: Math.max(1, Math.min(Math.floor(gameNetwork.userHighscoreForCurrentActiveLeaderboard / 300), 999))
    highscore: gameNetwork.userHighscoreForCurrentActiveLeaderboard
    rank: gameNetwork.userPositionForCurrentActiveLeaderboard

    scale: 0.5
    transformOrigin: Item.BottomRight
    anchors.bottom: gameWindowAnchorItem.bottom
    anchors.bottomMargin: 10
    anchors.right: gameWindowAnchorItem.right
    anchors.rightMargin: 10

    infoButton.enabled: player.name != ""
    infoButton.onClicked: {
      info.visible ^= true
    }
  }

  // credits
  Text {
    anchors.bottom: gameWindowAnchorItem.bottom
    anchors.bottomMargin: 10
    anchors.right: gameWindowAnchorItem.right
    anchors.rightMargin: 10
    font.pixelSize: 6
    color: "white"
    text: "UNO © 2016 Matell, Inc."
    visible: false
  }

  // main menu
  Column {
    id: gameMenu
    anchors.top: titleImage.bottom
    anchors.topMargin: 10
    anchors.horizontalCenter: gameWindowAnchorItem.horizontalCenter
    spacing: 6

    MenuButton {
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Quick Game"
      action: "quick"
    }

    MenuButton {
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Matchmaking"
    }

    MenuButton {
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Single Player"
      action: "single"
      //visible: false
    }
  }

  // animation to slide the community menu in and out
  NumberAnimation {
    id: slideAnimation
    running: false
    target: community
    property: "anchors.bottomMargin"
    duration: 200
    to: 0
    easing.type: Easing.InOutQuad
  }

  // community submenu
  Column {
    id: community
    width: communityButton.width
    spacing: 4
    anchors.left: gameWindowAnchorItem.left
    anchors.leftMargin: 10
    anchors.bottom: gameWindowAnchorItem.bottom
    anchors.bottomMargin: (community.height - communityButton.height) * (-1) + 10

    // community button to slide the community submenu in and out
    ButtonBase {
      id: communityButton
      color: "transparent"
      width: 38
      height: 38
      buttonImage.source: "../../assets/img/More.png"

      property bool hidden: true

      onClicked: {
        hidden = !hidden
        slideMenu()
      }

      // slides the community menu in or out depending on the hidden
      function slideMenu(){
        if (hidden){
          slideAnimation.to = (community.height - communityButton.height) * (-1) + 10
          opacity = 1.0
        }else{
          slideAnimation.to = 10
          opacity = 0.6
        }
        slideAnimation.start()
      }
    }

    MenuButton {
      action: "friends"
      color: "transparent"
      width: communityButton.width
      height: communityButton.height
      anchors.margins: communityButton.anchors.margins
      buttonImage.source: "../../assets/img/Friends.png"
      opacity: communityButton.hidden ? 0 : 1
    }


    // button to share the game
    ButtonBase {
      color: "transparent"
      width: communityButton.width
      height: communityButton.height
      anchors.margins: communityButton.anchors.margins
      buttonImage.source: "../../assets/img/Share.png"
      visible: !system.desktopPlatform

      onClicked: {
        nativeUtils.share("Come and play " + gameTitle + " with me, the best multiplayer card game! My player name is " + gameNetwork.displayName, "https://felgo.com/one-download/")
      }
    }

    // music and sound effect toggle buttons
    Row {
      spacing: 4

      // button to toggle the sound effects
      ButtonBase {
        color: "transparent"
        width: communityButton.width
        height: communityButton.height
        anchors.margins: communityButton.anchors.margins
        buttonImage.source: "../../assets/img/Sound.png"
        opacity: settings.soundEnabled ? 1.0 :  0.6
        onClicked: {
          settings.soundEnabled ^= true
        }
      }
    }

  }

  // message and leaderboard buttons
  Row {
    anchors.bottom: gameWindowAnchorItem.bottom
    anchors.left: community.right
    anchors.bottomMargin: 10
    anchors.leftMargin: community.spacing
    spacing: community.spacing

    MenuButton {
      id: inboxButton
      action: "inbox"
      color: "transparent"
      width: communityButton.width
      height: communityButton.height
      anchors.margins: communityButton.anchors.margins
      buttonImage.source: "../../assets/img/Messages.png"
    }

    MenuButton {
      action: "leaderboard"
      color: "transparent"
      width: communityButton.width
      height: communityButton.height
      anchors.margins: communityButton.anchors.margins
      buttonImage.source: "../../assets/img/Network.png"
    }
  }

  // connect to the FelgoGameNetwork to handle new inbox entries
  Connections{
    target: gameNetwork

    onInboxEntriesChanged:{
      var conv = gameNetwork.inboxEntries
      var count = 0
      for(var i = 0; i < conv.length; i++){
        count += conv[i].unread_count
      }
      inboxButton.notification = count
    }
  }

  // define Storage item for loading/storing key-value data
  // ask the user for feedback after opening the app 5 times
  Storage {
    id: localStorage
    property int appStarts: 0
    property int gamesPlayed: 0 // store number of games played
    property real lastLogin: 0   // date (day) of last login (reward received)

    // update app starts counter
    Component.onCompleted: {
      // uncomment this to clear the storage
      //localStorage.clearValue("appstarts")
      //localStorage.clearValue("gamesplayed")
      //localStorage.clearValue("lastlogin")

      var nr = localStorage.getValue("appstarts")
      if(nr === undefined) nr = 0

      nr++
      localStorage.setValue("appstarts", nr)
      appStarts = nr

      // init or load gamesPlayed counter
      if(localStorage.getValue("gamesplayed") === undefined)
        localStorage.setValue("gamesplayed", 0)
      gamesPlayed = localStorage.getValue("gamesplayed")

      // init or load last login day
      if(localStorage.getValue("lastlogin") === undefined)
        localStorage.setValue("lastlogin", 0) // will be correctly set when first checked
      lastLogin = localStorage.getValue("lastlogin")
    }

    // set and store gamesPlayed locally
    function setGamesPlayed(count) {
      localStorage.setValue("gamesplayed", count)
      localStorage.gamesPlayed = count
    }

    // set and store last login day
    function setLastLogin(day) {
      localStorage.setValue("lastlogin", day)
      localStorage.lastLogin = day
    }
  }

  // sync messages on the main menu page
  onVisibleChanged: {
    if(visible){
      gameNetwork.api.inbox()
      gameNetwork.sync()
    }
  }


}
