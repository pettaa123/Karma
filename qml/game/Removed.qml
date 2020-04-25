import QtQuick 2.0
import Felgo 3.0


Item {
    id: removed


    // sound effect plays when a cards get removed
    SoundEffect {
        volume: 0.5
        id: removeSound
        source: "../../assets/snd/deposit.wav"
    }


}
