//
//  ChannelCollectionViewCell.swift
//  YoutubeApiPlayer
//
//  Created by Andrey Boyko on 27.06.2022.
//

import UIKit

class ChannelCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageChannel: UIImageView!
    @IBOutlet weak var subscribers: UILabel!
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(subscriptions: Subscriptions) {
            if let urlImage = URL(string: subscriptions.url) {
            self.imageChannel.load(url: urlImage)
                self.imageChannel.layer.cornerRadius = self.imageChannel.frame.width/8.0
        }
        self.subscribers.text = subscriptions.channelTitle
        self.title.text = subscriptions.count
    }

}
