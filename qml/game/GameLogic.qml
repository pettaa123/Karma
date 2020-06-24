import QtQuick 2.12
import Felgo 3.0

Item {
    id: gameLogic

    property bool singlePlayer: false
    property bool initialized: false
    onInitializedChanged: console.debug("GameLogic.initialized changed to:", initialized)
    // the remaining turn time for the active player
    property double remainingTime
    // turn time for the active player, in seconds
    // do not set this too low, otherwise players with higher latency could run into problems as they get skipped by the leader
    property int userInterval: getUserInterval()
    // turn time for AI players, in milliseconds
    property int aiTurnTime: 1200
    // restart the game at the end after a few seconds
    property int restartTime: 9000
    property bool acted: false
    property bool gameOver: false

    property bool fourSames: false
    property bool firstRound: true

    property int messageSyncGameState: 0
    property int messageRequestGameState: 1
    property int messageMoveCardsHand: 2
    property int messageMoveCardDepot: 3

    property int messageSetSkipped: 5

    property int messageEndGame: 10 // we could replace this custom message with the new  function from multiplayer, custom end game message was sent before this functionality existed
    property int messagePrintChat: 11
    property int messageSetPlayerInfo: 12
    property int messageTriggerTurn: 13
    property int messageRequestPlayerTags: 14

    property int messageMoveDepotToHand: 15
    //property int messageIncreaseRemainingTime:12
    property int messageRemoveDepot: 16
    property int messageResetCurrentAndLast: 17
    property int messageMoveCardIdToHand: 18
    property int messageSetDone: 19
    property int messageSetFirstRound: 20
    property int messageExchangeCards: 21
    property int messageIThinkImDone: 22

    // gets set to true when a message is received before the game state got synced. in that case, request a new game state
    property bool receivedMessageBeforeGameStateInSync: false

    // win sound
    SoundEffect {
        volume: 0.5
        id: winSound
        source: "../../assets/snd/juhu.wav"
    }

    // win sound
    SoundEffect {
        volume: 0.5
        id: loserSound
        source: "../../assets/snd/ohno.wav"
    }

    //knock sound
    SoundEffect {
        volume: 0.3
        id: knockSound
        source: "../../assets/snd/knock.wav"
    }

    Timer {
        id: waitTimerScaleHand
        repeat:false
        interval:100
        property var scale
        onTriggered: {
            waitTimerScaleHand.stop()
            scaleHand(scale)
        }
    }

    // timer decreases the remaining turn time for the active player
    Timer {
        id: timer
        repeat: true
        running: !gameOver && initialized
        interval: 1000

        onTriggered: {
            remainingTime -= 1
            // let the AI play for the connected player after 10 seconds
            if (remainingTime === 0) {
                gameLogic.turnTimedOut()
            }
            // mark the valid card options for the active player
            //if (multiplayer.myTurn){
            //    markValid()
            //    scaleHand()
            //}
            // repaint the timer circle on the playerTag every second
            for (var i = 0; i < playerTags.children.length; i++){
                playerTags.children[i].canvas.requestPaint()
            }
        }
    }

    Timer {
        id:waitTimerGameOver
        repeat: false
        interval: 1000
        onTriggered: {
            waitTimerGameOver.stop()
            gameScene.gameOver.visible = true
        }
    }

    // AI takes over after a few seconds if the player is not connected
    Timer {
        id: aiTimeOut
        interval: aiTurnTime
        repeat: false
        onTriggered: {
            aiTimeOut.stop()
            gameLogic.executeAIMove()
            //endTurn()
        }
    }

    // start a new match after a few seconds
    Timer {
        id: restartGameTimer
        interval: restartTime
        onTriggered: {
            restartGameTimer.stop()
            startNewGame()
        }
    }

    // blocks the player if multiple cards could be layn for a short period of time and trigger a new turn when he doesnt pick another card
    Timer {
        id: waitInputTimer
        repeat: false
        interval: 1800
        onTriggered: {
            acted=true
            waitInputTimer.stop()
            endTurn()
        }
    }

    Timer {
        id: waitBeforeNewTurn
        repeat:false
        interval: 2500
        onTriggered: {
            waitBeforeNewTurn.stop()
            multiplayer.triggerNextTurn()
        }
    }



    // connect to the FelgoMultiplayer object and handle all messages
    Connections {
        // this is important! only handle the messages when we are currently in the game scene
        // otherwise, we would handle the playerJoined signal when the player is still in matchmaking view!
        // do not use the visible property here! as visible only gets triggered with the opacity animation in SceneBase
        target: multiplayer
        enabled: activeScene === gameScene

        onGameStarted: {
            // the gameStarted signal is received by the client as well not only by the leader, otherwise we would not realize when a new game starts
            // otherwise only the leader would trigger a "User.RestartGame" event
            // this is called internally though, thus make it a system event
            if(gameRestarted) {
                gameScene.jokerButton.visible = true
                console.debug("Game restarted")
            }
        }


        onAmLeaderChanged: {
            if (multiplayer.leaderPlayer){
                console.debug("Current Leader is: " + multiplayer.leaderPlayer.userId)
            }
            if(multiplayer.amLeader) {
                console.debug("this player just became the new leader")
                if(!timer.running && !gameOver) {
                    console.debug("New leader selected, but the timer is currently not running, thus trigger a new turn now")
                    // even when we comment this, the game does not stall 100%, thus it is likely that we would skip a player here. but better to skip a player once and make sure the game is continued than stalling the game. hard to reproduce, as it does not happen every time the leader changes!
                    triggerNewTurn()
                } else if (!timer.running){
                    restartGameTimer.restart()
                }
            }
        }

        onMessageReceived: {
            console.debug("onMessageReceived with code", code, "initialized:", initialized)

            var tempMessage=message

            if(!initialized && code !== messageSyncGameState) {
                console.debug("ERROR: received message before gameState was synced and user is not initialized:", code, message)

                if (tempMessage.receiverPlayerId === multiplayer.localPlayer.userId && !compareGameStateWithLeader(tempMessage.playerHands)) {
                    receivedMessageBeforeGameStateInSync = true
                }
                return
            }

            // sync the game state for existing and newly joined players
            if (code == messageSyncGameState) {
                if (!tempMessage.receiverPlayerId || tempMessage.receiverPlayerId === multiplayer.localPlayer.userId || !compareGameStateWithLeader(tempMessage.playerHands)) {
                    console.debug("Sync Game State now")
                    console.debug("Received Message: " + JSON.stringify(message))
                    // NOTE: the activePlayer can be undefined here, when the player makes a late-join! thus add a check in syncDepot() -> depositCard() and handle the case that it is undefined!
                    console.debug("multiplayer.activePlayer when syncing game state:", multiplayer.activePlayer)

                    syncPlayers()
                    initTags()
                    syncDeck(tempMessage.deck)
                    depot.syncDepot(tempMessage.depot,tempMessage.current,tempMessage.last ,tempMessage.multiple,tempMessage.skipped,tempMessage.checkLast)
                    depot.syncRemoved(tempMessage.removed)
                    syncHands(tempMessage.playerHands)


                    // join a game which is already over
                    gameOver = tempMessage.gameOver
                    firstRound = tempMessage.firstRound
                    gameScene.gameOver.visible = gameOver
                    timer.running = !gameOver

                    console.debug("finished syncGameState, setting initialized to true now")
                    initialized = true

                    // if we before received a message before game state was in sync, do request a new game state from the leader now
                    if(receivedMessageBeforeGameStateInSync) {
                        console.debug("requesting a new game state from server now, as receivedMessageBeforeGameStateInSync was true")
                        multiplayer.sendMessage(messageRequestGameState, multiplayer.localPlayer.userId)
                        receivedMessageBeforeGameStateInSync = false
                    }

                    // request the detailed playerTag info from the other players (highscore, level and badge)
                    // if the message was specifically sent to the local user (for example when he or she joins)
                    if (tempMessage.receiverPlayerId){
                        multiplayer.sendMessage(messageRequestPlayerTags, multiplayer.localPlayer.userId)
                    }
                }
            }
            // send a new game state to the requesting user
            else if (code == messageRequestGameState){
                multiplayer.leaderCode(function() {
                    sendGameStateToPlayer(tempMessage)
                })
            }
            // move card to hand
            else if (code == messageMoveCardsHand){
                // if there is an active player with a different userId, the message is invalid
                // the message was probably sent after the leader triggered the next turn
                if (multiplayer.activePlayer && multiplayer.activePlayer.userId !== tempMessage.userId){
                    multiplayer.leaderCode(function() {
                        console.debug("sendGameSateToPlayer from messageMoveCardsHand")
                        sendGameStateToPlayer(tempMessage.userId)
                    })
                    return
                }

                getCards(tempMessage.cards, tempMessage.userId,1000)
            }
            // move cardId from chinaHidden to hand
            else if (code == messageMoveCardIdToHand){
                // if there is an active player with a different userId, the message is invalid
                // the message was probably sent after the leader triggered the next turn
                if (multiplayer.activePlayer && multiplayer.activePlayer.userId !== tempMessage.userId){
                    multiplayer.leaderCode(function() {
                        console.debug("sendGameSateToPlayer from messageMoveCardIdToHand")
                        sendGameStateToPlayer(tempMessage.userId)
                    })
                    return
                }
                moveFromChinaHiddenToHand(tempMessage.userId,tempMessage.cardId,tempMessage.interval)
                takeDepot(tempMessage.userId,tempMessage.interval+1000)
            }



            else if (code == messageExchangeCards){
                //message too late, exchange cant be acknowledged
                if (!firstRound && tempMessage.userId!==multiplayer.leaderPlayer.userId){
                    multiplayer.leaderCode(function() {
                        sendGameStateToPlayer(tempMessage.userId)
                    })
                    return
                }

                for (var i = 0; i < playerHands.children.length; i++) {
                    if (playerHands.children[i].player.userId === tempMessage.userId){
                        playerHands.children[i].exchangeHandAndChinaCard(tempMessage.handCard,tempMessage.chinaCard)
                        playerHands.children[i].neatHand()
                        playerHands.children[i].neatChina()
                        break
                    }
                }

            }

            else if (code == messageSetDone){

                for (i = 0; i < playerHands.children.length; i++) {
                    if (playerHands.children[i].player.userId === tempMessage.userId){
                        playerHands.children[i].done=true
                        playerHands.children[i].firstDone=tempMessage.firstDone
                        if(multiplayer.localPlayer.userId===tempMessage.userId){
                            winSound.play()
                        }
                        break
                    }
                }
            }

            else if (code == messageIThinkImDone){

                if (multiplayer.activePlayer && multiplayer.activePlayer.userId !== tempMessage.userId){
                    multiplayer.leaderCode(function() {
                        console.debug("sendGameSateToPlayer from messageIThinkImDone")
                        sendGameStateToPlayer(tempMessage.userId)
                    })
                    return
                }

                multiplayer.leaderCode(function() {
                    //leader checks if player is really done
                    for (i = 0; i < playerHands.children.length; i++) {
                        if (playerHands.children[i].player.userId === tempMessage.userId){
                            if(playerHands.children[i].checkDone()){
                                playerHands.children[i].done=true
                                var firstDone=false
                                console.debug("ITHINKIMDONE message received")
                                console.debug("checkFirstDone: ")
                                if(checkFirstDone()){
                                    firstDone=true
                                    playerHands.children[i].firstDone=true
                                }
                                console.debug(firstDone)
                                multiplayer.sendMessage(messageSetDone, {userId: tempMessage.userId, firstDone: firstDone})
                            }
                            else{
                                sendGameStateToPlayer(tempMessage.userId)
                            }

                            break
                        }
                    }
                    if(checkShithead()){
                        endGame()
                        multiplayer.sendMessage(messageEndGame, {userId: multiplayer.localPlayer.userId})
                        return
                    }

                })


            }

            else if (code == messageRemoveDepot){
                // if there is an active player with a different userId, the message is invalid
                // the message was probably sent after the leader triggered the next turn
                if (multiplayer.activePlayer && multiplayer.activePlayer.userId !== tempMessage.userId){
                    multiplayer.leaderCode(function() {
                        console.debug("sendGameSateToPlayer from messageRemoveDepot")
                        sendGameStateToPlayer(tempMessage.userId)
                    })
                    return
                }
                removeDepot(tempMessage.interval,false)
            }

            // move card to depot
            else if (code == messageMoveDepotToHand){
                // if there is an active player with a different userId, the message is invalid
                // the message was probably sent after the leader triggered the next turn
                if (multiplayer.activePlayer && multiplayer.activePlayer.userId !== tempMessage.userId){
                    multiplayer.leaderCode(function() {
                        console.debug("sendGameSateToPlayer from messageMoveDepotToHand")
                        sendGameStateToPlayer(tempMessage.userId)
                    })
                    return
                }
                takeDepot(tempMessage.userId,tempMessage.interval)

            }

            // move card to depot
            else if (code == messageMoveCardDepot){
                // if there is an active player with a different userId, the message is invalid
                // the message was probably sent after the leader triggered the next turn
                if (multiplayer.activePlayer && multiplayer.activePlayer.userId !== tempMessage.userId){
                    multiplayer.leaderCode(function() {
                        console.debug("sendGameSateToPlayer from messageMoveCardDepot")
                        sendGameStateToPlayer(tempMessage.userId)
                    })
                    return
                }
                depositCard(tempMessage.cardId)
            }

            // sync skipped state
            else if (code == messageSetFirstRound){
                // if there is an active player with a different userId, the message is invalid
                // the message was probably sent after the leader triggered the next turn
                if (multiplayer.leaderPlayer.userId !== tempMessage.userId){
                    multiplayer.leaderCode(function() {
                        console.debug("sendGameSateToPlayer from messageSetSkipped")
                        sendGameStateToPlayer(tempMessage.userId)
                    })
                    return
                }
                firstRound = tempMessage.firstRoundBool
                knockSound.play()
                unshakeCards()
                scaleHand(1.0)
                gameLogic.startTurnTimer()
            }


            // game ends
            else if (code == messageEndGame){
                // if the message wasn't sent by the leader and
                // if it wasn't a desktop test and
                // if it wasn't sent by the active player, the message is invalid
                // the message was probably sent after the leader triggered the next turn
                if (multiplayer.leaderPlayer.userId !== tempMessage.userId &&
                        multiplayer.activePlayer && multiplayer.activePlayer.userId !== tempMessage.userId && !tempMessage.test){
                    return
                }

                endGame(tempMessage.userId)
            }
            // chat message
            else if (code == messagePrintChat){
                if (!chat.gConsole.visible){
                    chat.chatButton.buttonImage.source = "../../assets/img/Chat2.png"
                }
                chat.gConsole.printLn(message)
            }
            // set highscore and level from other players
            else if (code == messageSetPlayerInfo){
                updateTag(tempMessage.userId, tempMessage.level, tempMessage.highscore, tempMessage.rank)
            }
            // let the leader trigger a new turn
            else if (code == messageTriggerTurn){
                multiplayer.leaderCode(function() {
                    // the leader only stops the turn early if the requesting user is still the active player
                    if (multiplayer.activePlayer && multiplayer.activePlayer.userId === tempMessage){
                        triggerNewTurn()
                    }
                    // if the requesting user is no longer active, it means that he timed out according to the leader
                    // his last action happened after his turn and is therefore invalid
                    // the leader has to send the user a new game state
                    else {
                        console.debug("sendGameSateToPlayer from messageTriggerTurn")
                        sendGameStateToPlayer(tempMessage)
                    }
                })
            }
            // reset player tag info and send it to other player because it was requested
            /*
         Only the local user can access their highscore and rank from the leaderboard.
         This is the reason why we sync this information with messageSetPlayerInfo messages.
         Late join users have to request this information again after they initialize the game with a messageSyncGameState message.
         Another option would be to let the lea^der send highscore, rank and level of each user via messageSyncGameState.
      */
            else if (code == messageRequestPlayerTags){
                initTags()
            }
        }
    }

    // connect to the gameScene and handle all signals
    Connections {
        target: gameScene

        // the player selected a card
        onCardSelected: {
            var selectedCardState =entityManager.getEntityById(cardId).state

            //handle first Round
            if(firstRound){
                //check if selected card is in your hand

                if (selectedCardState !== "player" && selectedCardState !== "china" && selectedCardState !== "chinaHidden") {
                    return
                }
                for (var i = 0; i < playerHands.children.length; i++) {
                    if (playerHands.children[i].player === multiplayer.localPlayer){
                        if (!playerHands.children[i].inHandOrChina(cardId)) return
                        playerHands.children[i].shakeCard(cardId)
                        playerHands.children[i].exchangeShakingCard()
                        break
                    }
                }
                return
            }



            if (depot.multiple){
                if(entityManager.getEntityById(cardId).variationType !== depot.multiple) return
            }

            //var selectedCardState =entityManager.getEntityById(cardId).state
            if (selectedCardState !== "player" && selectedCardState !== "china" && selectedCardState !== "chinaHidden") {
                return
            }
            if (multiplayer.myTurn && !depot.skipped && initialized && !acted) {
                // deposit the valid card
                if (depot.validCard(cardId)){
                    waitInputTimer.stop()
                    var validIds=checkForMultiples(cardId)
                    depositCard(cardId)
                    acted = true
                    multiplayer.sendMessage(messageMoveCardDepot, {cardId: cardId, userId: multiplayer.localPlayer.userId})

                    if(validIds && validIds.length>1){ //give the player the chance to select a second card
                        depot.multiple=entityManager.getEntityById(cardId).variationType
                        if(depot.multiple.variationType!=="10"){
                            acted=false
                            waitInputTimer.restart()
                            return
                        }
                    }

                    for(i=0;i<playerHands.children.length;i++){
                        if (playerHands.children[i].player.userId===multiplayer.localPlayer.userId){
                            if(playerHands.children[i].checkDone()){
                                if(multiplayer.amLeader){
                                    playerHands.children[i].done=true
                                    winSound.play()
                                    var firstDone=false
                                    if(checkFirstDone()){
                                        playerHands.children[i].firstDone=true
                                        firstDone=true
                                    }
                                    multiplayer.sendMessage(messageSetDone, {userId: multiplayer.activePlayer.userId, firstDone: firstDone})
                                    if(checkShithead()){
                                        multiplayer.sendMessage(messageEndGame, {userId: multiplayer.localPlayer.userId})
                                        endGame()
                                        return
                                    }
                                }
                                else{
                                    playerHands.children[i].done=true
                                    multiplayer.sendMessage(messageIThinkImDone, {userId: multiplayer.activePlayer.userId})
                                }
                                break
                            }
                        }
                    }

                    if(depot.fourSames()){
                        multiplayer.sendMessage(messageRemoveDepot, {userId: multiplayer.localPlayer.userId, interval:1400})
                        removeDepot(1500,true)
                        return
                    }
                    endTurn()
                    return
                }


                //handle invalid china hidden cards
                for (i = 0; i < playerHands.children.length; i++) {
                    // find the playerHand for the active player
                    // if the selected card is in the playerHand of the active player
                    if (playerHands.children[i].inHand(cardId) && playerHands.children[i].hand.length===0
                            && playerHands.children[i].china.length===0){//check if valid also
                        var userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0
                        multiplayer.sendMessage(messageMoveCardIdToHand, {cardId: cardId, userId: userId, interval: 1500})
                        moveFromChinaHiddenToHand(playerHands.children[i].player.userId,cardId,1500)
                        takeDepot(userId,2500)
                        acted=true
                        return
                    }
                }
                //if card in hand but not valid shake it
                for (i = 0; i < playerHands.children.length; i++) {
                    if (playerHands.children[i].player === multiplayer.activePlayer){
                        if (playerHands.children[i].inHand(cardId)){
                            var card=entityManager.getEntityById(cardId)
                            card.shake()
                        }
                    }
                }
            }
        }
    }


    Timer{
        id: waitTimerMoveFromChinaHiddenToHand
        interval: 1000
        repeat: false
        property var userId
        property var cardId
        onTriggered: {
            waitTimerMoveFromChinaHiddenToHand.stop()
            for (var i = 0; i < playerHands.children.length; i++) {
                if (playerHands.children[i].player.userId === userId){
                    playerHands.children[i].moveFromChinaHiddenToHand(cardId)
                    break
                }
            }
        }
    }

    function removeDepot(interval, startTurn){
        depot.waitTimerRemoveDepot.interval=interval
        depot.waitTimerRemoveDepot.startTurn=startTurn
        depot.waitTimerRemoveDepot.restart()
    }


    function moveFromChinaHiddenToHand(userId,cardId,interval){
        waitTimerMoveFromChinaHiddenToHand.userId=userId
        waitTimerMoveFromChinaHiddenToHand.interval= interval
        waitTimerMoveFromChinaHiddenToHand.cardId=cardId
        waitTimerMoveFromChinaHiddenToHand.start()
    }

    function checkFirstDone(){
        for (var i = 0; i < playerHands.children.length; i++) {
            var numberDones=0
            if(playerHands.children[i].checkDone()){
                numberDones++
            }
        }
        if (numberDones===1){
            return true
        }
        return false
    }

    function checkForMultiples(cardId){
        var validIds = []
        for (var i = 0; i < playerHands.children.length; i++) {
            // find the playerHand for the active player
            // if the selected card is in the playerHand of the active player
            if (playerHands.children[i].inHand(cardId) && playerHands.children[i].chinaHiddenAccessible===false){
                // put all valid card ids in the array
                if(playerHands.children[i].chinaAccessible){
                    for (var j = 0; j < playerHands.children[i].china.length; j ++){
                        if (playerHands.children[i].china[j].variationType===entityManager.getEntityById(cardId).variationType){
                            validIds.push(playerHands.children[i].china[j].entityId)
                        }
                    }
                }
                else {for (j = 0; j < playerHands.children[i].hand.length; j ++){
                        if (playerHands.children[i].hand[j].variationType===entityManager.getEntityById(cardId).variationType){
                            validIds.push(playerHands.children[i].hand[j].entityId)
                        }
                    }
                }
                return validIds
            }
            return validIds
        }
    }

    // sync deck with leader and set up the game
    function syncDeck(cardInfo){
        deck.syncDeck(cardInfo)
        // reset all values at the start of the game
        acted = false
        fourSames = false
        gameOver = false
        timer.start()
        scaleHand(1.0)
        //markValid()
        gameScene.gameOver.visible = false
        gameScene.leaveGame.visible = false
        gameScene.switchName.visible = false
        playerInfoPopup.visible = false
        chat.reset()
    }

    // deposit the selected cards
    function depositCards(cardIds){
        // unmark all highlighted cards, needed for ai move after userinterval
        //unmark()
        // scale down the active localPlayer playerHand
        scaleHand(1.0)
        for (var i = 0; i < playerHands.children.length; i++) {
            for(var j = 0; j<cardIds.length;j++){
                var cardId=cardIds? cardIds[j]:0
                // find the playerHand for the active player
                // if the selected card is in the playerHand of the active player
                if (playerHands.children[i].inHand(cardId)){
                    // remove and deposit the card
                    playerHands.children[i].removeFromHand(cardId)
                    var userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0
                    multiplayer.sendMessage(messageMoveCardDepot, {cardId: cardId, userId: userId})
                    depot.depositCard(cardId)
                }
                // uncover the card for disconnected players after chosing the color
                if (!multiplayer.activePlayer || !multiplayer.activePlayer.connected && depot.current){
                    depot.current.hidden = false
                }
            }
        }
    }

    // deposit the selected card
    function depositCard(cardId){
        // unmark all highlighted cards
        //unmark()
        for (var i = 0; i < playerHands.children.length; i++) {
            // find the playerHand for the active player
            // if the selected card is in the playerHand of the active player
            playerHands.children[i].activateChinaCheck()
            if (playerHands.children[i].inHand(cardId)){
                // remove and deposit the card
                playerHands.children[i].removeFromHand(cardId)
                depot.depositCard(cardId)
            }
            // uncover the card for disconnected players after chosing the color
            if ((!multiplayer.activePlayer || !multiplayer.activePlayer.connected) && depot.current){
                depot.current.hidden = false
            }
        }
    }

    // let AI take over if the player is not skipped
    function executeAIMove() {
        playRandomValids()
    }

    // play a random valid card from the playerHand of the active player
    function playRandomValids() {

        // find the playerHand of the active player
        for (var i = 0; i < playerHands.children.length; i++) {
            if (playerHands.children[i].player === multiplayer.activePlayer && !playerHands.children[i].player.done){

                //if chinaHidden dont mark valid, take a card and check if its valid, if not take depot and just chosen card
                var validCardIds = []

                if(Math.random()>0.75){
                    validCardIds= playerHands.children[i].chinaHiddenAccessible? playerHands.children[i].checkFirstValid(): playerHands.children[i].randomValidIds()
                }
                else{
                    validCardIds= playerHands.children[i].chinaHiddenAccessible? playerHands.children[i].checkFirstValid(): playerHands.children[i].smartValidIds()
                }

                var userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0
                // deposit the valid card or draw depot
                if (!validCardIds && playerHands.children[i].chinaHiddenAccessible){
                    multiplayer.sendMessage(messageMoveCardIdToHand, {cardId: playerHands.children[i].chinaHidden[0].entityId, userId: userId, interval: 1000})
                    moveFromChinaHiddenToHand(playerHands.children[i].player.userId,playerHands.children[i].chinaHidden[0].entityId,1000)
                    multiplayer.sendMessage(messageMoveDepotToHand, {userId: playerHands.children[i].player.userId, interval: 1900})
                    takeDepot(userId,2000)
                    return
                }
                if (validCardIds){
                    acted=true
                    depositCards(validCardIds)
                }

                //check done
                if(playerHands.children[i].checkDone()){
                    playerHands.children[i].done=true
                    var firstDone=false
                    if(checkFirstDone()){
                        playerHands.children[i].firstDone=true
                        firstDone=true
                    }
                    multiplayer.sendMessage(messageSetDone, {userId: userId, firstDone: firstDone})
                    if(checkShithead()){
                        multiplayer.sendMessage(messageEndGame, {userId: multiplayer.localPlayer.userId})
                        endGame()
                        return
                    }
                }
                if(depot.fourSames()){
                    multiplayer.sendMessage(messageRemoveDepot, {userId: userId, interval:1400})
                    removeDepot(1500,true)
                    return
                }
            }
        }
        endTurn()
    }



    // check whether a user with a specific id has valid cards or not
    function hasValidCards(userId){
        var playerHand = getHand(multiplayer.localPlayer.userId)
        var valids = playerHand.getValidCards()
        return valids.length > 0
    }

    // give the connected player 10 seconds until the AI takes over
    function startTurnTimer() {
        timer.stop()
        remainingTime = userInterval
        if (!gameOver) {
            timer.start()
        }
    }

    function handleFirstRound(){
        var playerHand = getHand(multiplayer.localPlayer.activePlayer)
        playerHand.originalHeight=134*2
    }


    // start the turn for the active player
    function turnStarted(playerId) {
        console.debug("turnStarted() called")
        console.debug("multiplayer.activePlayer.userId: " + multiplayer.activePlayer.userId)
        acted=false

        if(!multiplayer.activePlayer) {
            console.debug("ERROR: activePlayer not valid in turnStarted!")
            return
        }


        // start the timer
        gameLogic.startTurnTimer()


        if(firstRound && multiplayer.activePlayer.connected){
            for (var i = 0; i < playerHands.children.length; i++) {
                if (playerHands.children[i].player === multiplayer.localPlayer){
                    playerHands.children[i].neatFirstRound()
                    playerTags.children[i].canvas.requestPaint()
                    break
                }
            }
            return
        }

        for (i = 0; i < playerHands.children.length; i++) {
            //endTurn if player is already done
            if (playerHands.children[i].player === multiplayer.activePlayer){
                if(playerHands.children[i].done){
                    //check if done before skip
                    multiplayer.leaderCode(function() {
                        multiplayer.triggerNextTurn()
                    })
                    return
                }
            }
        }


        // check if the current card has an effect for the active player
        if(depot.cardEffect()){
            return
        }


        for (i = 0; i < playerHands.children.length; i++) {
            if (playerHands.children[i].player === multiplayer.activePlayer){

                playerHands.children[i].activateChinaCheck()

                //if chinaHidden dont mark valid, take a card and check if its valid, if not take depot and just chosen card
                if(!playerHands.children[i].chinaHiddenAccessible){//if china hidden accessible wait for user to select a card
                    var validCardIds= playerHands.children[i].randomValidIds()
                    if(!validCardIds){
                        acted=true
                        multiplayer.leaderCode(function () {
                            multiplayer.sendMessage(messageMoveDepotToHand, {userId: playerHands.children[i].player.userId, interval: 1900})
                            takeDepot(playerHands.children[i].player.userId,2000)
                        })

                        return
                    }
                }
            }
        }

        // zoom in on the hand of the active local player
        if (multiplayer.myTurn){
            waitTimerScaleHand.scale=1.6
            waitTimerScaleHand.restart()
        }
        // mark the valid card options
        //markValid()

        // repaint the timer circle
        for (i = 0; i < playerTags.children.length; i++){
            playerTags.children[i].canvas.requestPaint()
        }
        // schedule AI to take over in 3 seconds in case the player is gone
        multiplayer.leaderCode(function() {
            if (!multiplayer.activePlayer || !multiplayer.activePlayer.connected) {
                aiTimeOut.start()
            }
        })
    }

    function unshakeCards()
    {
        for (var i = 0; i<playerHands.children.length;i++){
            if(playerHands.children[i].player.userId===multiplayer.localPlayer.userId){
                playerHands.children[i].unshakeAll()
                return
            }
        }
    }

    // schedule AI to take over after 10 seconds if the connected player is inactive
    function turnTimedOut(){


        // clean up our UI
        timer.running = false

        if(gameLogic.firstRound){
            unshakeCards()
            firstRound=false

            // player timed out, so leader should take over
            multiplayer.leaderCode(function () {
                var userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0
                multiplayer.sendMessage(messageSetFirstRound,{firstRoundBool: false, userId: userId})
                knockSound.play()
                scaleHand(1.0)
                //start turn for player with most fours
                var mostFoursUserId=mostLows()
                if(mostFoursUserId){
                    multiplayer.triggerNextTurn(mostFoursUserId)
                }
                else{
                    turnStarted(multiplayer.localPlayer.userId)
                }
            })

            return
        }


        if(waitBeforeNewTurn.running || waitInputTimer.running || depot.waitTimerRemoveDepot.running || waitTimerTakeDepot.running || waitTimerGetCards.running){
            return
        }

        console.debug("turnTimedOut() acted: "+ acted + "myTurn: " + multiplayer.myTurn)
        if (!acted){
            acted=true

        }

        scaleHand(1.0)
        // player timed out, so leader should take over
        multiplayer.leaderCode(function () {
            // if the player is in the process of chosing a color
            executeAIMove()
            endTurn()
        })
    }

    function mostLows(){
        var playerId=undefined
        var count
        var tempCount=0
        for(var low=1; low<4;low++){
            count=0
            for(var i=0; i<playerHands.children.length;i++){
                for(var j=0; j<playerHands.children[i].hand.length;j++){
                    if(playerHands.children[i].hand[j].val===low) tempCount++
                }
                if(tempCount>count){
                    count=tempCount
                    playerId=playerHands.children[i].player.userId
                }
                tempCount=0
            }
            if(count>0) return playerId
        }
    }


    // stop the timers and reset the deck at the end of the game
    function leaveGame(){
        waitInputTimer.stop()
        waitBeforeNewTurn.stop()
        aiTimeOut.stop()
        restartGameTimer.stop()
        timer.running = false
        timer.stop()
        waitTimerScaleHand.stop()
        firstRound=true
        deck.reset()
        depot.reset()
        chat.gConsole.clear()
        multiplayer.leaveGame()
        scaleHand(1.0)
        initialized = false
        receivedMessageBeforeGameStateInSync = false
        window.state = "menu"
    }

    function joinGame(room){
        multiplayer.joinGame(room)
    }

    // initialize the game
    // is called from GameOverWindow when the leader restarts the game, and from GameScene when it got visible from GameScene.onVisibleChanged
    function initGame(calledFromGameOverScreen){
        if(!multiplayer.initialized && !multiplayer.singlePlayer){
            multiplayer.createGame()
        }

        // reset all values at the start of the game
        initialized= false
        gameOver = false
        firstRound=true
        timer.start()
        gameScene.jokerButton.visible = true
        gameScene.gameOver.visible = false
        gameScene.leaveGame.visible = false
        gameScene.switchName.visible = false
        playerInfoPopup.visible = false
        chat.reset()
        depot.reset()

        // initialize the players, the deck and the individual hands
        initPlayers()
        initDeck()
        initHands()
        // reset all tags and set tag data of the leader
        initTags()

        // set the game state for all players
        multiplayer.leaderCode(function () {
            // NOTE: only the leader must set this to true! the clients only get initialized after the initial syncing game state message is received
            initialized = true

            // if we call this here, gameStarted is called twice. it is not needed to call, because it is already called when the room is setup
            // thus we must not call this! forceStartGame() is called from the MatchMakingView, not from the GameScene!
            if(calledFromGameOverScreen) {
                // by calling restartGame, we emit a gameStarted call on the leader and the clients
                multiplayer.restartGame()
            }

            // we want to send the state to all players in this case, thus set the playerId to undefined and this case is handled in onMessageReceived so all players handle the game state syncing if playerId is undefined
            // send game state after forceStartGame, otherwise the message will not be received by the initial players!
            if (!multiplayer.singlePlayer) {
                sendGameStateToPlayer(undefined)
            }

            // only the leader needs to call this
            // lets always the leader take the first turn, otherwise the same player that ended the game before would be the first to make a turn
            //gameLogic.triggerNewTurn(multiplayer.leaderPlayer.userId)

            multiplayer.triggerNextTurn(multiplayer.leaderPlayer.userId)//call directly to have userID as parameter
        })

        // start by scaling the playerHand of the active localPlayer
        //scaleHand(1.0)

        console.debug("InitGame finished!")
    }

    /*
    Is only called if leader. The leader does not receive the messageSyncGameState message anyway, because messages are not sent to self.
    Used to sync the game in the beginning and for every newly joined player.
    Is called from leader initially when starting a game and when a new player joins.
    If playerId is undefined, it is handled by all players. Use this for initial syncing with players already in the matchmaking room.
  */
    function sendGameStateToPlayer(playerId) {
        console.debug("sendGameStateToPlayer() with playerId", playerId)
        // save all needed game sync data
        var message = {}

        // save all current hands of the other players
        var currentPlayerHands = []
        for (var i = 0; i < playerHands.children.length; i++) {
            // the hand of a single player
            var currentPlayerHand = {}
            // save the userId to assign the information to the correct player
            currentPlayerHand.userId = playerHands.children[i].player.userId
            // save the ids of player's cards
            currentPlayerHand.handIds = []
            currentPlayerHand.chinaIds = []
            currentPlayerHand.chinaHiddenIds= []
            for (var j = 0; j < playerHands.children[i].hand.length; j++){
                currentPlayerHand.handIds[j] = playerHands.children[i].hand[j].entityId
            }
            for (j = 0; j < playerHands.children[i].china.length; j++){
                currentPlayerHand.chinaIds[j] = playerHands.children[i].china[j].entityId
            }
            for (j = 0; j < playerHands.children[i].chinaHidden.length; j++){
                currentPlayerHand.chinaHiddenIds[j] = playerHands.children[i].chinaHidden[j].entityId
            }
            currentPlayerHand.done=playerHands.children[i].done
            currentPlayerHand.firstDone=playerHands.children[i].firstDone

            currentPlayerHand.chinaAccessible=playerHands.children[i].chinaAccessible
            currentPlayerHand.chinaHiddenAccessible=playerHands.children[i].chinaHiddenAccessible

            // add the hand information of a single player
            currentPlayerHands.push(currentPlayerHand)
        }
        // save the hand information of all players
        message.playerHands = currentPlayerHands
        // save the deck information to create an identical one
        message.deck = deck.cardInfo
        message.cardsInStack = deck.cardsInStack
        // sync the depot variables
        if(depot.current) message.current = depot.current.entityId

        message.skipped = depot.skipped
        message.gameOver = gameOver
        message.firstRound = firstRound

        if(depot.last) message.last = depot.last.entityId

        message.checkLast = depot.checkLast
        if(depot.multiple) message.multiple = depot.multiple.entityId


        // save all card ids of the current depot
        var depotIDs = []
        var removedIDs = []
        for (var k = 0; k < deck.cardDeck.length; k++){
            if ((deck.cardDeck[k].state === "depot" || deck.cardDeck[k].state === "removed") &&deck.cardDeck[k].entityId !== depot.current.entityId){
                depotIDs.push(deck.cardDeck[k].entityId)
            }
            if (deck.cardDeck[k].state === "removed"){
                removedIDs.push(deck.cardDeck[k].entityId)
            }
        }
        message.depot = depotIDs
        message.removed = removedIDs

        // send the message to the newly joined player
        message.receiverPlayerId = playerId

        console.debug("Send Message: " + JSON.stringify(message))
        multiplayer.sendMessage(messageSyncGameState, message)
    }

    // compares the amount of cards in each player's hand with the leader's game state
    // used to check whether to sync with the leader or not
    function compareGameStateWithLeader(messageHands){
        for (var i = 0; i < playerHands.children.length; i++){
            var currentUserId = playerHands.children[i].player.userId
            for (var j = 0; j < messageHands.length; j++){
                var messageUserId = messageHands[j].userId
                if (currentUserId === messageUserId){
                    if (playerHands.children[i].hand.length !== messageHands[j].handIds.length){
                        // returns false if the amount of cards differentiate
                        console.debug("ERROR: game state differentiates from the one of the leader because of the different amount of cards - resync the game of this player!")
                        return false
                    }
                }
            }
        }
        // returns true if all hands are synced
        return true
    }

    // the leader initializes all players and positions them at the borders of the game
    function initPlayers(){
        multiplayer.leaderCode(function () {
            var clientPlayers = multiplayer.players
            var playerInfo = []
            for (var i = 0; i < clientPlayers.length; i++) {
                playerTags.children[i].player = clientPlayers[i]
                playerHands.children[i].player = clientPlayers[i]
                playerInfo[i] = clientPlayers[i].userId
            }
        })
    }

    // find player by userId
    function getPlayer(userId){
        for (var i = 0; i < multiplayer.players.length; i++){
            console.debug("All UserIDs: " + multiplayer.players[i].userId + ", Looking for: " + userId)
            if (multiplayer.players[i].userId === userId){
                return multiplayer.players[i]
            }
        }
        console.debug("ERROR: could not find player with id", userId, "in the multiplayer.players list!")
        return undefined
    }

    // find hand by userId
    function getHand(userId){
        for (var i = 0; i < playerHands.children.length; i++){
            if (playerHands.children[i].player.userId === userId){
                return playerHands.children[i]
            }
        }
        console.debug("ERROR: could not find player with id", userId, "in the multiplayer.players list!")
        return undefined
    }

    // update tag by player userId
    function updateTag(userId, level, highscore, rank){
        for (var i = 0; i < playerTags.children.length; i++){
            if (playerHands.children[i].player.userId === userId){
                playerTags.children[i].level = level
                playerTags.children[i].highscore = highscore
                playerTags.children[i].rank = rank
            }
        }
    }

    // the other players position the players at the borders of the game field
    function syncPlayers(){
        // it can happen that the multiplayer.players array is different than the one from the local user
        // possible reasons are, that a player meanwhile joined the game but this did not get forwarded to the room, or not forwarded to the leader yet

        // assign the players to the positions at the borders of the game field
        for (var j = 0; j < multiplayer.players.length; j++) {
            playerTags.children[j].player = multiplayer.players[j]
            playerHands.children[j].player = multiplayer.players[j]
        }
    }

    // the leader creates the deck and depot
    function initDeck(){
        multiplayer.leaderCode(function () {
            deck.createDeck()
        })
    }

    // the leader hands out the cards to the other players
    function joker(){
        if (multiplayer.myTurn && !depot.skipped && initialized &&!acted &&!firstRound && depot.current) {
            var userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0
            multiplayer.sendMessage(messageMoveDepotToHand, {userId: userId, interval: 0})
            takeDepot(userId,0)
            acted=true
            return true
        }
        else{
            gameScene.jokerButton.shaker.start()
            return false
        }
    }

    // the leader hands out the cards to the other players
    function initHands(){
        multiplayer.leaderCode(function () {
            for (var i = 0; i < playerHands.children.length; i++) {
                // start the hand for each player

                playerHands.children[i].startHand(initialized)
                if(!multiplayer.players[i].connected){
                    playerHands.children[i].optimizeChina()
                }
                playerHands.children[i].neatHand()
                playerHands.children[i].neatChina()
            }
        })
    }


    // sync all hands according to the leader
    function syncHands(messageHands){
        for (var i = 0; i < playerHands.children.length; i++){
            var currentUserId = playerHands.children[i].player.userId
            for (var j = 0; j < messageHands.length; j++){
                var messageUserId = messageHands[j].userId
                if (currentUserId === messageUserId){
                    playerHands.children[i].syncHand(messageHands[j])
                }
            }
        }
    }

    // reset all tags and init the tag for the local player
    function initTags(){
        for (var i = 0; i < playerTags.children.length; i++){
            playerTags.children[i].initTag()
            if (playerHands.children[i].player && playerHands.children[i].player.userId === multiplayer.localPlayer.userId){
                playerTags.children[i].getPlayerData(true)
            }
        }
    }

    Timer{
        id: waitTimerGetCards
        interval:500
        repeat: false
        property var cards
        property var userId
        onTriggered: {
            waitTimerGetCards.stop()
            // find the playerHand of the active player and pick up cards
            for (var i = 0; i < playerHands.children.length; i++) {
                if (playerHands.children[i].player.userId === userId){
                    playerHands.children[i].pickUpCards(cards,initialized)
                    break
                }
            }
        }
    }

    // draw the specified amount of cards
    function getCards(cards, userId,interval){
        if(interval) waitTimerGetCards.interval=interval
        waitTimerGetCards.userId=userId
        waitTimerGetCards.cards=cards
        waitTimerGetCards.start()
    }

    Timer{
        id: waitTimerTakeDepot
        interval: 1000
        repeat: false
        property var userId
        onTriggered: {
            // find the playerHand of the active player and pick up cards
            for (var i = 0; i < playerHands.children.length; i++) {
                if (playerHands.children[i].player.userId === userId){
                    playerHands.children[i].pickUpDepot()
                    break
                }
            }
            depot.current   =undefined
            depot.last      =undefined
            multiplayer.leaderCode(function () {
                endTurn()
            })
            waitTimerScaleHand.scale=1.0
            waitTimerScaleHand.restart()

        }
    }


    //take depot if no valid card in hand
    function takeDepot(userId,interval){
        waitTimerTakeDepot.interval=interval
        waitTimerTakeDepot.userId=userId
        waitTimerTakeDepot.start()
    }

    // find the playerHand of the active player and mark all valid card options
    function markMultiples(cardId){
        if (multiplayer.myTurn){
            for (var i = 0; i < playerHands.children.length; i++) {
                if (playerHands.children[i].player === multiplayer.activePlayer){
                    playerHands.children[i].markMultiples(cardId)
                    break
                }
            }
        } else {
            unmark()
        }
    }

    // find the playerHand of the active player and mark all valid card options
    function markValid(){
        if (multiplayer.myTurn){
            for (var i = 0; i < playerHands.children.length; i++) {
                if (playerHands.children[i].player === multiplayer.activePlayer){
                    playerHands.children[i].markValid()
                    break
                }
            }
        }
    }



    // unmark all valid card options of all players
    //function unmark(cardId){
    //    for (var i = 0; i < playerHands.children.length; i++) {
    //        playerHands.children[i].unmark()
    //    }
    //}

    // scale the playerHand of the active localPlayer
    function scaleHand(scale){
        if (!scale) scale = multiplayer.myTurn && !depot.skipped ? 1.6 : 1.0
        for (var i = 0; i < playerHands.children.length; i++){
            if (playerHands.children[i].player && playerHands.children[i].player.userId === multiplayer.localPlayer.userId){
                playerHands.children[i].scaleHand(scale)
                playerHands.children[i].neatHand()
                playerHands.children[i].neatChina()

            }
        }
    }

    // end the turn of the active player
    function endTurn(){

        // scale down the hand of the active local player
        scaleHand(1.0)


        var userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0
        //check if the active player has won the game
        for (var i = 0; i < playerHands.children.length; i++) {
            if (playerHands.children[i].player === multiplayer.activePlayer && !depot.skipped){
                //if(checkShithead()){
                //    endGame()
                //    multiplayer.sendMessage(messageEndGame, {userId: userId})
                //    return
                //}
                //if 10 was last card start turn for same player
                if(depot.current && depot.current.variationType === "10"){
                    multiplayer.sendMessage(messageRemoveDepot, {userId: userId, interval:1400})
                    if(playerHands.children[i].done){
                        removeDepot(1500,false)
                        break
                    }
                    else{
                        removeDepot(1500,true)
                        return
                    }
                }

                // refill cards
                //if (!again && acted){
                var refillNumber = playerHands.children[i].activateChinaCheck()

                if (refillNumber!==0){

                    multiplayer.sendMessage(messageMoveCardsHand, {cards: refillNumber, userId: userId})
                    getCards(refillNumber, userId,1000)

                }
                //}
            }
        }
        depot.multiple=undefined//is it necessary, cause it is also in hasEffect
        // reset acted

        // continue if the game is still going
        if (!gameOver){
            if (multiplayer.amLeader){
                triggerNewTurn()
            } else {
                // send message to leader to trigger new turn
                multiplayer.sendMessage(messageTriggerTurn, userId)
            }
        }
    }

    function triggerNewTurn(){
        waitBeforeNewTurn.start()
    }

    function checkShithead(){
        var playerCount=4
        var doneCount=0
        var connectedNDone=0
        var connected=0
        for (var i = 0; i < playerHands.children.length; i++) {
            if (playerHands.children[i].done){
                doneCount++
                if(multiplayer.singlePlayer && playerHands.children[i].player.userId===multiplayer.localPlayer.userId){
                    return true
                }
            }
            if(doneCount>=playerCount-1){
                return true
            }
            //if all non computer players are done return true
            if(multiplayer.players[i].connected){
                connected++
                if(playerHands.children[i].done){
                    connectedNDone++
                }
            }

        }
        if(connected===connectedNDone){
            return true
        }
        return false
    }

    // calculate the points for each player
    function calculatePoints(userId){
        // calculate the score
        for (var i = 0; i < playerHands.children.length; i++) {
            playerHands.children[i].points()
        }
        // set the name of the winner
        for (i = 0; i < playerHands.children.length; i++) {
            if(playerHands.children[i].score===0){
                gameScene.gameOver.loser = playerHands.children[i].player
                if(multiplayer.localPlayer.userId===playerHands.children[i].player.userId){
                    loserSound.play()
                }
            }
        }
    }

    // end the game and report the scores
    /*
    This is called by both the leader and the clients.
    Each user calculates and displays the points of all players. The local user reports his score and updates his level.
    If it differs from the previous level, the local user levelled up. In this case we display a message with the new level on the game over window.
    If he doesn't have a nickname, we ask him to chose one. Then we reset all timers and values.
    */
    function endGame(userId){
        // calculate the points of each player and set the name of the winner
        calculatePoints(userId)

        // show the gameOver message with the winner and score
        //gameScene.gameOver.visible = true
        waitTimerGameOver.start()

        // add points to MultiplayerUser score of the winner
        var currentHand = getHand(multiplayer.localPlayer.userId)
        if (currentHand) gameNetwork.reportRelativeScore(currentHand.score)

        var currentTag
        for (var i = 0; i < playerTags.children.length; i++){
            if (playerTags.children[i].player.userId === multiplayer.localPlayer.userId){
                currentTag = playerTags.children[i]
            }
        }

        // calculate level with new points and check if there was a level up
        var oldLevel = currentTag.level
        currentTag.getPlayerData(false)
        if (oldLevel !== currentTag.level){
            gameScene.gameOver.level = currentTag.level
            gameScene.gameOver.levelText.visible = true
        } else {
            gameScene.gameOver.levelText.visible = false
        }

        // show window with text input to switch username
        if (!multiplayer.singlePlayer && !gameNetwork.user.hasCustomNickName()) {
            gameScene.switchName.visible = true
        }

        // stop all timers and end the game
        scaleHand(1.0)
        gameOver = true
        aiTimeOut.stop()
        timer.running = false

        multiplayer.leaderCode(function () {
            restartGameTimer.restart()
        })

    }

    function startNewGame(){
        restartGameTimer.stop()
        // the true causes a gameStarted to be emitted
        gameLogic.initGame(true)
    }

    function getUserInterval(){
        if(gameLogic.firstRound){
            return multiplayer.amLeader? 14 : 12
        }
        return multiplayer.myTurn && !multiplayer.amLeader ? 22 : 25
    }

}

