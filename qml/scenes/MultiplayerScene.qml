import Felgo 3.0
import QtQuick 2.0
import "../common"

SceneBase {
  id: multiplayerScene
  property alias state: multiplayerview.state
  property alias mpView: multiplayerview

  MultiplayerView{
    gameNetworkItem: gameNetwork
    tintColor: "black"

    id: multiplayerview

    onBackClicked: {
      backButtonPressed()
    }

    onShowCalled: {
      window.state = "multiplayer"
    }
  }


  function show(state){
    multiplayerview.show(state)
  }
}
