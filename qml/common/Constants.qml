pragma Singleton
import Felgo 3.0
import QtQuick 2.0

Item {
    id: constants

    // create on your own license key on https://www.felgo.com/license
    readonly property string licenseKey: "CF1A3A9276DEE33B42302670D49A3C09404F8002C9422DEAB1A0F9A9D9FFEDD7562BF5BD59F64CFBF2FDFAE246C484B931DC546257F73188B984ADF8E97B60549C2263221FF2621E5FCCD2019687175DADE8BB78BF374DF4404BC0D48D599DFDA0529A9B63F2F65DE10A01211ACC3C5F50CAB949E464B070BE9E1494C3F9C3B1A62FF41D996C9BB0A341D37B7D8FBB4D7BF986DE1155F5EAC03E160B3092AA38C16AFDBEEE9B9F3B11D135AFA27840BB3CE63F26D30C2828C74EE34C13DA6BACBBC2EA1BE5BC52C1A551F254E0FD0EAB5FF7B508499937CC50628DEAD15A0FD7405A108C4B7F60091011876184E9F301789FE5539603CCBE184FEA9C32EBD1A3FF8FF47CCD15D1ED9C85F558BFACA732B9B83210A359EE75B291C016B362EBD13FF065BC318D0742BDE50CF40CD1DF76C3C301A396EC2BCB408AFB5176AD377FDCE020F46F1DCFA9F5E34399F15F6000"

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
