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
        source: getPlayerImage()
        width: parent.width / 400 * 560//getPlayerImageWidth() //
        height: parent.height / 134 * 260//getPlayerImageHeight() //
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height * (-0.5)
        z: 0
        smooth: true

        onSourceChanged: {
            z = 0
        }
    }

    // playerHand background image
    // the image changes for the active player
    Image {
        id: firstRoundImage
        source: multiplayer.localPlayer === player && gameLogic.firstRound? "../../assets/img/PlayerHandFirstRound.png" : ""
        width: parent.width / 400 * 750
        height: parent.height / 134 * 550
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height * (-0.5)
        z: 0
        smooth: true

        onSourceChanged: {
            z = 0
        }
    }

    Rectangle {
        id: handRect
        visible: multiplayer.localPlayer === player && gameLogic.firstRound
        width: 97*3+97/3
        height: 152
        color: "transparent"
        opacity: 0.5
        border.color: "black"
        border.width: 2
        radius: 5
        z: firstRoundImage.z+2+100
        x:30

        Text {
            transformOrigin: Item.Left
            //anchors.left: parent.left
            rotation : -90
            anchors.fill:parent
            anchors.leftMargin: 11
            font.family: "Tahoma"
            font.pointSize: 14
            text:  qsTr("hand")
            verticalAlignment: Text.AlignVCenter
        }
    }


    Rectangle {
        id: chinaRect
        visible: multiplayer.localPlayer === player && gameLogic.firstRound
        width: 97*3+97/3
        height: 152
        color: "transparent"
        opacity: 0.5
        border.color: "black"
        border.width: 2
        radius: 5
        z: firstRoundImage.z+1+100
        y:-150
        x:30

        Text {
            transformOrigin: Item.Left
            //anchors.left: parent.left
            rotation : -90
            anchors.fill:parent
            anchors.leftMargin: 11
            font.family: "Tahoma"
            font.pointSize: 14
            text:  qsTr("bunker")
            verticalAlignment: Text.AlignVCenter

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
        visible: depot.skipped && multiplayer.activePlayer === player
        smooth: true
    }


    function checkDone(){
        if (chinaHidden.length===0 && china.length===0 && hand.length===0){
            return true
        }
        return false
    }

    function setDone(){
        done=true
    }

    function resetDone(){
        done=false
    }

    function getPlayerImage()
    {
        if(done)
            return "../../assets/img/PlayerHand3.png"
        if(gameLogic.firstRound && multiplayer.localPlayer === player)
            return ""
        var imagePath = multiplayer.activePlayer === player && !gameLogic.acted && !gameLogic.firstRound? "../../assets/img/PlayerHand2.png" : "../../assets/img/PlayerHand1.png"
        return imagePath
    }


    function setChinaAccessible(){
        chinaAccessible=true
    }


    function setChinaHiddenAccessible(){
        chinaHiddenAccessible=true
    }

    function resetChinaAccessible(){
        chinaAccessible=false
    }

    function resetChinaHiddenAccessible(){
        chinaHiddenAccessible=false
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
        resetChinaAccessible()
        resetChinaHiddenAccessible()
        //scaleHand(1.0)
        resetDone()

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

            card.rotation = hand.length==0 && player.userId===multiplayer.localPlayer.userId? cardAngle:cardAngle-28
            card.y = hand.length==0 && player.userId===multiplayer.localPlayer.userId?Math.abs(cardAngle) * 1.5:-Math.sin(Math.sin((cardAngle-23)*3.14/180))*card.height/1.1 -originalHeight/1.4
            card.x = hand.length==0 && player.userId===multiplayer.localPlayer.userId? cardX:cardX - originalWidth/3
            card.z = hand.length==0 && player.userId===multiplayer.localPlayer.userId?i +50 + playerHandImage.z:i -50 + playerHandImage.z



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

            card.rotation = hand.length==0 && player.userId===multiplayer.localPlayer.userId ? cardAngle : cardAngle-28
            card.y = hand.length==0 && player.userId===multiplayer.localPlayer.userId ? (Math.abs(cardAngle) * 1.5)-5:(-Math.sin(Math.sin((cardAngle-23)*3.14/180))*card.height/1.1 -originalHeight/1.4)-5
            card.x = hand.length==0 && player.userId===multiplayer.localPlayer.userId ? cardX : cardX - originalWidth/3
            card.z = hand.length==0 && player.userId===multiplayer.localPlayer.userId ? i +40 + playerHandImage.z : i -100 + playerHandImage.z
        }
    }

    function neatFirstRound(){
        // recalculate the offset between cards if there are too many in the hand
        // make sure they stay within the playerHand
        offset = originalWidth * zoom / 4

        // calculate the card position and rotation in the hand and change the z order
        for (var i = 0; i < hand.length; i ++){
            var card = hand[i]
            // angle span for spread cards in hand
            var handAngle = 0
            // card angle depending on the array position
            var cardAngle = handAngle / hand.length * (i + 0.5) - handAngle / 2
            //offset of all cards + one card width
            var handWidth = offset * (hand.length - 1) + card.originalWidth * zoom
            // x value depending on the array position
            var cardX = (playerHand.originalWidth * zoom - handWidth) / 2 + (i * offset)

            card.rotation = cardAngle
            card.y = 0
            card.x = cardX
            card.z = i +50 + firstRoundImage.z
        }
        //handRect.x=0
        handRect.y= -5
        handRect.height=hand[0].originalHeight+10

        // calculate the card position and rotation in the hand and change the z order
        for (i = 0; i < china.length; i ++){
            card = china[i]
            // angle span for spread cards in hand
            handAngle = 0 //40
            // card angle depending on the array position
            cardAngle = handAngle / china.length * (i + 0.5) - handAngle / 2
            //offset of all cards + one card width
            handWidth = offset * (china.length - 1) + card.originalWidth * zoom
            // x value depending on the array position
            cardX = (playerHand.originalWidth * zoom - handWidth) / 2 + (i * offset)

            card.rotation = cardAngle
            card.y = -card.height * 1.08
            card.x = cardX
            card.z = i +50 + firstRoundImage.z
        }
        //chinaRect.x=0
        chinaRect.y=-card.height * 1.08-11
        chinaRect.height=china[0].originalHeight+16

        for (i = 0; i < chinaHidden.length; i ++){
            card = chinaHidden[i]
            // angle span for spread cards in hand
            handAngle = 0 //40
            // card angle depending on the array position
            cardAngle = handAngle / chinaHidden.length * (i + 0.5) - handAngle / 2
            //offset of all cards + one card width
            handWidth = offset * (chinaHidden.length - 1) + card.originalWidth * zoom
            // x value depending on the array position
            cardX = (playerHand.originalWidth * zoom - handWidth) / 2 + (i * offset)

            card.rotation = cardAngle
            card.y = -card.height * 1.08-5
            card.x = cardX
            card.z = i +40 + firstRoundImage.z
        }
    }

    function unshakeAll()
    {
        for (var i = 0; i < hand.length; i ++){
            if(hand[i].shaking)hand[i].shakeToggle()
        }
        for (i = 0; i < china.length; i ++){
            if(china[i].shaking)china[i].shakeToggle()
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
                if (multiplayer.localPlayer === player){
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
                if (multiplayer.localPlayer === player){
                    pickUp[i].hidden = false
                }
                drawSound.play()
            }
            // reorganize the hand
            neatHand()
            neatChina()
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
            if(multiplayer.localPlayer === player){
                pickUp[i].hidden = false
            }
            drawSound.play()
        }
        // reorganize the hand

        neatHand()
        neatChina()
    }


    // change the current hand card array
    function syncHand(cardIDs,chinaIDs,chinaHiddenIDs) {
        hand = []
        for (var i = 0; i < cardIDs.length; i++){
            var tmpCard = entityManager.getEntityById(cardIDs[i])
            changeParent(tmpCard)
            deck.cardsInStack --
            if (multiplayer.localPlayer === player){
                tmpCard.hidden = false
            }
            hand.push(tmpCard)
            drawSound.play()
        }
        for (i = 0; i < chinaIDs.length; i++){
            tmpCard = entityManager.getEntityById(chinaIDs[i])
            changeParent(tmpCard)
            tmpCard.state = "china"
            tmpCard.hidden=false
            deck.cardsInStack --
            if (multiplayer.localPlayer === player){
                tmpCard.hidden = false
            }
            china.push(tmpCard)
            drawSound.play()
        }
        for (i = 0; i < chinaHiddenIDs.length; i++){
            tmpCard = entityManager.getEntityById(chinaHiddenIDs[i])
            changeParent(tmpCard)
            tmpCard.state = "chinaHidden"
            deck.cardsInStack --
            if (multiplayer.localPlayer === player){
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
        if (chinaHiddenAccessible){
            for (var i = 0; i < chinaHidden.length; i ++){
                if(chinaHidden[i].entityId === cardId){
                    return true
                }
            }
        }
        else if (chinaAccessible){
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

    function shakeCard(cardId){
        var card=entityManager.getEntityById(cardId)
        if(card.state==="china"){
            for(var i=0;i<china.length;i++){
                if(china[i].shaking && china[i].entityId!==cardId) china[i].shakeToggle()
                if(china[i].entityId===cardId) china[i].shakeToggle()
            }
        }
        if(card.state==="player"){
            for(i=0;i<hand.length;i++){
                if(hand[i].shaking && hand[i].entityId!==cardId) hand[i].shakeToggle()
                if(hand[i].entityId===cardId) hand[i].shakeToggle()
            }
        }
    }

    function exchangeHandAndChinaIndex(handIndex,chinaIndex){
        var temp=hand[handIndex]
        hand.splice(handIndex,1,china[chinaIndex])
        hand[handIndex].state="player"
        china.splice(chinaIndex,1,temp)
        china[chinaIndex].state="china"
    }

    function exchangeShakingCard(){
        var shakingIndex=3
        //hand
        for(var i=0;i<hand.length;i++){
            //find card shaking index
            if(hand[i].shaking){
                shakingIndex=i
                break
            }
        }
        if(shakingIndex!==3){
            for(i=0;i<china.length;i++){
                //find shaking card
                if(china[i].shaking){
                    exchangeHandAndChinaIndex(shakingIndex,i)
                    hand[shakingIndex].shakeToggle()
                    china[i].shakeToggle()
                    neatFirstRound()
                    var userId = multiplayer.localPlayer ? multiplayer.localPlayer.userId : 0
                    multiplayer.sendMessage(gameLogic.messageExchangeCards, {handIndex: shakingIndex, chinaIndex: i,userId: userId})
                    return
                }
            }
            shakingIndex=3
        }
        for(i=0;i<china.length;i++){
            //find card shaking index
            if(china[i].shaking){
                shakingIndex=i
                break
            }
        }
        if(shakingIndex!==3){
            for(i=0;i<hand.length;i++){
                //find shaking card
                if(hand[i].shaking){
                    exchangeHandAndChinaIndex(i,shakingIndex)
                    hand[i].shakeToggle()
                    china[shakingIndex].shakeToggle()
                    neatFirstRound()
                    var userId = multiplayer.localPlayer ? multiplayer.localPlayer.userId : 0
                    multiplayer.sendMessage(gameLogic.messageExchangeCards, {handIndex: i, chinaIndex: shakingIndex,userId: userId})
                    return
                }
            }
        }
    }

    // check if a card with a specific id is on this hand
    function inHandOrChina(cardId){
        for (var i = 0; i < china.length; i ++){
            if(china[i].entityId === cardId){
                return true
            }
        }

        for (i = 0; i < hand.length; i ++){
            if(hand[i].entityId === cardId){
                return true
            }
        }
        return false
    }

    function moveFromChinaHiddenToHand(cardId){
        if (chinaHiddenAccessible){
            for (var i = 0; i < chinaHidden.length; i ++){
                if(chinaHidden[i].entityId === cardId){

                    // add the selected chinaHidden card to the playerHand array
                    if (multiplayer.localPlayer === player){
                        chinaHidden[i].hidden = false
                    }
                    chinaHidden[i].state="player"
                    chinaHidden[i].width = chinaHidden[i].originalWidth
                    chinaHidden[i].height = chinaHidden[i].originalHeight
                    hand.push(chinaHidden[i])
                    chinaHidden.splice(i, 1)
                    resetChinaHiddenAccessible()
                    break
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
                    neatChina()
                    return
                }
            }
        }
        else if(chinaAccessible){
            for (i = 0; i < china.length; i ++){
                if(china[i].entityId === cardId){
                    china[i].width = china[i].originalWidth
                    china[i].height = china[i].originalHeight
                    china.splice(i, 1)
                    depositSound.play()
                    neatChina()
                    return
                }
            }
        }
        else {for (i = 0; i < hand.length; i ++){
                if(hand[i].entityId === cardId){
                    hand[i].width = hand[i].originalWidth
                    hand[i].height = hand[i].originalHeight
                    hand.splice(i, 1)
                    depositSound.play()
                    neatHand()
                    neatChina()
                    return
                }
            }
        }
    }

    // highlight all valid cards by setting the glowImage visible
    function markValid(){

        if (!depot.skipped && !gameLogic.gameOver){ //!done

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
    //function unmark(){
    //    for (var i = 0; i < hand.length; i ++){
    //        hand[i].glowImage.visible = false
    //        hand[i].updateCardImage()
    //    }
    //    if(chinaHiddenAccessible){
    //        for (i = 0; i < chinaHidden.length; i ++){
    //            chinaHidden[i].glowImage.visible = false
    //            chinaHidden[i].updateCardImage()
    //        }
    //
    //    }
    //    if(chinaAccessible){
    //        for (i = 0; i < china.length; i ++){
    //            china[i].glowImage.visible = false
    //            china[i].updateCardImage()
    //        }
    //    }
    //}

    function setFirstRound(){

    }

    // scale the whole playerHand of the active localPlayer with a zoom factor
    function scaleHand(scale){
        zoom = scale
        //if(!chinaAccessible && !chinaHiddenAccessible){
        playerHand.height = playerHand.originalHeight * zoom
        playerHand.width = playerHand.originalWidth * zoom
        //}
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
    }

    // get a random valid card id from the playerHand
    function randomValidIds(){
        var validIds = []
        var valids = getValidCards()
        if (valids.length > 0){
            // return a random valid card from the array
            var randomIndex = Math.floor(Math.random() * (valids.length))
            for(var i=0; i<valids.length;i++){
                if(valids[i].variationType===valids[randomIndex].variationType){
                    validIds.push(valids[i].entityId)
                }
            }
            return validIds
        }
        else{
            return undefined
        }
    }

    //returns worst hand index if val is better
    function worstIndex(valids){
        var worst=14
        var index=111
        for(var i=0;i<valids.length;i++){
            if (valids[i].val<worst){
                worst=valids[i].val
                index=i
            }
        }
        return index
    }

    // get a random valid card id from the playerHand
    function smartValidIds(){
        var validIds = []
        var valids = getValidCards()
        if (valids.length > 0){
            var index=worstIndex(valids)
            for(var i=0; i<valids.length;i++){
                if(valids[i].variationType===valids[index].variationType){
                    validIds.push(valids[i].entityId)
                }
            }
            return validIds
        }
        return undefined
    }

    // get a random valid card id from the playerHand
    function checkFirstValid(){
        var validIds = []
        if (depot.validCard(chinaHidden[0].entityId)){
            validIds.push(chinaHidden[0].entityId)
            return validIds
        }else{
            return undefined
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
        var index=worstChinaIndex()
        for (var i=0;i<hand.length;i++){
            //exchangeWithBetterInHand
            if(index===111) return
            if(hand[i].val>china[index].val){
                //exchange if china is better than hand
                var temp=china[index]

                hand[i].state ="china"
                hand[i].hidden= false
                china.splice(index,1,hand[i])
                temp.state ="player"
                temp.hidden=multiplayer.localPlayer === player? false:true
                hand.splice(i,1,temp)


                //update worst handindex after somethin changed
                index=worstChinaIndex()
            }
        }
    }



    //returns worst hand index if val is better
    function worstChinaIndex(){
        var worst=14
        var index=111
        for(var i=0;i<china.length;i++){
            if (china[i].val<worst){
                worst=china[i].val
                index=i
            }
        }
        return index
    }
    // check if the player has zero cards left and stack is empty
    function activateChinaCheck(){

        if (hand.length ==0 && china.length == 0 && chinaHidden.length >0){
            setChinaHiddenAccessible()
            resetChinaAccessible()
            return 0
        }

        if (hand.length == 0 && deck.cardsInStack==0 && china.length >0){
            setChinaAccessible()
            resetChinaHiddenAccessible()
            return 0
        }

        if (hand.length != 0){
            resetChinaAccessible()
            resetChinaHiddenAccessible()
        }
        console.debug("activateChinaCheck: deck.cardsInStack: " + deck.cardsInStack)
        if (hand.length == 2 && deck.cardsInStack>0){
            return 1
        }
        if (hand.length == 1 && deck.cardsInStack>0){
            return 2
        }
        if (hand.length == 0 && deck.cardsInStack>0){
            return 3
        }
        return 0 //hand.length==3
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

