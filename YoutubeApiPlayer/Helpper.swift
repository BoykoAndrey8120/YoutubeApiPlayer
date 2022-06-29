//
//  Helpper.swift
//  YoutubeApiPlayer
//
//  Created by Andrey Boyko on 27.06.2022.
//

import Foundation
import UIKit
import YoutubePlayer_in_WKWebView


extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

extension UIView {
    func applyGradient() {
        let gradient = CAGradientLayer()
        guard let colorTop = UIColor(named: "Color1"), let colorBotton = UIColor(named: "Color2") else { return }
        gradient.colors = [colorTop.cgColor,
                           colorBotton.cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.frame = self.bounds
        self.layer.insertSublayer(gradient, at: 0)
    }
}

extension ViewController : WKYTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: WKYTPlayerView) {
        playerView.playVideo()
    }
}
