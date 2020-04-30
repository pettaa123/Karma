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
    property bool checkLast
    // block the player for a short period of time when he gets skipped
    property alias effectTimer: effectTimer
    // the current depot card effect for the next player
    property bool effect: false
    // whether the active player is skipped or not
    property bool skipped: false

    property var multiple


    // sound effect plays when a player gets skipped
    SoundEffect {
        volume: 0.5
        id: skipSound
        source: "../../assets/snd/skip.wav"
    }

    // sound effect plays when a player gets skipped
    SoundEffect {
        volume: 0.5
        id: reverseSound
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
                console.debug(deck.cardDeck[i].entityId)
                var card = entityManager.getEntityById(deck.cardDeck[i].entityId)
                //card.newParent = removed
                card.state = "removed"
                card.glowImage.visible = false
                // move the card to the depot and vary the position and rotation
                card.hidden = true

                // move the card to the depot and vary the position and rotation
                var rotation = randomIntFromInterval(86, 94)
                var xOffset = randomIntFromInterval(-4, 4)
                var yOffset = randomIntFromInterval(-4, 4)

                //var newWidth = Math.floor(card.originalWidth*2/3)
                //var newHeight = Math.floor(card.originalHeight*2/3)

                //card.resetGeometry()
                card.rotation = rotation
                card.width= card.originalWidth*2/3
                card.height= card.originalHeight*2/3
                card.x=Math.floor((-2*card.originalWidth)+xOffset)
                card.y=yOffset
            }
        }
        current=undefined
        last=undefined
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

        var userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0
        // signal if the placed card has an effect on the next player
        if(hasEffect()){
            effect = true
            multiplayer.sendMessage(gameLogic.messageSetEffect, {effect: true, userId: userId})
        } else {
            effect = false
            multiplayer.sendMessage(gameLogic.messageSetEffect, {effect: false, userId: userId})
        }
    }

    // change the card's parent to depot
    function changeParent(card){
        card.newParent = depot
        card.state = "depot"
    }

    // check if the card has an effect for the next player
    function hasEffect(){
        if (current.variationType === "8" ||
                current.variationType === "3"){
            return true
        } //skip
        else{
            return false
        }
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
                if (effect){
                    if (current && current.variationType === "8") {
                        console.debug("SKIP")
                        skip()
                    }
                    if (current && current.variationType === "3") {
                        console.debug("CHECKLAST TRUE")
                        checkLast=true
                    }
                } else {
                    // reset the card effects if they are not active
                    skipped = false
                    checkLast= false
                    multiple=false
                }
            }
        }
        console.debug("cardEffect ended")
    }



    // skip the current player by playing a sound, setting the skipped variable and starting the skip timer
    function skip(){
        skipSound.play()
        effect = false
        var userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0
        multiplayer.sendMessage(gameLogic.messageSetEffect, {effect: false, userId: userId})
        skipped = true

        if (multiplayer.activePlayer && multiplayer.activePlayer.connected){
            multiplayer.leaderCode(function() {
                effectTimer.start()
            })
        }
    }

    // reset the depot
    function reset(){
        current = undefined
        last = undefined
        checkLast = false
        skipped = false
        effect = false
        effectTimer.stop()
    }

    // sync the depot with the leader
    function syncDepot(depotCardIDs, currentId, skipped, effect){
        for (var i = 0; i < depotCardIDs.length; i++){
            depositCard(depotCardIDs[i])
            deck.cardsInStack --
        }

        depositCard(currentId)
        depot.skipped = skipped
        depot.effect = effect
    }


    // return a random number between two values
    function randomIntFromInterval(min,max)
    {
        return Math.floor(Math.random() * (max - min + 1) + min)
    }
}
