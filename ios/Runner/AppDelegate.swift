import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate{

    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        NSLog("Spotify connection established")
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        NSLog("Spotify connection failed")
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
      NSLog("Spotify disconnected")
    }

    
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
       NSLog("Spotify player state changed")
    }
    
    override func applicationDidBecomeActive(_ application: UIApplication) {
        NSLog("active")
        appRemote.connect()
    }

    


    
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
        let channel = FlutterMethodChannel(name: "dev.budde.spotify_queue",
                                                        binaryMessenger: controller.binaryMessenger)
        
            channel.setMethodCallHandler({
               (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
                  // Note: this method is invoked on the UI thread.
                  
                switch call.method {
                case "play":
                    NSLog("Play")

                    self.startPlayback()
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
                    NSLog("Connect")
                    //self.startSpotify(open: URL)
                    break
                case "play_song":
                     NSLog("Play Song")
                     
                     if let args = call.arguments as? [String] {
                         if args.count == 1 {
                            self.playTrack(args[0])
                         } else {
                            NSLog("Wrong arg count")
                        }
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
        appRemote.playerAPI?.play(trackIdentifier, callback: defaultCallback)
    }
        
}
