import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate{

    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        NSLog("Spotify connection established")
        self.appRemote.playerAPI?.delegate = self
        self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
        })
        self.appRemote.playerAPI?.setShuffle(false, callback: defaultCallback)
        self.appRemote.playerAPI?.setRepeatMode(SPTAppRemotePlaybackOptionsRepeatMode.off, callback: defaultCallback)
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        NSLog("Spotify connection failed")
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
      NSLog("Spotify disconnected")
    }

    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
       debugPrint("Track name: %@", playerState.track.name)
        invokeCurrentTrack(track: playerState.track)
        invokeIsPaused(isPaused: playerState.isPaused)
    }
    
    override func applicationDidBecomeActive(_ application: UIApplication) {
        if let _ = self.appRemote.connectionParameters.accessToken {
            self.appRemote.connect()
        }
    }
    
    override func applicationWillResignActive(_ application: UIApplication) {
        if self.appRemote.isConnected {
            self.appRemote.disconnect()
        }
    }
    
    func invokeCurrentTrack(track: SPTAppRemoteTrack) {
        let song:[String] = [track.name, track.artist.name, track.uri, track.imageIdentifier]
        channel.invokeMethod("song", arguments: song)
    }
    
    func invokeIsPaused(isPaused: Bool) {
        channel.invokeMethod("isPaused",arguments: isPaused)
    }

    private var channel: FlutterMethodChannel!
    private let CHANNEL: String = "dev.budde.spotify_queue"
    private let clientIdentifier = "12e51e7fd567478db5db871585124355"
    private let redirectUri = URL(string: "dev.budde.spotifyqueue://callback")!
    
    // keys
    static private let kAccessTokenKey = "access-token-key"

    var accessToken = UserDefaults.standard.string(forKey: kAccessTokenKey) {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(accessToken, forKey: AppDelegate.kAccessTokenKey)
            defaults.synchronize()
        }
    }

    lazy var appRemote: SPTAppRemote = {
        let configuration = SPTConfiguration(clientID: self.clientIdentifier, redirectURL: self.redirectUri)
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        return appRemote
    }()
    
    override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
                     
        NSLog("Init Application")
        
        GeneratedPluginRegistrant.register(with: self)
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        channel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)
        
            channel.setMethodCallHandler({
               (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
                  // Note: this method is invoked on the UI thread.
                  
                switch call.method {
                case "play":
                    NSLog("Play")
                    if (self.appRemote.isConnected) {
                        self.startPlayback()
                    } else {
                        self.appRemote.authorizeAndPlayURI("")
                        self.startPlayback()
                    }
                    break
                
                case "pause":
                    NSLog("Pause")

                    self.pausePlayback()
                    break
                  
                case "skip_next":
                    NSLog("Skip next")

                    self.skipNext()
                    break
                case "skip_previous":
                    NSLog("Skip previous")

                    self.skipPrevious()
                     break

                case "connect":

                    break
                case "play_song":
                    NSLog("Play Song")
                     
                    if let args = call.arguments as? [String: Any] {
                        NSLog(String(args.count))
                         if args.count == 1 {
                            self.playTrack(args["track"] as? String ?? "Error")
                         } else {
                            NSLog("Wrong arg count")
                        }
                     } else {
                        NSLog("Error getting args")
                    }
                break
                default:
                    NSLog("Error invalid method call")
                    break
                }
                  
            })
            
              return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
        

    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        NSLog("init Spotify")
        let parameters = appRemote.authorizationParameters(from: url)

        if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = access_token
            self.accessToken = access_token
        } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
            NSLog(error_description)
        }
  return true
}

    
      var defaultCallback: SPTAppRemoteCallback {
        get {
            return {[weak self] _, error in
                if let error = error {
                    print(error as NSError)
                }
            }
        }
    }
    

    public func skipNext() {
        appRemote.playerAPI?.skip(toNext: defaultCallback)
    }

    public func skipPrevious() {
        appRemote.playerAPI?.skip(toPrevious: defaultCallback)
    }

    public func startPlayback() {
        appRemote.playerAPI?.resume(defaultCallback)
    }

    public func pausePlayback() {
        appRemote.playerAPI?.pause(defaultCallback)
    }
    
    public func playTrack(_ trackIdentifier: String) {
        NSLog(trackIdentifier)
        
        appRemote.authorizeAndPlayURI(trackIdentifier)
    }
    
    private func subscribeToPlayerState() {
        appRemote.playerAPI?.subscribe { (_, error) -> Void in
            guard error == nil else { return }
        }
    }
        
}
