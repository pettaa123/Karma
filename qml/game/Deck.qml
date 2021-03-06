import QtQuick 2.0
import Felgo 3.0

// includes all cards in the game and the stack functionality
Item {
    id: deck
    width: 82
    height: 134

    // amount of cards in the game
    property int cardsInDeck: 52 //108
    // amount of cards in the stack left to draw
    property int cardsInStack: 52 // 108
    // array with the information of all cards in the game
    property var cardInfo: []
    // array with all card entities in the game
    property var cardDeck: []
    // all card types and colors
    property var types: ["2", "3", "4", "5", "6","7", "8", "9","10", "11", "12", "13", "14"]
    property var vals: [10,11,1,2,3,4,5,6,13,7,8,9,12]
    property var cardColor: ["karo", "herz", "pik", "kreuz"]

    // shuffle sound in the beginning of the game
    SoundEffect {
        volume: 0.5
        id: shuffleSound
        source: "../../assets/snd/shuffle.wav"
    }

    // the leader creates the deck in the beginning of the game
    function createDeck(){
        reset()
        fillDeck()
        shuffleDeck()
        printDeck()
    }

    // the other players sync their deck with the leader in the beginning of the game
    function syncDeck(deckInfo){
        reset()
        for (var i = 0; i < cardsInDeck; i ++){
            cardInfo[i] = deckInfo[i]
        }
        printDeck()
    }


    // create the information for all cards
    function fillDeck(){
        var card

        var upper_bound=13


        var unique_random_numbers = []

        while (unique_random_numbers.length < upper_bound) {
            var random_number = Math.floor(Math.random()*(upper_bound));
            if (unique_random_numbers.indexOf(random_number) == -1) {
                // Yay! new random number
                unique_random_numbers.push( random_number );
            }
        }


        // create karo, herz, pik and kreuz colored cards
        for (var i = 0; i < 13; i ++){
            // one 2-Ass value cards per color
            for (var j = 0; j < 4; j ++){
                card = {variationType: types[i], cardColor: cardColor[j], points: 1, hidden: true, order: unique_random_numbers[i]*4+j, val: vals[i]}
                cardInfo.push(card)
            }
        }
    }



    // create the card entities with the cardInfo array
    function printDeck(){
        shuffleSound.play()
        var id
        for (var i = 0; i < cardInfo.length; i ++){
            id = entityManager.createEntityFromUrlWithProperties(
                        Qt.resolvedUrl("Card.qml"), {
                            "variationType": cardInfo[i].variationType,
                            "cardColor": cardInfo[i].cardColor,
                            "points": cardInfo[i].points,
                            "val": cardInfo[i].val,
                            "order": cardInfo[i].order,
                            "hidden": cardInfo[i].hidden,
                            "z": i,
                            "state": "stack",
                            "parent": deck,
                            "newParent": deck})
            cardDeck.push(entityManager.getEntityById(id))
        }
        offsetStack()
    }

    // hand out cards
    function handOutCards(amount){
        var handOut = []
        for (var i = 0; i < (cardsInStack + i) && i < amount; i ++){
            // highest index for the last card on top of the others
            var index = deck.cardDeck.length - (deck.cardDeck.length - deck.cardsInStack) - 1
            handOut.push(cardDeck[index])
            cardsInStack --
        }
        return handOut
    }

    // the leader shuffles the cardInfo array in the beginning of the game
    function shuffleDeck(){
        // randomize array element order in-place using Durstenfeld shuffle algorithm
        for (var i = cardInfo.length - 1; i > 0; i--) {
            var j = Math.floor(Math.random() * (i + 1))
            var temp = cardInfo[i]
            cardInfo[i] = cardInfo[j]
            cardInfo[j] = temp
        }
        cardsInStack = cardsInDeck
    }

    // remove all cards and playerHands between games
    function reset(){
        var toRemoveEntityTypes = ["card"]
        entityManager.removeEntitiesByFilter(toRemoveEntityTypes)
        while(cardDeck.length) {
            cardDeck.pop()
            cardInfo.pop()
        }
        cardsInStack = cardsInDeck
        for (var i = 0; i < playerHands.children.length; i++) {
            playerHands.children[i].reset()
        }
    }

    // get the id of the card on top of the stack
    function getTopCardId(){
        // create a new stack from depot cards if there's no card left to draw
        var index = Math.max(cardDeck.length - (cardDeck.length - cardsInStack) - 1, 0)
        return deck.cardDeck[index].entityId
    }

    // reposition the remaining cards to create a stack
    function offsetStack(){
        for (var i = 0; i < cardDeck.length; i++){
            if (cardDeck[i].state == "stack"){
                cardDeck[i].x = i * (-1.5)
                cardDeck[i].y = i * (-0.5)
            }
        }
    }

    // move the stack cards to the beginning of the cardDeck array
    function moveElement(from, to){
        cardDeck.splice(to,0,cardDeck.splice(from,1)[0])
        return this
    }
}
