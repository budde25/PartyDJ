import UIKit
import StoreKit

class ViewController: UIViewController,
                      SPTAppRemotePlayerStateDelegate,
                      SPTAppRemoteUserAPIDelegate,
                      SKStoreProductViewControllerDelegate {

    private let playURI = "spotify:album:5uMfshtC2Jwqui0NUyUYIL"

    private var currentPodcastSpeed: SPTAppRemotePodcastPlaybackSpeed?


    // MARK: Player State
    @IBOutlet weak var playerStateSubscriptionButton: UIButton!

    @IBAction func didPressPlayerStateSubscriptionButton(_ sender: AnyObject) {
        if (subscribedToPlayerState) {
            unsubscribeFromPlayerState()
        } else {
            subscribeToPlayerState()
        }
    }

    private func updatePlayerStateSubscriptionButtonState() {
        let playerStateSubscriptionButtonTitle = subscribedToPlayerState ? "Unsubscribe" : "Subscribe"
        playerStateSubscriptionButton.setTitle(playerStateSubscriptionButtonTitle, for: UIControl.State())
    }

    // MARK: Capabilities
    @IBOutlet weak var onDemandCapabilitiesLabel: UILabel!
    @IBOutlet weak var capabilitiesSubscriptionButton: UIButton!

    @IBAction func didPressGetCapabilitiesButton(_ sender: AnyObject) {
        fetchUserCapabilities()
    }

    @IBAction func didPressCapabilitiesSubscriptionButton(_ sender: AnyObject) {
        if (subscribedToCapabilities) {
            unsubscribeFromCapailityChanges()
        } else {
            subscribeToCapabilityChanges()
        }
    }

    private func updateViewWithCapabilities(_ capabilities: SPTAppRemoteUserCapabilities) {
        onDemandCapabilitiesLabel.text = "Can play on demand: " + (capabilities.canPlayOnDemand ? "Yes" : "No")
    }

    private func updateCapabilitiesSubscriptionButtonState() {
        let capabilitiesSubscriptionButtonTitle = subscribedToCapabilities ? "Unsubscribe" : "Subscribe"
        capabilitiesSubscriptionButton.setTitle(capabilitiesSubscriptionButtonTitle, for: UIControl.State())
    }

    // MARK: Shuffle Button
    @IBOutlet weak var toggleShuffleButton: UIButton!
    @IBOutlet weak var shuffleModeLabel: UILabel!

    @IBAction func didPressToggleShuffleButton(_ sender: AnyObject) {
        toggleShuffle()
    }
    private func updateShuffleLabel(_ isShuffling: Bool) {
        shuffleModeLabel.text = "Shuffle mode: " + (isShuffling ? "On" : "Off")
    }

    // MARK: Repeat Mode Button
    @IBOutlet weak var toggleRepeatModeButton: UIButton!
    @IBOutlet weak var repeatModeLabel: UILabel!
    @IBAction func didPressToggleRepeatModeButton(_ sender: AnyObject) {
        toggleRepeatMode()
    }

    private func updateRepeatModeLabel(_ repeatMode: SPTAppRemotePlaybackOptionsRepeatMode) {
        repeatModeLabel.text = "Repeat mode: " + {
            switch repeatMode {
            case .off: return "Off"
            case .track: return "Track"
            case .context: return "Context"
            default: return "Off"
            }
            }()
    }

    private var playerState: SPTAppRemotePlayerState?
    private var subscribedToPlayerState: Bool = false
    
    
    private func displayError(_ error: NSError?) {
        if let error = error {
            presentAlert(title: "Error", message: error.description)
        }
    }

    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: StoreKit
    private func showAppStoreInstall() {
        if TARGET_OS_SIMULATOR != 0 {
            presentAlert(title: "Simulator In Use", message: "The App Store is not available in the iOS simulator, please test this feature on a physical device.")
        } else {
            let loadingView = UIActivityIndicatorView(frame: view.bounds)
            view.addSubview(loadingView)
            loadingView.startAnimating()
            loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
            let storeProductViewController = SKStoreProductViewController()
            storeProductViewController.delegate = self
            storeProductViewController.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: SPTAppRemote.spotifyItunesItemIdentifier()], completionBlock: { (success, error) in
                loadingView.removeFromSuperview()
                if let error = error {
                    self.presentAlert(
                        title: "Error accessing App Store",
                        message: error.localizedDescription)
                } else {
                    self.present(storeProductViewController, animated: true, completion: nil)
                }
            })
        }
    }

    public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    


    private func toggleShuffle() {
        guard let playerState = playerState else { return }
        appRemote.playerAPI?.setShuffle(!playerState.playbackOptions.isShuffling, callback: defaultCallback)
    }


    private func playTrackWithIdentifier(_ identifier: String) {
        appRemote.playerAPI?.play(identifier, callback: defaultCallback)
    }

    private func subscribeToPlayerState() {
        guard (!subscribedToPlayerState) else { return }
        appRemote.playerAPI!.delegate = self
        appRemote.playerAPI?.subscribe { (_, error) -> Void in
            guard error == nil else { return }
            self.subscribedToPlayerState = true
            self.updatePlayerStateSubscriptionButtonState()
        }
    }

    private func unsubscribeFromPlayerState() {
        guard (subscribedToPlayerState) else { return }
        appRemote.playerAPI?.unsubscribe { (_, error) -> Void in
            guard error == nil else { return }
            self.subscribedToPlayerState = false
            self.updatePlayerStateSubscriptionButtonState()
        }
    }

    private func toggleRepeatMode() {
        guard let playerState = playerState else { return }
        let repeatMode: SPTAppRemotePlaybackOptionsRepeatMode = {
            switch playerState.playbackOptions.repeatMode {
            case .off: return .track
            case .track: return .context
            case .context: return .off
            default: return .off
            }
        }()

        appRemote.playerAPI?.setRepeatMode(repeatMode, callback: defaultCallback)
    }

    // MARK: - Image API
    private func fetchAlbumArtForTrack(_ track: SPTAppRemoteTrack, callback: @escaping (UIImage) -> Void ) {
        appRemote.imageAPI?.fetchImage(forItem: track, with:CGSize(width: 1000, height: 1000), callback: { (image, error) -> Void in
            guard error == nil else { return }

            let image = image as! UIImage
            callback(image)
        })
    }

    // MARK: - User API
    private var subscribedToCapabilities: Bool = false

    private func fetchUserCapabilities() {
        appRemote.userAPI?.fetchCapabilities(callback: { (capabilities, error) in
            guard error == nil else { return }

            let capabilities = capabilities as! SPTAppRemoteUserCapabilities
            self.updateViewWithCapabilities(capabilities)
        })
    }

    private func subscribeToCapabilityChanges() {
        guard (!subscribedToCapabilities) else { return }
        appRemote.userAPI!.delegate = self
        appRemote.userAPI?.subscribe(toCapabilityChanges: { (success, error) in
            guard error == nil else { return }

            self.subscribedToCapabilities = true
            self.updateCapabilitiesSubscriptionButtonState()
        })
    }

    private func unsubscribeFromCapailityChanges() {
        guard (subscribedToCapabilities) else { return }
        AppDelegate.sharedInstance.appRemote.userAPI?.unsubscribe(toCapabilityChanges: { (success, error) in
            guard error == nil else { return }

            self.subscribedToCapabilities = false
            self.updateCapabilitiesSubscriptionButtonState()
        })
    }

    // MARK: - <SPTAppRemotePlayerStateDelegate>
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        self.playerState = playerState
    }

    // MARK: - <SPTAppRemoteUserAPIDelegate>
    func userAPI(_ userAPI: SPTAppRemoteUserAPI, didReceive capabilities: SPTAppRemoteUserCapabilities) {
        updateViewWithCapabilities(capabilities)
    }

    func showError(_ errorDescription: String) {
        let alert = UIAlertController(title: "Error!", message: errorDescription, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func appRemoteConnected() {
        subscribeToPlayerState()
        subscribeToCapabilityChanges()
    }

    func appRemoteDisconnect() {
        self.subscribedToPlayerState = false
        self.subscribedToCapabilities = false
    }
}
