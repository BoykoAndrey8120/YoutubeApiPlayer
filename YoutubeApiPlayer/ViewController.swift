//
//  ViewController.swift
//  YoutubeApiPlayer
//
//  Created by Andrey Boyko on 27.06.2022.
//

import GoogleAPIClientForREST
import GoogleSignIn
import UIKit
import RxSwift
import RxCocoa
import YoutubePlayer_in_WKWebView

class ViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    @IBOutlet weak var player: WKYTPlayerView!
    @IBOutlet weak var buttonActivatePlayer: UIButton!
    @IBOutlet weak var collectionVideos: UICollectionView!
    @IBOutlet weak var collectionPlaylists: UICollectionView!
    @IBOutlet weak var collectionChannel: UICollectionView!
    @IBOutlet weak var buttonPlayer: UIButton!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var constraintButtonPlayer: NSLayoutConstraint!
    // If modifying these scopes, delete your previously saved credentials by
    @IBOutlet weak var leftButton: UIButton!
    // resetting the iOS simulator or uninstall the app.
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    private let scopes = [kGTLRAuthScopeYouTubeReadonly]
    private let service = GTLRYouTubeService()
    let signInButton = GIDSignInButton()
    let output = UITextView()
    var arrayOfSubscription: [Subscriptions] = []
    var arrayOfPlaylists: [Playlists] = []
    var arrayOfVideos: [Video] = []
    let bag = DisposeBag()
    var playerIsActive = false
    var videoIsActive = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player.delegate = self
        // Configure Google Sign-in.
        configureGoogleSignin()
        
        // Add the sign-in button.
        view.addSubview(signInButton)
        
        // Add a UITextView to display output.
        output.frame = view.bounds
        output.isEditable = false
        output.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        output.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        output.isHidden = true
        // view.addSubview(output);
        collectionChannel.delegate = self
        collectionChannel.dataSource = self
        collectionChannel.register(UINib(nibName: "ChannelCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ChannelCollectionViewCell")
        collectionPlaylists.delegate = self
        collectionPlaylists.dataSource = self
        collectionPlaylists.register(UINib(nibName: "PlaylistCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PlaylistCollectionViewCell")
        collectionVideos.delegate = self
        collectionVideos.dataSource = self
        collectionVideos.register(UINib(nibName: "VideosCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "VideosCollectionViewCell")
        
        
    }
    
    override func viewDidLayoutSubviews() {
        // self.playerView.updateConstraints()
        playerView.applyGradient()
        playerView.clipsToBounds = true
        playerView.layer.cornerRadius = 10
    }
    
    func configureGoogleSignin() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signInSilently()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        } else {
            self.signInButton.isHidden = true
            self.output.isHidden = false
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            fetchSubscription()
        }
    }
    
    
    // List up to 10 files in Drive
    func fetchSubscription() {
        let query = GTLRYouTubeQuery_SubscriptionsList.query(withPart: "snippet")
        query.mine = true
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(displayResultWithTicketSub(ticket:finishedWithObject:error:)))
    }
    
    // Process the response and display output
    @objc func displayResultWithTicketSub(
        ticket: GTLRServiceTicket,
        finishedWithObject response: GTLRYouTube_SubscriptionListResponse,
        error : NSError?) {
        
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        if let subscription = response.items, !subscription.isEmpty {
            for sub in subscription {
                let item = Subscriptions(
                    channelTitle: sub.snippet?.title ?? "",
                    channelId: sub.identifier ?? "",
                    url: sub.snippet?.thumbnails?.high?.url ?? "",
                    count: sub.contentDetails?.newItemCount?.stringValue ?? "")
                self.arrayOfSubscription.append(item)
            }
        }
        let observable = Observable.just(self.arrayOfSubscription)
        observable.subscribe { event in
            if event.isCompleted {
                self.collectionChannel.reloadData()
            }
        }.disposed(by: bag)
        self.fetchPlaylists()
    }
    
    func fetchPlaylists() {
        let query = GTLRYouTubeQuery_PlaylistsList.query(withPart: "snippet, contentDetails")
        query.channelId = "UCuvCKE0ibaW81NBwfOmCv3g"
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(displayResultWithTicketPlaylists(ticket:finishedWithObject:error:)))
    }
    
    // Process the response and display output
    @objc func displayResultWithTicketPlaylists(
        ticket: GTLRServiceTicket,
        finishedWithObject response: GTLRYouTube_PlaylistListResponse,
        error : NSError?) {
        
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        if let playlists = response.items, !playlists.isEmpty {
            for play in playlists {
                let item = Playlists(title: play.snippet?.channelTitle ?? "",
                                     id: play.identifier ?? "",
                                     url: play.snippet?.thumbnails?.high?.url ?? "")
                self.arrayOfPlaylists.append(item)
            }
        }
        let observable = Observable.just(self.arrayOfPlaylists)
        observable.subscribe { event in
            if event.isCompleted {
                self.collectionPlaylists.reloadData()
                self.fetchVideo()
                print("complite")
            }
        }.disposed(by: bag)
    }
    
    func fetchVideo() {
        let query = GTLRYouTubeQuery_VideosList.query(withPart: "snippet, contentDetails, statistics")
        query.chart = kGTLRYouTubeChartMostPopular
        query.maxResults = 10
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(displayResultWithTicketVideo(ticket:finishedWithObject:error:)))
    }
    
    // Process the response and display output
    @objc func displayResultWithTicketVideo(
        ticket: GTLRServiceTicket,
        finishedWithObject response: GTLRYouTube_VideoListResponse,
        error : NSError?) {
        
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        if let videos = response.items, !videos.isEmpty {
            for video in videos {
                let item = Video(title: video.snippet?.title ?? "",
                                 count: video.statistics?.viewCount?.stringValue ?? "",
                                 url: video.snippet?.thumbnails?.high?.url ?? "",
                                 id: video.identifier ?? "")
                self.arrayOfVideos.append(item)
            }
        }
        let observable = Observable.just(self.arrayOfVideos)
        observable.subscribe { event in
            if event.isCompleted {
                self.collectionVideos.reloadData()
                print("complite")
            }
        }.disposed(by: bag)
        
    }
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertController.Style.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertAction.Style.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    //MARK: - Action
    
    @IBAction func activatePlayer(_ sender: Any) {
        if playerIsActive == false {
            UIView.animate(withDuration: 0.3, animations: {
                self.constraintButtonPlayer.constant = self.constraintButtonPlayer.constant + self.playerView.bounds.height - 25
                self.view.layoutSubviews()
            }, completion: { _ in
                self.buttonPlayer.imageView?.image = UIImage(named: "arrowDown")
                self.playerIsActive = true
                self.view.layoutSubviews()
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.constraintButtonPlayer.constant = self.constraintButtonPlayer.constant - self.playerView.bounds.height + 25
                self.view.layoutSubviews()
            }, completion: { _ in
                self.buttonPlayer.imageView?.image = UIImage(named: "arrowUp")
                self.playerIsActive = false
                self.view.layoutSubviews()
            })
        }
    }
    
    @IBAction func playOrPause(_ sender: Any) {
        switch videoIsActive {
        case true:
            if (pauseButton.imageView?.image == UIImage(named: "pause")) {
                break
            } else {
            player.pauseVideo()
            pauseButton.imageView?.image = UIImage(named: "play")
            videoIsActive = false
            }
        case false:
            if (pauseButton.imageView?.image == UIImage(named: "play")) {
                player.playVideo()
                pauseButton.imageView?.image = UIImage(named: "pause")
                videoIsActive = true
            }
        }
    }
    
}

//MARK: - UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        switch collectionView {
        case collectionChannel:
            count = arrayOfSubscription.count
            return count
        case collectionPlaylists:
            count = arrayOfPlaylists.count
            return count
        case collectionVideos:
            count = arrayOfVideos.count
            return count
        default:
            break
        }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView == collectionChannel) {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChannelCollectionViewCell", for: indexPath) as? ChannelCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.setup(subscriptions: arrayOfSubscription[indexPath.item])
            return cell
        }
        if (collectionView == collectionPlaylists) {
            guard let cell2 = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaylistCollectionViewCell", for: indexPath) as? PlaylistCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell2.setup(playlist: arrayOfPlaylists[indexPath.item])
            return cell2
        }
        if (collectionView == collectionVideos) {
            guard let cell3 = collectionView.dequeueReusableCell(withReuseIdentifier: "VideosCollectionViewCell", for: indexPath) as? VideosCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell3.setup(video: arrayOfVideos[indexPath.item])
            return cell3
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == collectionVideos {
            player.load(withVideoId: arrayOfVideos[indexPath.item].id)
            pauseButton.imageView?.image = UIImage(named: "pause")
            self.activatePlayer(buttonPlayer)
            videoIsActive = true
        }
    }
}





