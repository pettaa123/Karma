pragma Singleton
import Felgo 3.0
import QtQuick 2.0

Item {
    id: constants

    // create on your own license key on https://www.felgo.com/license
    readonly property string licenseKey: "6C62C358F215AE428F357EDBE0FB303FFED6FE4EEA6D26D417654422E490885EB0D17CF1B01957F10434FE6BC9EDC7B4B441E9E0B421EABD56290A5A666A213DEE590F080DF4A8E5776CE8588EA9DBD795F0F58C9C43B140F19CF2D878D966976F05375C210B911378DF9435F0F27F8B18B0AB2332FB5FACB0516B757EC2A2B3E8CD7D35234F9AEC4B4D03258D9967A7EEACD296F9F6A137A8058F038C2F1BD6E407DE388C5C38EEDDEF87F9D1CBEB31E12AF014B70AFD1D46A97D871FA5F94C2F692C98BF9B6B87BA9DFCE735E020CC8C8B2AE81B2384B16656FA8573D178F2E6BA5ED74E59D8263FE307D8F6C93030EF389ADDB1FDA4792B6A116CBD663E61AA61240DAEDAC4A2E0AD5E54DD6CB3698974A44C850FBB09D34E1CADB8F7D10926990264084F933873B88F752BBB55263E2BD03D8007AA56B37D7CBD0AAB5258C2F84619335B6151197490C6B21A569F"

    // FelgoGameNetwork - set your own gameId and secret after you created your own game here: https://cloud.felgo.com/
    readonly property int gameId: 906
    readonly property string gameSecret: "altocincokarma"

    // FelgoMultiplayer - set your own appKey and pushKey after you created your own game here: https://cloud.felgo.com/
    //readonly property string appKey: "c2e647ce-5a83-4153-ae62-5c7d349ba87e"
    readonly property string pushKey: ""

    // Facebook - add your Facebook app-id here (as described in the plugin documentation)
    //readonly property string fbAppId: "<your-app-id>"

    // Google Analytics - add your property id from Google Analytics here (as described in the plugin documentation)
    //readonly property string gaPropertyId: "<your-property-id>"

    // Flurry - from flurry dashboard
    //readonly property string flurryApiKey: "<your-flurry-apikey>"

    // AdMob - add your adMob banner and insterstial unit ids here (as described in the plugin documentation)
    //readonly property string adMobBannerUnitId: "<your-ad-mob-banner-id>"
    //readonly property string adMobInterstitialUnitId: "<your-ad-mob-interstitial-id>"
    //readonly property var adMobTestDeviceIds: ["<your-test-device-id>"]

    // for sending feedback via a php script, use a password
    //readonly property string feedbackSecret: "<secret-for-feedback-dialog>"
    //readonly property string ratingUrl: "<your-rating-url>" // url to open on device for rating the app

    // Soomla In-App Purchases - add your configuration here
    //readonly property string soomlaSecret: "<your-soomla-secret>"
    //readonly property string soomlaAndroidKey: "<your-android-key>"
    //readonly property string currencyId: "<your-currency-id>"
    //readonly property string currency100PackId: "<your-pack1-storeproduct-id>"
    //readonly property string currency500PackId: "<your-pack2-storeproduct-id>"
    //readonly property string currency1000PackId: "<your-pack3-storeproduct-id>"
    //readonly property string currency5000PackId: "<your-pack4-storeproduct-id>"

    // game configuration
    readonly property bool enableStoreAndAds: false // whether in-game store and ads are enabled, if set to false the game is 100% free to play
    readonly property bool simulateStore: false     // if the store should be simulated locally or actually use the soomla plugin to purchase goods
    readonly property bool lockScreenForInterstitial: false // locks screen to prevent user-action while interstitial is opening up
}
