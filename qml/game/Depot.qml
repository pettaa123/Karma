import QtQuick 2.0
import Felgo 3.0

Item {
    id: depot
    width: 82
    height: 134

    // current card on top of the depot for finding a match
    property var current
    // last card under current
    property var last
    // checklast instead of actual
    property bool checkLast : false
    // block the player for a short period of time when he gets skipped
    property alias effectTimer: effectTimer
    // whether the active player is skipped or not
    property bool skipped: false
    // holds temporary a card which was played second,third etc...
    property var multiple


    // sound effect plays createDwhen a player gets skipped
    SoundEffect {
        volume: 0.5
        id: skipSound
        source: "../../assets/snd/skip.wav"
    }

    // sound effect plays when a player gets skipped
    SoundEffect {
        volume: 0.5
        id: reverseSoundde
        source: "../../assets/snd/reverse.wav"
    }

    // blocks the player for a short period of time and trigger a new turn when he gets skipped
    Timer {
        id: effectTimer
        repeat: false
        interval: 3000
        onTriggered: {
            effectTimer.stop()
            skipped = false
            var userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0
            multiplayer.sendMessage(gameLogic.messageSetSkipped, {skipped: false, userId: userId})
            console.debug("<<<< Trigger new turn after effect")
            multiplayer.triggerNextTurn()
        }
    }

    // put cards away if 10 was played
    function removeDepot(){
        for (var i = 0; i < deck.cardDeck.length; i ++){
            if(deck.cardDeck[i].state==="depot"){
                removeCard(deck.cardDeck[i].entityId)
            }
        }
        current=undefined
        last=undefined
    }

    function removeCard(id){
        var card = entityManager.getEntityById(id)
        card.state = "removed"
        card.glowImage.visible = false
        // move the card to the removed place and vary the position and rotation
        card.hidden = true

        // move the card to the depot and vary the position and rotation
        var rotation = randomIntFromInterval(86, 94)
        var xOffset = randomIntFromInterval(-4, 4)
        var yOffset = randomIntFromInterval(-4, 4)

        card.rotation = rotation
        card.width= card.originalWidth*2/3
        card.height= card.originalHeight*2/3
        card.x=Math.floor((-2*card.originalWidth)+xOffset)
        card.y=yOffset
    }


    //no valid card handOut
    function handOutDepot(){
        var handOut = []
        for (var i = 0; i < deck.cardDeck.length; i ++){
            if(deck.cardDeck[i].state==="depot")
                handOut.push(deck.cardDeck[i])
        }
        var userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0
        multiplayer.sendMessage(gameLogic.messageDrawDepot, {userId: userId})


        return handOut
    }

    // add the selected card to the depot
    function depositCard(cardId){
        var card = entityManager.getEntityById(cardId)
        // change the parent of the card to depot
        changeParent(card)
        // uncover card right away if the player is connected
        // used for wild and wild4 cards
        // activePlayer might be undefined here, when initially synced
        console.debug(multiplayer.activeplayer)
        console.debug(multiplayer.activePlayer.connected)
        if (!multiplayer.activePlayer || multiplayer.activePlayer.connected){
            card.hidden = false
        }

        // move the card to the depot and vary the position and rotation
        var rotation = randomIntFromInterval(-10, 10)
        var xOffset = randomIntFromInterval(-10, 10)
        var yOffset = randomIntFromInterval(-10, 10)

        card.rotation = rotation
        card.x = xOffset
        card.y = yOffset


        // the first card starts with z 0, the others get placed on top
        if (!current) {
            card.z = 0
        }else{
            card.z = current.z + 1
        }

        // the deposited card is the current reference card
        last = current
        current = card
    }

    // change the card's parent to depot
    function changeParent(card){
        card.newParent = depot
        card.state = "depot"
    }

    // check if the selected card matches with the current reference card
    function validCard(cardId){
        // only continue if the selected card is in the hand of the active player

        for (var i = 0; i < playerHands.children.length; i++) {
            if (playerHands.children[i].player === multiplayer.activePlayer){
                if (!playerHands.children[i].inHand(cardId)) return false // shouldnt be reached
            }
        }

        var card = entityManager.getEntityById(cardId)

        if (card.variationType=== "3") return true
        if (card.variationType=== "2") return true
        if (card.variationType=== "10") return true

        if (!current || (checkLast && !last)){
            return true
        }

        var toBeChecked = checkLast ? last : current
        //if to be checked is a 3 again, dig deeper
        while(toBeChecked.variationType ==="3"){
            for (var j=0;j<deck.cardDeck.length;j++){
                var z= toBeChecked.z
                if(deck.cardDeck[j].state==="depot" && (deck.cardDeck[j].z===z-1)){
                    toBeChecked=deck.cardDeck[j]
                    break
                }
            }
            if(toBeChecked.z===0) break
        }


        if (toBeChecked.variationType === "7" && (parseInt(card.variationType) <= "7")) return true
        if (toBeChecked.variationType === "7" && (parseInt(card.variationType) > "7")) return false


        if (parseInt(card.variationType) >= parseInt(toBeChecked.variationType)) return true

        return false
    }





    // play a card effect depending on the card type
    function cardEffect(){
        console.debug("cardEffect started")
        for (var i = 0; i < playerHands.children.length; i++) {
            if (playerHands.children[i].player === multiplayer.activePlayer && !playerHands.children[i].done){
                if (current && current.variationType === "8") {
                    console.debug("SKIP")
                    skip()
                }
                if (current && current.variationType === "3") {
                    console.debug("CHECKLAST TRUE")
                    checkLast=true
                    var userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0
                    multiplayer.sendMessage(gameLogic.messageSetCheckLast, {checkLast: true, userId: userId})
                }
                else {
                    // reset the card effects if they are not active
                    skipped = false
                    checkLast= false
                    multiple=undefined
                    var userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0
                    multiplayer.sendMessage(gameLogic.messageSetCheckLast, {checkLast: false, userId: userId})
                    multiplayer.sendMessage(gameLogic.messageSetMultiple, {multiple: undefined, userId: userId})
                }
            }
        }
        console.debug("cardEffect ended")
    }



    // skip the current player by playing a sound, setting the skipped variable and starting the skip timer
    function skip(){
        skipSound.play()
        skipped = true

        if (multiplayer.activePlayer && multiplayer.activePlayer.connected){
            multiplayer.leaderCode(function() {
                effectTimer.start()
            })
        }
    }

    // reset the depot            var test=entityManager.getEntityById(cardId)
    function reset(){
        current = undefined
        last = undefined
        checkLast = false
        skipped = false
        effectTimer.stop()
    }

    // sync the depot with the leader
    function syncDepot(depotCardIDs,currentId,lastId,multipleId, skipped, checkLast){
        for (var i = 0; i < depotCardIDs.length; i++){
            depositCard(depotCardIDs[i])
            deck.cardsInStack --
        }

        if(currentId) depositCard(currentId)

        depot.skipped = skipped

        //SHITHEAD
        depot.checkLast = checkLast? checkLast : false
        depot.last= lastId? gentityManager.getEntityById(lastId):undefined
        depot.multiple = multipleId? gentityManager.getEntityById(lastId):undefined
    }

    // sync the depot with the leader
    function syncRemoved(removedCardIDs){
        for (var i = 0; i < removedCardIDs.length; i++){
            removeCard(removedCardIDs[i])
        }

    }

    // return a random number between two values
    function randomIntFromInterval(min,max)
    {
        return Math.floor(Math.random() * (max - min + 1) + min)
    }
}
