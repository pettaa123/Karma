import QtQuick 2.0
import Felgo 3.0

Item {
    id: depot
    width: 97
    height: 152

    // current card on top of the depot for finding a match
    property var current
    // last card under current
    property var last
    // checklast instead of actual
    property bool checkLast : false
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

    // sound effect when player completes four
    SoundEffect {
        volume: 0.5
        id: yeahSound
        source: "../../assets/snd/yeah.wav"
    }


    function fourSames(){
        if(!current || !last){return false}
        var toBeChecked=last
        var counter=1
        //if to be checked is of same value again, dig deeper
        var reached=true
        while(toBeChecked.variationType==current.variationType && reached){
            reached=false
            counter++
            if(counter===4){
                yeahSound.play()
                return true
            }
            var z= toBeChecked.z
            for (var j=0;j<deck.cardDeck.length;j++){
                if(deck.cardDeck[j].state==="depot" && (deck.cardDeck[j].z===z-1)){
                    if(deck.cardDeck[j].variationType===current.variationType){
                        toBeChecked=deck.cardDeck[j]
                        reached=true
                        break
                    }
                }
            }
        }
        return false
    }

    // put cards away if 10 was played
    function removeDepot(){
        for (var i = 0; i < deck.cardDeck.length; i ++){
            if(deck.cardDeck[i].state==="depot"){
                removeCard(deck.cardDeck[i].entityId)
            }
        }
        checkLast=false

        //sync last
        //var userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0
        //multiplayer.sendMessage(gameLogic.messageResetCurrentAndLast, {userId: userId})

        last=undefined
        current=undefined
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
            if(deck.cardDeck[i].state==="depot"){
                deck.cardDeck[i].hidden=true
                handOut.push(deck.cardDeck[i])
            }
        }
        return handOut
    }

    // add the selected card to the depot
    function depositCard(cardId){
        var card = entityManager.getEntityById(cardId)
        // change the parent of the card to depot
        changeParent(card)
        // uncover card right away if the player is connected
        // activePlayer might be undefined here, when initially synced
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
        checkLast=false
        if(!current) return false
        if (current && current.variationType === "3"){
            checkLast=true
        }
        if(current.variationType === "8" && skipped==false){
            //var userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0
            //multiplayer.sendMessage(gameLogic.messageSetSkipped, {skipped: true, userId: userId})
            skipSound.play()
            gameLogic.acted=true
            skipped=true
            multiplayer.leaderCode(function () {
                console.debug("endTurn() from cardEffect()")
                gameLogic.endTurn()
            })
            return true
        }
        if(skipped==true){
            skipped =false
        }
        return false
    }


    // reset the depot            var test=entityManager.getEntityById(cardId)
    function reset(){
        current = undefined
        last = undefined
        checkLast = false
        skipped = false
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
        depot.last= lastId? entityManager.getEntityById(lastId):undefined
        depot.multiple = multipleId? entityManager.getEntityById(lastId):undefined
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
