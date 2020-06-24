import Felgo 3.0
import QtQuick 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 1.4
import "../common"

SceneBase {
  id: gameNetworkScene

  property alias gnView: myGameNetworkView


  GameNetworkView {
    id: myGameNetworkView
    onBackClicked: {
        myGameNetworkView.visible = false
        window.state = "menu"
    }
    gameNetworkItem: gameNetwork
    state: "leaderboard"
    tintColor: "grey"
    anchors.fill: gameWindowAnchorItem

    onShowCalled: {
      myGameNetworkView.visible = true
    }
  }


}


