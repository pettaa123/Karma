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
    // the score at the end of the game
    property int score: 0
    // value used to spread the cards in hand
    property double offset: width/10
    //chinaAccessible if hand is empty
    property bool chinaAccessible: false

    //chinaHiddenAccessible if hand is empty
    property bool chinaHiddenAccessible: false
    //player done
    property bool done


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
            //neatHand()
            //neatChina()
        }
    }

    // playerHand blocked image is visible when the player gets skipped
    Image {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        source: "../../assets/img/Blocked.png"
        width: 170
        height: width
        z: 200
        visible: depot.skipped && multiplayer.activePlayer == player
        smooth: true
    }



    function setChinaAccessible(){
        this.chinaAccessible=true
    }


    function setChinaHiddenAccessible(){
        this.chinaHiddenAccessible=true
    }

    function resetChinaAccessible(){
        this.chinaAccessible=false
    }

    function resetChinaHiddenAccessible(){
        this.chinaHiddenAccessible=false
    }

    // start the hand by picking up a specified amount of cards
    function startHand(initialized){
        pickUpCards(start,initialized)
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
            chinaHidden.pop()
        }
        this.resetChinaAccessible()
        this.resetChinaHiddenAccessible()
        //scaleHand(1.0)
        this.done=false

    }

    function neatChina(){
        offset = originalWidth * zoom / 10


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
            card.y = -Math.sin(Math.sin((cardAngle-28)*3.14/180))*card.height/1.1 -originalHeight/1.4
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
            card.y = card.y = -Math.sin(Math.sin((cardAngle-28)*3.14/180))*card.height/1.1 -originalHeight/1.4 -50
            card.x = cardX - originalWidth/3
            card.z = i -100 + playerHandImage.z
        }
    }

    // organize the hand and spread the cards
    function neatHand(){
        // sort all cards by their natural order
        if(hand.length >1){hand.sort(function(a, b) {
            return a.order - b.order
        })
        }

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
    function pickUpCards(amount,initialized){
        var pickUp = deck.handOutCards(amount)

        if (chinaHidden.length==0 && !initialized){ //if first round
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
                chinaHidden.push(pickUp[i])        //var userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0
                //multiplayer.sendMessage(gameLogic.messageSetEffect, {effect: false, userId: userId})
            }

            // add the stack cards to the playerHand array
            for (i = 6; i < pickUp.length; i ++){
                hand.push(pickUp[i])
                changeParent(pickUp[i])
                if (multiplayer.localPlayer == player){
                    pickUp[i].hidden = false
                }
                drawSound.play()
            }
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
        var pickUp = depot.handOutDepot()
        if(pickUp.length>0){
            resetChinaAccessible()
            resetChinaHiddenAccessible()
        }

        // add the depot cards to the playerHand array
        for (var i = 0; i < pickUp.length; i ++){
            hand.push(pickUp[i])
            changeParent(pickUp[i])
            if(multiplayer.localPlayer == player){
                pickUp[i].hidden = false
            }
            drawSound.play()
        }
        // reorganize the hand
        neatHand()
    }


    // change the current hand card array
    function syncHand(cardIDs,chinaIDs,chinaHiddenIDs) {
        hand = []
        for (var i = 0; i < cardIDs.length; i++){
            var tmpCard = entityManager.getEntityById(cardIDs[i])
            changeParent(tmpCard)
            deck.cardsInStack --
            if (multiplayer.localPlayer == player){
                tmpCard.hidden = false
            }
            hand.push(tmpCard)
            drawSound.play()
        }
        for (var i = 0; i < chinaIDs.length; i++){
            var tmpCard = entityManager.getEntityById(chinaIDs[i])
            changeParent(tmpCard)
            tmpCard.state = "china"
            deck.cardsInStack --
            if (multiplayer.localPlayer == player){
                tmpCard.hidden = false
            }
            china.push(tmpCard)
            drawSound.play()
        }
        for (var i = 0; i < chinaHiddenIDs.length; i++){
            var tmpCard = entityManager.getEntityById(chinaHiddenIDs[i])
            changeParent(tmpCard)
            tmpCard.state = "chinaHidden"
            deck.cardsInStack --
            if (multiplayer.localPlayer == player){
                tmpCard.hidden = true
            }
            chinaHidden.push(tmpCard)
            drawSound.play()
        }
        // reorganize the hand
        neatHand()
        neatChina()
    }

    // change the parent of the card to playerHand
    function changeParent(card){
        card.newParent = playerHand
        card.state = "player"
    }

    // check if a card with a specific id is on this hand
    function inHand(cardId){
        if (this.chinaHiddenAccessible){
            for (var i = 0; i < chinaHidden.length; i ++){
                if(chinaHidden[i].entityId === cardId){
                    return true
                }
            }
        }
        else if (this.chinaAccessible){
            for (i = 0; i < china.length; i ++){
                if(china[i].entityId === cardId){
                    return true
                }
            }
        }
        else {for (i = 0; i < hand.length; i ++){
                if(hand[i].entityId === cardId){
                    return true
                }
            }
            return false}
    }

    function moveFromChinaHiddenToHand(cardId){
        if (chinaHiddenAccessible){
            for (var i = 0; i < chinaHidden.length; i ++){
                if(chinaHidden[i].entityId === cardId){

                    // add the selected chinaHidden card to the playerHand array
                    hand.push(chinaHidden[i])
                    changeParent(chinaHidden[i])
                    if (multiplayer.localPlayer == player){
                        chinaHidden[i].hidden = false
                    }
                    // reorganize the hand
                    chinaHidden[i].width = chinaHidden[i].originalWidth
                    chinaHidden[i].height = chinaHidden[i].originalHeight
                    chinaHidden.splice(i, 1)
                    return
                }
                //neatHand()
            }
        }
    }


    // remove card with a specific id from hand
    function removeFromHand(cardId){
        if (chinaHiddenAccessible){
            for (var i = 0; i < chinaHidden.length; i ++){
                if(chinaHidden[i].entityId === cardId){
                    chinaHidden[i].width = chinaHidden[i].originalWidth
                    chinaHidden[i].height = chinaHidden[i].originalHeight
                    chinaHidden.splice(i, 1)
                    depositSound.play()
                    neatHand()
                    return
                }
            }
        }
        else if(chinaAccessible){
            for (var i = 0; i < china.length; i ++){
                if(china[i].entityId === cardId){
                    china[i].width = china[i].originalWidth
                    china[i].height = china[i].originalHeight
                    china.splice(i, 1)
                    depositSound.play()
                    neatHand()
                    return
                }
            }
        }
        else {for (var i = 0; i < hand.length; i ++){
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
    }

    // highlight all valid cards by setting the glowImage visible
    function markValid(){

        if (!depot.skipped && !gameLogic.gameOver){ //!done
            // if there are no valids pick depot
            if(!chinaHiddenAccessible){
                var validIds = randomValidIds() //ai
                if(validIds == null){
                    //deck.markStack()
                    //take depot
                    pickUpDepot()
                }
            }

            if(chinaAccessible){
                for (var i = 0; i < china.length; i ++){
                    if (depot.validCard(china[i].entityId)){
                        china[i].glowImage.visible = true
                        china[i].updateCardImage()
                    }else{
                        china[i].glowImage.visible = false
                        china[i].saturation = -0.5
                        china[i].lightness = 0.5
                    }
                }
            }
            else{
                for (i = 0; i < hand.length; i ++){
                    if (depot.validCard(hand[i].entityId)){
                        hand[i].glowImage.visible=  true
                        hand[i].updateCardImage()
                    }else{
                        hand[i].glowImage.visible = false
                        hand[i].saturation = -0.5
                        hand[i].lightness = 0.5
                    }
                }
            }
        }
    }

    // highlight all valid cards by setting the glowImage visible
    function markMultiples(cardId){
        if (!depot.skipped && !gameLogic.gameOver){ //!done
            var card=entityManager.getEntityById(cardId)
            if(chinaAccessible){
                for (var i = 0; i < china.length; i ++){
                    if (china[i].variationType===card.variationType){
                        china[i].glowImage.visible = true
                        china[i].updateCardImage()
                    }else{
                        china[i].glowImage.visible = false
                        china[i].saturation = -0.5
                        china[i].lightness = 0.5
                    }
                }
            }
            else{
                for (i = 0; i < hand.length; i ++){
                    if (hand[i].variationType===card.variationType){
                        hand[i].glowImage.visible=  true
                        hand[i].updateCardImage()
                    }else{
                        hand[i].glowImage.visible = false
                        hand[i].saturation = -0.5
                        hand[i].lightness = 0.5
                    }
                }
            }
        }
    }


    // unmark all cards in hand
    function unmark(){
        for (var i = 0; i < hand.length; i ++){
            hand[i].glowImage.visible = false
            hand[i].updateCardImage()
        }
        if(chinaHiddenAccessible){
            for (i = 0; i < chinaHidden.length; i ++){
                chinaHidden[i].glowImage.visible = false
                chinaHidden[i].updateCardImage()
            }

        }
        if(chinaAccessible){
            for (i = 0; i < china.length; i ++){
                china[i].glowImage.visible = false
                china[i].updateCardImage()
            }
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
            chinaHidden[i].width = chinaHidden[i].originalWidth * zoom
            chinaHidden[i].height = chinaHidden[i].originalHeight * zoom
        }

        neatHand()
        neatChina()
    }

    // get a random valid card id from the playerHand
    function randomValidIds(){
        var validIds = []
        var valids = getValidCards()
        if (valids.length > 0){
            // return a random valid card from the array
            var randomIndex = Math.floor(Math.random() * (valids.length))
            for(var i=0; i<valids.length;i++){
                if(valids[i].variationType==valids[randomIndex].variationType){
                    validIds.push(valids[i].entityId)
                }
            }
            return validIds
        }else{
            return null
        }
    }

    // get a random valid card id from the playerHand
    function checkFirstValid(){
        var validIds = []
        if (depot.validCard(chinaHidden[0].entityId)){
            validIds.push(chinaHidden[0].entityId)
            return validIds
        }else{
            moveFromChinaHiddenToHand(chinaHidden[0].entityId)
            return null
        }
    }

    // get an array with all valid cards
    function getValidCards(){
        var valids = []
        // put all valid card options in the array

        if(chinaAccessible){
            for (var i = 0; i < china.length; i ++){
                if (depot.validCard(china[i].entityId)){
                    valids.push(entityManager.getEntityById(china[i].entityId))
                }
            }
        }
        else {for (i = 0; i < hand.length; i ++){
                if (depot.validCard(hand[i].entityId)){
                    valids.push(entityManager.getEntityById(hand[i].entityId))
                }
            }}
        return valids
    }

    function optimizeChina(){
        //for(var i =0;i<hand.length;i++)
        //{
        //    console.debug("hand before")
        //    console.debug(hand[i].entityId)
        //    console.debug(hand[i].hidden)}
        var index=worstHandIndex()
        for (var i=0;i<china.length;i++){
            //exchangeWithBetterInHand
            if(index===111) return
            if(china[i].val>hand[index].val){
                //exchange if china is better than hand
                var temp=hand[index]

                china[i].state ="player"
                china[i].hidden= multiplayer.localPlayer == player? false:true
                hand.splice(index,1,china[i])
                temp.state ="china"
                temp.hidden=false
                china.splice(i,1,temp)


                //update worst handindex after somethin changed
                index=worstHandIndex()
            }
        }
        for(var i =0;i<hand.length;i++)
        {
            console.debug("hand after")
            console.debug(hand[i].entityId)
            console.debug(hand[i].hidden)}
    }



    //returns worst hand index if val is better
    function worstHandIndex(){
        var worst=13
        var index=111
        for(var i=0;i<hand.length;i++){
            if (hand[i].val<worst){
                worst=hand[i].val
                index=i
            }
        }
        return index
    }
    // check if the player has zero cards left and stack is empty
    function activateChinaCheck(){
        if (this.hand.length == 0 && deck.cardsInStack==0 && china.length >0){
            this.setChinaAccessible()
            return 0
        }
        if (this.hand.length ==0 && china.length == 0 && chinaHidden.length >0){
            this.setChinaHiddenAccessible()
            this.resetChinaAccessible()
            return 0
        }
        if( chinaHidden.length == 0 && hand.length == 0){
            this.done=true
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
        if(hand.length<1){
            points=10
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
