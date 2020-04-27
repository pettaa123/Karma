pragma Singleton
import Felgo 3.0
import QtQuick 2.0

Item {
    id: constants

    // create on your own license key on https://www.felgo.com/license
    readonly property string licenseKey: "A7E64A57ED9981908EEB122D1F09A60C7B10BF71AABA6F01862265395B2868B119EC71B77FFC44AECE81E7B3CAC9F60E3A78C36DAB65A8CE5D6659790610A692ABB6948E3FFA441C156C7D44AFD6DD818433DFA1165C06086DAA87DEF9A47055BBE369AFC31BBBC331AC13E0103E37AA5C95258D22BB5D5FB03690B1A800C0C7A483E82B412C435400FDF4E55E44F50F1F4EB6B5B52F22EA9663EE37473FB580A9B9A0C7657A9F8DE18C145F1DBFE4C115B16809FB7C4384DDD8DCBA532B8B2BD9967CFE27A03A8B5B2405588355CAB3A4861E94C24F692568F72B591EBD0376B96E24CE0A4F14AE9A64FADDBEC3180C25541E647D2359A598E56A1D2A75BF758EA902E97AE4B51040F869A9FB91E9770494DCAE173865F65A150EE446F4AAED27CB576D16299AC06936B5861F42CC35"

    // FelgoGameNetwork - set your own gameId and secret after you created your own game here: https://cloud.felgo.com/
    readonly property int gameId: 856
    readonly property string gameSecret: "altocinco"

    // FelgoMultiplayer - set your own appKey and pushKey after you created your own game here: https://cloud.felgo.com/
    //readonly property string appKey: "c2e647ce-5a83-4153-ae62-5c7d349ba87e"
    //readonly property string pushKey: "JYnG49n8sI5wXsTcdTx8XDZXSefAEaivUMcdMLUl@cI7t1EIp6AYi7qFhY9CdACyYlVpxqlHPZeeqZF4X"

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
