import QtQuick 2.0
import Felgo 3.0

// the cards in the hand of the player
Item {
    id: playerHand
    width: 400
    height: 134

    property double zoom: 1.0
    property int originalWidth: 400
    property int originalHeight: 134

    // amount of cards in hand in the beginning of the game
    property int start: 9
    // array with all cards in hand
    property var hand: []
    // array with visible cards in china :)
    property var china: []
    // array with unvisible cards in china :)
    property var chinaHidden: []
    // the owner of the cards
    property var player: MultiplayerUser{}
    // whether the player pressed the ONUButton or not
    property bool onu: false
    // the score at the end of the game
    property int score: 0
    // value used to spread the cards in hand
    property double offset: width/10
    // value activated if hand cards are gone
    property bool chinaActivated : false


    // sound effect plays when drawing a card
    SoundEffect {
        volume: 0.5
        id: drawSound
        source: "../../assets/snd/draw.wav"
    }

    // sound effect plays when depositing a card
    SoundEffect {
        volume: 0.5
        id: depositSound
        source: "../../assets/snd/deposit.wav"
    }

    // sound effect plays when winning the game
    SoundEffect {
        volume: 0.5
        id: winSound
        source: "../../assets/snd/win.wav"
    }

    // playerHand background image
    // the image changes for the active player
    Image {
        id: playerHandImage
        source: multiplayer.activePlayer === player && !gameLogic.acted? "../../assets/img/PlayerHand2.png" : "../../assets/img/PlayerHand1.png"
        width: parent.width / 400 * 560
        height: parent.height / 134 * 260
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height * (-0.5)
        z: 0
        smooth: true

        onSourceChanged: {
            z = 0
            neatHand()
        }
    }

    // playerHand blocked image is visible when the player gets skipped
    Image {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        source: "../../assets/img/Blocked.png"
        width: 170
        height: width
        z: 100
        visible: depot.skipped && multiplayer.activePlayer == player
        smooth: true
    }

    // playerHand bubble image is visible when the player pressed the ONUButton
    Image {
        anchors.top: parent.top
        anchors.right: parent.right
        source: "../../assets/img/Bubble.png"
        rotation: parent.rotation * (-1)
        width: 60
        height: width
        z: 100
        visible: onu
        smooth: true
    }

    // start the hand by picking up a specified amount of cards
    function startHand(){
        pickUpCards(start)
    }

    // reset the hand by removing all cards
    function reset(){
        while(hand.length) {
            hand.pop()
        }
        while(china.length) {
            china.pop()
        }
        while(chinaHidden.length) {
            china.pop()
        }

        onu = false
        scaleHand(1.0)
    }

    function neatChina(){
        offset = originalWidth * zoom / 10
        console.debug("neat china")

        // calculate the card position and rotation in the hand and change the z order
        for (var i = 0; i < china.length; i ++){
            var card = china[i]
            // angle span for spread cards in hand
            var handAngle = 30 //40
            // card angle depending on the array position
            var cardAngle = handAngle / china.length * (i + 0.5) - handAngle / 2
            //offset of all cards + one card width
            var handWidth = offset * (china.length - 1) + card.originalWidth * zoom
            // x value depending on the array position
            var cardX = (playerHand.originalWidth * zoom - handWidth) / 2 + (i * offset)

            card.rotation = cardAngle-28
            card.y = -Math.cos(card.rotation)*1.5 -originalHeight/4
            card.x = cardX - originalWidth/3
            card.z = i -50 + playerHandImage.z
        }

        for (i = 0; i < chinaHidden.length; i ++){
            card = chinaHidden[i]
            // angle span for spread cards in hand
            handAngle = 30 //40
            // card angle depending on the array position
            cardAngle = handAngle / chinaHidden.length * (i + 0.5) - handAngle / 2
            //offset of all cards + one card width
            handWidth = offset * (chinaHidden.length - 1) + card.originalWidth * zoom
            // x value depending on the array position
            cardX = (playerHand.originalWidth * zoom - handWidth) / 2 + (i * offset)

            card.rotation = cardAngle-28
            card.y = -Math.cos(card.rotation)*1.5 -originalHeight/4
            card.x = cardX - originalWidth/3
            card.z = i -100 + playerHandImage.z
        }
    }

    // organize the hand and spread the cards
    function neatHand(){
        console.debug("neatHand")
        // sort all cards by their natural order
        hand.sort(function(a, b) {
            return a.order - b.order
        })

        // recalculate the offset between cards if there are too many in the hand
        // make sure they stay within the playerHand
        offset = originalWidth * zoom / 10
        if (hand.length > 7){
            offset = playerHand.originalWidth * zoom / hand.length / 1.5
        }

        // calculate the card position and rotation in the hand and change the z order
        for (var i = 0; i < hand.length; i ++){
            var card = hand[i]
            // angle span for spread cards in hand
            var handAngle = 40
            // card angle depending on the array position
            var cardAngle = handAngle / hand.length * (i + 0.5) - handAngle / 2
            //offset of all cards + one card width
            var handWidth = offset * (hand.length - 1) + card.originalWidth * zoom
            // x value depending on the array position
            var cardX = (playerHand.originalWidth * zoom - handWidth) / 2 + (i * offset)

            card.rotation = cardAngle
            card.y = Math.abs(cardAngle) * 1.5
            card.x = cardX
            card.z = i +50 + playerHandImage.z
        }

    }

    // pick up specified amount of cards
    function pickUpCards(amount){
        onuButton.button.enabled = false
        var pickUp = deck.handOutCards(amount)

        if (chinaHidden.length==0){ //if first round
            for (var i = 0; i < 3; i ++){
                pickUp[i].newParent = playerHand
                pickUp[i].state = "china"
                pickUp[i].hidden = false
                china.push(pickUp[i])
            }


            for (i = 3; i < 6; i ++){
                pickUp[i].newParent = playerHand
                pickUp[i].state = "chinaHidden"
                pickUp[i].hidden = true
                chinaHidden.push(pickUp[i])
            }

            //reorganize china
            neatChina()



            // add the stack cards to the playerHand array
            for (i = 6; i < pickUp.length; i ++){
                hand.push(pickUp[i])
                changeParent(pickUp[i])
                if (multiplayer.localPlayer == player){
                    pickUp[i].hidden = false
                }
                drawSound.play()
            }
            // reorganize the hand
            neatHand()
        }

        else{
            // add the stack cards to the playerHand array
            for (i = 0; i < pickUp.length; i ++){
                hand.push(pickUp[i])
                changeParent(pickUp[i])
                if (multiplayer.localPlayer == player){
                    pickUp[i].hidden = false
                }
                drawSound.play()
            }
            // reorganize the hand
            neatHand()
        }
    }

    // pick up specified amount of cards
    function pickUpDepot(){
        var pickUp = depot.handOutCards()
        // add the depot cards to the playerHand array
        for (var i = 0; i < pickUp.length; i ++){
            hand.push(pickUp[i])
            changeParent(pickUp[i])
            if (multiplayer.localPlayer == player){
                pickUp[i].hidden = false
            }
            drawSound.play()
        }
        // reorganize the hand
        neatHand()
    }


    // change the current hand card array
    function syncHand(cardIDs) {
        hand = []
        for (var i = 0; i < cardIDs.length; i++){
            var tmpCard = entityManager.getEntityById(cardIDs[i])
            hand.push(tmpCard)
            changeParent(tmpCard)
            deck.cardsInStack --
            if (multiplayer.localPlayer == player){
                tmpCard.hidden = false
            }
            drawSound.play()
        }
        // reorganize the hand
        neatHand()
    }

    // change the parent of the card to playerHand
    function changeParent(card){
        card.newParent = playerHand
        card.state = "player"
    }

    // check if a card with a specific id is on this hand
    function inHand(cardId){
        for (var i = 0; i < hand.length; i ++){
            if(hand[i].entityId === cardId){
                return true
            }
        }
        return false
    }

    // remove card with a specific id from hand
    function removeFromHand(cardId){
        for (var i = 0; i < hand.length; i ++){
            if(hand[i].entityId === cardId){
                hand[i].width = hand[i].originalWidth
                hand[i].height = hand[i].originalHeight
                hand.splice(i, 1)
                depositSound.play()
                neatHand()
                return
            }
        }
    }

    // highlight all valid cards by setting the glowImage visible
    function markValid(){
        if (!depot.skipped && !gameLogic.gameOver){
            for (var i = 0; i < hand.length; i ++){
                if (depot.validCard(hand[i].entityId)){
                    hand[i].glowImage.visible = true
                    hand[i].updateCardImage()
                }else{
                    hand[i].glowImage.visible = false
                    hand[i].saturation = -0.5
                    hand[i].lightness = 0.5
                }
            }
            // mark the stack if there are no valid cards in hand
            var validId = randomValidId() //ai
            if(validId == null){
                //deck.markStack()
                //take depot
                pickUpDepot()
            }
        }
    }

    // unmark all cards in hand
    function unmark(){
        for (var i = 0; i < hand.length; i ++){
            hand[i].glowImage.visible = false
            hand[i].updateCardImage()
        }
    }

    // scale the whole playerHand of the active localPlayer with a zoom factor
    function scaleHand(scale){
        zoom = scale
        playerHand.height = playerHand.originalHeight * zoom
        playerHand.width = playerHand.originalWidth * zoom
        for (var i = 0; i < hand.length; i ++){
            hand[i].width = hand[i].originalWidth * zoom
            hand[i].height = hand[i].originalHeight * zoom
        }
        for (i =0; i< china.length; i++){
            china[i].width = china[i].originalWidth * zoom
            china[i].height = china[i].originalHeight * zoom
        }
        for (i =0; i< chinaHidden.length; i++){
            chinaHidden[i].width = china[i].originalWidth * zoom
            chinaHidden[i].height = china[i].originalHeight * zoom
        }

        neatHand()
        neatChina()
    }

    // get a random valid card id from the playerHand
    function randomValidId(){
        var valids = getValidCards()
        if (valids.length > 0){
            // return a random valid card from the array
            var randomIndex = Math.floor(Math.random() * (valids.length))
            return valids[randomIndex].entityId
        }else{
            return null
        }
    }

    // get an array with all valid cards
    function getValidCards(){
        var valids = []
        // put all valid card options in the array
        for (var i = 0; i < hand.length; i ++){
            if (depot.validCard(hand[i].entityId)){
                valids.push(entityManager.getEntityById(hand[i].entityId))
            }
        }
        return valids
    }

    // check if the player has zero cards left and stack is empty
    function activateChinaCheck(){
        if (hand.length == 0 && deck.cardsInDeck==0 && chinaHidden.length ==3){
            for (var i = 0; i < china.length; i++) {
                hand[i]=china[i]
            }
            return true
        }
        if (hand.length == 2 && deck.cardsInDeck!=0){
         return 1
        }
        if (hand.length == 1 && deck.cardsInDeck!=0){
         return 2
        }
        if (hand.length == 0 && deck.cardsInDeck!=0){
         return 3
        }
        return 0
    }


    // calculate all card points in hand
    function points(){
        var points = 0
        for (var i = 0; i < hand.length; i++) {
            points += hand[i].points
        }
        return points
    }

    // animate the playerHand width and height
    Behavior on width {
        NumberAnimation { easing.type: Easing.InOutQuad; duration: 400 }
    }

    Behavior on height {
        NumberAnimation { easing.type: Easing.InOutQuad; duration: 400 }
    }
}
